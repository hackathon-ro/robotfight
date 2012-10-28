<?
class LoginPage extends Page {
    public function run() {
        if (
            !array_key_exists('username', $this->data) ||
            !array_key_exists('lat', $this->data) ||
            !array_key_exists('long', $this->data)
        ) {
            return;
        }

        $db = Database::getInstance();

        // Get user and update his location.
        $a = [
            'long' => ':long',
            'lat' => ':lat'
        ];
        $sql = "
            UPDATE users
            SET " . Misc::arrayToUpdateQuery($a) . "
            WHERE
                lower(username) = :username
            RETURNING
                id,
                username,
                wins,
                losses,
                state,
                opponent_id,
                lat,
                long
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([
            ':username' => $this->data['username'],
            ':long' => $this->data['long'],
            ':lat' => $this->data['lat']
        ]);
        $user = null;

        // Create user if he doesn't already exist.
        if ($stm->rowCount() === 0) {
            $newUser = true;
            $a = [
                'username' => ':username',
                'long' => ':long',
                'lat' => ':lat',
                'state' => UserStates::AWAITING_MATCH,
                'match_making_began_on' => 'NOW()'
            ];
            $sql = "
                INSERT INTO users " . Misc::arrayToInsertQuery($a) . "
                RETURNING
                    id,
                    username,
                    wins,
                    losses,
                    state,
                    opponent_id
                    lat,
                    long
            ";
            $stm = $db->conn->prepare($sql);
            $result = $stm->execute([
                ':username' => $this->data['username'],
                ':long' => $this->data['long'],
                ':lat' => $this->data['lat']
            ]);
            $user = $stm->fetch();
        }
        else {
            $user = $stm->fetch();

            // Delete previous updates.
            $sql = "
                DELETE FROM updates
                WHERE user_id = :user_id
            ";
                $stm = $db->conn->prepare($sql);
                $result = $stm->execute([
                    ':user_id' => $user['id']
                ]);
        }

        // Reset user state for users that were playing with this user.
        $sql = "
            SELECT
                id
            FROM users
            WHERE opponent_id = :opponent_id
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([
            ':opponent_id' => $user['id']
        ]);
        while ($row = $stm->fetch()) {
            // Notify that the match has ended.
            $pushQueue = PushQueue::getInstance();
            $pushQueue->add('match-ended', []);

            $this->startMatchMaking($row['id']);
        }

        // Do match-making.
        $this->startMatchMaking($user['id']);

        // Delete other sessions for this user.
        $sql = "
            DELETE
            FROM sessions
            WHERE
                user_id = :user_id
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([':user_id' => $user['id']]);

        // Create session token.
        $token = $this->generateToken();
        $a = [
            'user_id' => ':user_id',
            'token' => ':token'
        ];
        $sql = "
            INSERT INTO sessions " . Misc::arrayToInsertQuery($a) . "
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([
            ':user_id' => $user['id'],
            ':token' => $token
        ]);

        // Return data.
        $this->result = [
            'success' => true,
            'username' => $user['username'],
            'token' => $token,
            'wins' => $user['wins'],
            'losses' => $user['losses']
        ];
    }

    private function generateToken() {
        return Misc::generateAlphanumericString(24);
    }

    private function startMatchMaking($userId) {
        $db = Database::getInstance();

        // Update user info.
        $a = [
            'state' => UserStates::AWAITING_MATCH,
            'match_making_began_on' => 'NOW()',
            'opponent_id' => 'NULL'
        ];
        $sql = "
            UPDATE users
            SET " . Misc::arrayToUpdateQuery($a) . "
            WHERE id = :id
            RETURNING
                id,
                username,
                wins,
                losses,
                lat,
                long
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([':id' => $userId]);
        $user = $stm->fetch();

        // Do match-making if another opponent is available.
        $sql = "
            SELECT
                id,
                username,
                wins,
                losses,
                lat,
                long
            FROM users
            WHERE
                state = " . UserStates::AWAITING_MATCH . " AND
                match_making_began_on > NOW() - INTERVAL '1000 seconds' AND
                id != :user_id
            ORDER BY match_making_began_on ASC
            LIMIT 1
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([
            'user_id' => $user['id']
        ]);
        if ($stm->rowCount() === 1) {
            //var_dump('found!');
            $match = $stm->fetch();

            // Push notification for the player that just logged in.
            $pushQueue = PushQueue::getInstance();
            $pushQueue->add($userId, [
                'action' => 'found-match',
                'data' => [
                    'username' => $match['username'],
                    'wins' => $match['wins'],
                    'losses' => $match['losses'],
                    'lat' => $match['lat'],
                    'long' => $match['long'],
                    'your-turn' => false
                ]
            ]);

            // Push notification for the player that was waiting for a match.
            $pushQueue = PushQueue::getInstance();
            $pushQueue->add($match['id'], [
                'action' => 'found-match',
                'data' => [
                    'username' => $user['username'],
                    'wins' => $user['wins'],
                    'losses' => $user['losses'],
                    'lat' => $user['lat'],
                    'long' => $user['long'],
                    'your-turn' => true
                ]
            ]);
        }
    }
}