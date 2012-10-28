<?
require_once 'RequestTestCase.php';
require_once __DIR__ . '/../src/Database.php';

/**
 * Simulate two users fighting each other. One user is simulated here. The other user is operated in iOS by a tester.
 */
class PairTest extends RequestTestCase {
    function testLogin() {
//        // Empty server.
//        $db = Database::getInstance();
//        $sql = "
//            TRUNCATE users;
//            TRUNCATE updates;
//            TRUNCATE sessions;
//        "; // Set disconnected state.
//            $a = [
//                'state' => UserStates::DISCONNECTED
//            ];
//        $result = $db->conn->exec($sql);
//
//        // Initialize player variables.
//        $t1 = [
//            'x' => 2,
//            'y' => 1
//        ];
//
//        // Login t1.
//        $response = $this->postRequest('login', [
//            'username' => 'test1',
//            'lat' => $t1['x'],
//            'long' => $t1['y']
//        ]);
//        $this->assertTrue($response['success'] === true);
//        $t1['token'] = $response['token'];
//
//        // Fire
//        $maxError = 0.0001;
//        $response = $this->postRequest('fire', [
//            'token' => $t1['token'],
//            'angle' => 63.4349488,
//            'power' => 0.5
//        ]);
//        $this->assertTrue($response['success'] === true);
    }
}