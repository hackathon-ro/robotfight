<?
class FirePage extends Page {
    public function run() {
        if (
            !array_key_exists('token', $this->data) ||
            !array_key_exists('angle', $this->data) ||
            !array_key_exists('power', $this->data)
        ) {
            return;
        }

        $db = Database::getInstance();

        // Check the token and if it's the user's turn to fire.
        $sql = "
            SELECT
                users.id,
                users.opponent_id,
                users.lat,
                users.long,
                opponent.hp,
                opponent.lat AS opponent_lat,
                opponent.long AS opponent_long
            FROM sessions
            JOIN users ON (users.id = sessions.user_id)
            JOIN users AS opponent ON (opponent.id = users.opponent_id)
            WHERE
                token = :token AND
                users.state = " . UserStates::PLAYER_TURN . "
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([
            ':token' => $this->data['token']
        ]);
        if ($stm->rowCount() === 0) {
            return;
        }
        $user = $stm->fetch();

        $maxDistanceError = 1;
        $distance = Misc::distance($user['lat'], $user['long'], $user['opponent_lat'], $user['opponent_long']);
        $finalDistance = $distance + $maxDistanceError * ($this->data['power'] - 0.5);
        $x = $user['lat'] + cos(deg2rad($this->data['angle'])) * $finalDistance;
        $y = $user['long'] + sin(deg2rad($this->data['angle'])) * $finalDistance;

        // Damage taken depends on distance from target.
        $maxDamage = 50;
        $maxDistance = 1;
        $dmg = max(0, $maxDamage * ($maxDistance - Misc::distance($x, $y, $user['opponent_lat'], $user['opponent_long'])));
        $hp = max(0, round($user['hp'] - $dmg));

        // Still alive?
        if ($hp > 0) {
            // Update opponent's hp and state.
            $a = [
                'hp' => ':hp',
                'state' => UserStates::PLAYER_TURN
            ];
            $sql = "
                UPDATE users
                SET " . Misc::arrayToUpdateQuery($a) . "
                WHERE
                    id = :id
            ";
            $stm = $db->conn->prepare($sql);
            $result = $stm->execute([
                ':hp' => $hp,
                ':id' => $user['opponent_id']
            ]);

            // Update current player's state.
            $a = [
                'state' => UserStates::OPPONENT_TURN
            ];
            $sql = "
                UPDATE users
                SET " . Misc::arrayToUpdateQuery($a) . "
                WHERE
                    id = :id
            ";
            $stm = $db->conn->prepare($sql);
            $result = $stm->execute([
                ':id' => $user['id']
            ]);
        }
        else {
            // Update opponent.
            $a = [
                'losses' => 'losses + 1',
                'state' => UserStates::DISCONNECTED
            ];
            $sql = "
                UPDATE users
                SET " . Misc::arrayToUpdateQuery($a) . "
                WHERE
                    id = :id
            ";
            $stm = $db->conn->prepare($sql);
            $result = $stm->execute([
                ':id' => $user['opponent_id']
            ]);

            // Update current player.
            $a = [
                'wins' => 'wins + 1',
                'state' => UserStates::DISCONNECTED
            ];
            $sql = "
                UPDATE users
                SET " . Misc::arrayToUpdateQuery($a) . "
                WHERE
                    id = :id
            ";
            $stm = $db->conn->prepare($sql);
            $result = $stm->execute([
                ':id' => $user['id']
            ]);
        }

        // Send notification to opponent.
        $pushQueue = PushQueue::getInstance();
        $pushQueue->add($user['opponent_id'], [
            'action' => 'hit',
            'data' => [
                'lat' => $x,
                'long' => $y,
                'hp' => $hp
            ]
        ]);

        // Send result to current player.
        $this->result = [
            'success' => true,
            'lat' => $x,
            'long' => $y,
            'hp' => $hp
        ];
    }
}