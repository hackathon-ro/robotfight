<?
abstract class Page {
    protected
        $data = null,
        $result = ['success' => false];

    public function __construct() {
        $data = file_get_contents("php://input");

        // Log request, for debugging purposes.
        $db = Database::getInstance();
        $a = [
            'text' => ':text'
        ];
        $sql = "
            INSERT INTO logs " . Misc::arrayToInsertQuery($a) . "
        ";
        $stm = $db->conn->prepare($sql);
        $result = $stm->execute([
            ':text' => $data
        ]);

        $data = json_decode($data, true);
        if ($data === null) {
            if (count($_POST) > 0) {
                $data = $_POST;
            }
            else {
                $data = $_GET;
            }
        }
        $this->data = $data;
    }

    public abstract function run();

    public function echoResult() {
        echo json_encode($this->result);
    }
}