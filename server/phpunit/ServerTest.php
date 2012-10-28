<?
require_once 'RequestTestCase.php';
require_once __DIR__ . '/../src/Database.php';

/**
 * Simulate two users fighting each other. Server should be empty when testing so they will be matched with each other.
 */
class ServerTest extends RequestTestCase {
    function testLogin() {
        // Empty server.
        $db = Database::getInstance();
        $sql = "
            TRUNCATE users;
            TRUNCATE updates;
            TRUNCATE sessions;
        ";
        $result = $db->conn->exec($sql);

        // Initialize player variables.
        $t1 = [];
        $t2 = [];

        // Login t1.
        $response = $this->postRequest('login', [
            'username' => 'test1',
            'long' => 20.5,
            'lat' => 10.5
        ]);
        $this->assertTrue($response['success'] === true);
        $t1['token'] = $response['token'];

        // Get updates for t1. Should be empty.
        $response = $this->postRequest('get-updates', [
            'token' => $t1['token']
        ]);
        $this->assertTrue($response['success'] === true);
        $this->assertTrue(count($response['updates']) === 0);

        // Login t2.
        $response = $this->postRequest('login', [
            'username' => 'test2',
            'long' => 21,
            'lat' => 15
        ]);
        $this->assertTrue($response['success'] === true);
        $t2['token'] = $response['token'];

        // Get updates for t2.
        // t2 should now be matched with t1 and it should be t1's turn (t1 connected first).
        $response = $this->postRequest('get-updates', [
            'token' => $t2['token']
        ]);
        $this->assertTrue($response['success'] === true);
        $this->assertTrue(count($response['updates']) === 1);
        $this->assertTrue($response['updates'][0]['action'] === 'found-match');
    }
}