<?
class RequestTestCase extends PHPUnit_Framework_TestCase {
    protected function postRequest($action, $data) {
        // Build URL.
        $get = [];
        foreach ($data as $key => $value) {
            $get[] = $key . '=' . $value;
        }
        $get = implode('&', $get);
        $url = 'http://localhost/' . $action . '?' . $get;

        // Get and parse result.
        $response = file_get_contents($url);
        print_r($url . "\n");
        print_r($response . "\n\n");
        $response = json_decode($response, true);

        // Assert that the response has been parsed successfully.
        $this->assertTrue($response !== null);

        return $response;
    }
}