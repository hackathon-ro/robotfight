<?
class GetUpdatesPage extends Page {
    public function run() {
        if (
            !array_key_exists('token', $this->data)
        ) {
            return;
        }

        $db = Database::getInstance();

        // Get user info from token.
        $sql = "
            SELECT
                user_id,
                users.opponent_id
            FROM sessions
            JOIN users ON (users.id = sessions.user_id)
            WHERE token = :token
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([
            ':token' => $this->data['token']
        ]);
        if ($stm->rowCount() === 0) {
            return;
        }
        $user = $stm->fetch();

        // Update user info.
        $sql = "
            UPDATE users
            SET
                last_ping = NOW()
            WHERE id = :id
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([
            ':id' => $user['user_id']
        ]);

//        var_dump($user);

        // Check if opponent timed out.
        $sql = "
            SELECT
                NULL
            FROM users
            WHERE
                id = :id AND
                last_ping < NOW() - INTERVAL '" . Misc::TIMEOUT . " seconds'
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([
            ':id' => $user['opponent_id']
        ]);
        if ($stm->rowCount() == 1) {
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

        // Get updates while removing them for the database.
        $a = [
            'user_id' => ':user_id',
            'data' => ':data'
        ];
        $sql = "
            DELETE FROM updates
            WHERE user_id = :user_id
            RETURNING
                data
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([
            ':user_id' => $user['user_id']
        ]);
        $updates = [];

        // Hardcoded debugging! So clean!
//        if ($this->data['token'] == '74MdYwtfh7ng8Hxd3y2WM8CU') {
//            $updates[] = json_decode('{"action":"match-found","data":{"username":"gigi","lat":10,"long":10,"your-turn":false}}');
//            $updates[] = json_decode('{"action":"hit","data":{"lat": "11", "long": "12", "hp": "25"}}');
//        }

        while ($row = $stm->fetch()) {
            $updates[] = json_decode($row['data']);
        }
        $this->result = [
            'success' => true,
            'updates' => $updates
        ];
    }
}