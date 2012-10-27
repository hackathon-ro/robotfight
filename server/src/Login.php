<?
class Login extends Page {
    public function run() {
        $db = Database::getInstance();

        // Get user.
        $sql = "
            SELECT
                id,
                username,
                wins,
                losses
            FROM users
            WHERE
                lower(username) = :username
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([':username' => $this->data['username']]);

        // Create user if he doesn't already exist.
        if ($stm->rowCount() === 0) {
            $a = [
                'username' => ':username'
            ];
            $sql = "
                INSERT INTO users " . Misc::arrayToInsertQuery($a) . "
                RETURNING
                    id,
                    username,
                    wins,
                    losses
            ";
            $stm = $db->conn->prepare($sql);
            $result = $stm->execute([':username' => $this->data['username']]);
        }

        // Get user data.
        $user = $stm->fetch();

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
            ':token' => $this->generateToken()
        ]);
        $token = $this->generateToken();

        // Return data.
        $this->result = [
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