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
                opponent_id
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
                'lat' => ':lat'
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
        }

        // Reset user state if necessary.
        if ($user['state'] != 0) {
            $a = [
                'state' => 0
            ];
            $sql = "
                UPDATE users
                SET " . Misc::arrayToUpdateQuery($a) . "
                WHERE id = :id
            ";
            $stm = $db->conn->prepare($sql);
            $result = $stm->execute([':id' => $user['id']]);

            // End match for the opponent.
            if ($user['opponent_id'] === null) {
                $a = [
                    'state' => 0,
                    'opponent_id' => null
                ];
                $sql = "
                    UPDATE users
                    SET " . Misc::arrayToUpdateQuery($a) . "
                    WHERE id = :id
                ";
                $stm = $db->conn->prepare($sql);
                $result = $stm->execute([':id' => $user['opponent_id']]);

                $pushQueue = PushQueue::getInstance();
                $pushQueue->add('match-ended', []);
            }
        };

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
}