<?
class Database {
    private static $instance = null;

    public $conn;

    public function __construct() {
        //$this->conn = pg_connect("host=localhost port=5432 dbname=hackathon user=postgres password=boss");
        $this->conn = new PDO('pgsql:dbname=hackathon;host=localhost;port=5432', 'postgres', 'boss');
    }

//    public function __destruct() {
//        pg_close($this->conn);
//    }

    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new Database();
        }
        return self::$instance;
    }
}