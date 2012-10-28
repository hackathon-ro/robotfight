<?
require_once 'RequestTestCase.php';
require_once __DIR__ . '/../src/Database.php';

/**
 * Simulate two users fighting each other. Server should be empty when testing so they will be matched with each other.
 */
class FullGameTest extends RequestTestCase {
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

        // Get updates for t1. Should be empty. He's the only guy on the server.
        $response = $this->postRequest('get-updates', [
            'token' => $t1['token']
        ]);
        $this->assertTrue($response['success'] === true);
        $this->assertTrue(count($response['updates']) === 0);

        // Login t2.
        $response = $this->postRequest('login', [
            'username' => 'test2',
            'lat' => $t2['x'],
            'long' => $t2['y']
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
        $this->assertTrue($response['updates'][0]['data']['username'] === 'test1');
        $this->assertTrue($response['updates'][0]['data']['your-turn'] === false);

        // Get updates for t1. Should be matched with t2.
        $response = $this->postRequest('get-updates', [
            'token' => $t1['token']
        ]);
        $this->assertTrue($response['success'] === true);
        $this->assertTrue(count($response['updates']) === 1);
        $this->assertTrue($response['updates'][0]['action'] === 'found-match');
        $this->assertTrue($response['updates'][0]['data']['username'] === 'test2');
        $this->assertTrue($response['updates'][0]['data']['your-turn'] === true);

        // Simulate that t1 hits t2 with exact precision.
        $maxError = 0.0001;
        $response = $this->postRequest('fire', [
            'token' => $t1['token'],
            'angle' => 63.4349488,
            'power' => 0.5
        ]);
        $this->assertTrue($response['success'] === true);
        $this->assertTrue(abs($response['lat'] - $t2['x']) < $maxError);
        $this->assertTrue(abs($response['long'] - $t2['y']) < $maxError);

        // Get updates for t2.
        $response = $this->postRequest('get-updates', [
            'token' => $t2['token']
        ]);
        $this->assertTrue($response['success'] === true);
        $this->assertTrue(count($response['updates']) === 1);
        $this->assertTrue($response['updates'][0]['action'] === 'hit');

        // Simulate that t1 tries to hit again, although it isn't his turn.
        $response = $this->postRequest('fire', [
            'token' => $t1['token'],
            'angle' => 10,
            'power' => 0.1
        ]);
        $this->assertTrue($response['success'] === false);

        // Simulate that t2 hits t1 with awful precision.
        $minError = 1;
        $response = $this->postRequest('fire', [
            'token' => $t2['token'],
            'angle' => 50,
            'power' => 0.1
        ]);
        $this->assertTrue($response['success'] === true);
        $this->assertTrue(abs($response['lat'] - $t2['x']) > $minError);
        $this->assertTrue(abs($response['long'] - $t2['y']) > $minError);

        // Simulate that t2 tries to hit again, although it isn't his turn.
        $response = $this->postRequest('fire', [
            'token' => $t2['token'],
            'angle' => 10,
            'power' => 0.1
        ]);
        $this->assertTrue($response['success'] === false);

        // Simulate that t1 hits t2 with exact precision and kills him.
        $maxError = 0.0001;
        $response = $this->postRequest('fire', [
            'token' => $t1['token'],
            'angle' => 63.4349488,
            'power' => 0.5
        ]);
        $this->assertTrue($response['success'] === true);
        $this->assertTrue(abs($response['lat'] - $t2['x']) < $maxError);
        $this->assertTrue(abs($response['long'] - $t2['y']) < $maxError);
    }
}