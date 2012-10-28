<?
require_once 'RequestTestCase.php';

class BogusRequestTest extends RequestTestCase {
    function testGetUpdates() {
        $response = $this->postRequest('get-updates', [
            'token' => '123'
        ]);
        $this->assertTrue($response['success'] === false);
    }
}