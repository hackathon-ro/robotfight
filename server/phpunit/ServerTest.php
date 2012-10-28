<?
require_once 'RequestTestCase.php';

class ServerTest extends RequestTestCase {
    function testLogin() {
        // Login and get updates.
        $response = $this->postRequest('login', [
            'username' => 'test',
            'long' => 20.5,
            'lat' => 10.5
        ]);
        $this->assertTrue($response['success'] === true);

        $token = $response['token'];

        $response = $this->postRequest('get-updates', [
            'token' => $token
        ]);
        $this->assertTrue($response['success'] === true);
    }
}