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
                user_id
            FROM sessions
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

//        var_dump($user);

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
        if ($this->data['token'] == '74MdYwtfh7ng8Hxd3y2WM8CU') {
            $updates[] = json_decode('{"action":"match-found","data":{"username":"gigi","lat":10,"long":10,"your-turn":true}}');
            $updates[] = json_decode('{"action":"hit","data":{"lat": "11", "long": "12", "hp": "50"}}');
        }

        while ($row = $stm->fetch()) {
            $updates[] = json_decode($row['data']);
        }
        $this->result = [
            'success' => true,
            'updates' => $updates
        ];
    }
}