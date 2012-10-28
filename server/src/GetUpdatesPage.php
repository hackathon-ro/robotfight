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

        // Get updates.
        $a = [
            'user_id' => ':user_id',
            'data' => ':data'
        ];
        $sql = "
            SELECT
                data
            FROM updates
            WHERE user_id = :user_id
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([
            ':user_id' => $user['user_id']
        ]);
        $updates = [];
        while ($row = $stm->fetch()) {
            $updates[] = $row['data'];
        }
        $this->result = $updates;
    }
}