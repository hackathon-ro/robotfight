<?
class PushQueue {
    private static $instance;

    public function add($userId, $data) {
//        var_dump($data);
        $db = Database::getInstance();

        $a = [
            'user_id' => ':user_id',
            'data' => ':data'
        ];
        $sql = "
            INSERT INTO updates " . Misc::arrayToInsertQuery($a) . "
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([
            ':user_id' => $userId,
            ':data' => json_encode($data)
        ]);
    }

    public static function getInstance() {
        // Include APNS library
//        require_once '../lib/ApnsPHP/Autoload.php';

        if (self::$instance === null) {
            self::$instance = new PushQueue();
        }
        return self::$instance;
    }
}