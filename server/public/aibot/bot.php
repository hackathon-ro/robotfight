<?
set_time_limit(999999999);

while (true) {
    // Login.
    $response = $this->postRequest('login', [
        'username' => 'aibot',
        'lat' => rand(40, 60),
        'long' => rand(40, 60)
    ]);
    $token = $response['token'];

    while (true) {
        // Wait for match
        $response = $this->postRequest('get-updates', [
            'token' => $token
        ]);
        foreach ($response['updates'] as $r) {
            switch ($r['action']) {
                case 'found-match':
                    break;

                case 'match-ended':
                    break 3;
                    break;

            }
        }
        usleep(0.5);
    }

    usleep(0.5);
}

function postRequest($action, $data) {
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