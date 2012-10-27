<?
abstract class Page {
    protected
        $data = null,
        $result = null;

    public function __construct() {
        $data = file_get_contents("php://input");
        $data = json_decode($data);
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