<?
require_once 'RequestTestCase.php';
require_once __DIR__ . '/../src/Database.php';

/**
 * Simulate two users fighting each other. Server should be empty when testing so they will be matched with each other.
 * There will be many disconnects and reconnects in the middle of the game.
 */
class DisconnectsTest extends RequestTestCase {
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
        $t1 = [
            'x' => 2,
            'y' => 1
        ];
        $t2 = [
            'x' => 3,
            'y' => 3
        ];

        // Login t1.
        $response = $this->postRequest('login', [
            'username' => 'test1',
            'lat' => $t1['x'],
            'long' => $t1['y']
        ]);
        $this->assertTrue($response['success'] === true);
        $t1['token'] = $response['token'];

        // Login t2.
        $response = $this->postRequest('login', [
            'username' => 'test2',
            'lat' => $t2['x'],
            'long' => $t2['y']
        ]);
        $this->assertTrue($response['success'] === true);
        $t2['token'] = $response['token'];

        // Login t1. Again. Simulate a disconnect followed by a reconnect.
        $response = $this->postRequest('login', [
            'username' => 'test1',
            'lat' => $t1['x'],
            'long' => $t1['y']
        ]);
        $this->assertTrue($response['success'] === true);
        $t1['token'] = $response['token'];

        // Get updates for t1. Shouldn't be matched with anyone.
        $response = $this->postRequest('get-updates', [
            'token' => $t1['token']
        ]);
        $this->assertTrue($response['success'] === true);
        $this->assertTrue(count($response['updates']) === 0);
    }
}