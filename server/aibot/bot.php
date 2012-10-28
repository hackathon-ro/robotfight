<?
// Usage: php -f bot.php BOTNAME HOSTNAME

date_default_timezone_set('Europe/Bucharest');
set_time_limit(999999);

global $name, $token;
$name = $argv[1];
$token = '';

while (true) {
    mylog('I`m logging in.');

    // login.
    $response = postRequest('login', [
        'username' => $name,
        'lat' => rand(40, 60),
        'long' => rand(40, 60)
    ]);
    $token = $response['token'];

    while (true) {
        // Wait for match
        $response = postRequest('get-updates', [
            'token' => $token
        ]);
        if ($response === false) {
            break 1;
        }
        foreach ($response['updates'] as $r) {
            switch ($r['action']) {
                case 'found-match':
                    mylog('Match found! My nemesis: ' . $r['data']['username']);
                    if ($r['data']['your-turn'] === true) {
                        $response = fire();
                        if ($response['hp'] == 0) {
                            break 3;
                        }
                    }
                    break;

                case 'hit':
                    mylog('I`ve been hit, Hp left: ' . $r['data']['hp']);
                    if ($r['data']['hp'] == 0) {
                        mylog('I died. :(');
                        break 3;
                    }
                    $response = fire();
                    if ($response['hp'] == 0) {
                        break 3;
                    }
                    break;

                case 'match-ended':
                    mylog('Match ended prematurely.');
                    break 3;
                    break;

            }
        }
//        break;
        usleep(01.95);
    }
//    break;
    usleep(01.95);
}

function fire() {
    global $name, $token;
    mylog('I`m firing!');
    $response = postRequest('fire',  [
        'token' => $token,
        'power' => rand(0, 1000) / 1000,
        'angle' => round(rand(0, 359))
    ]);
    mylog('I`ve left him with hp: ' . $response['hp']);
    if ($response['hp'] === 0) {
        mylog('I`ve won!');
    }
    return $response;
}

function mylog($s) {
    echo '[ ' . date('H:i:s') . ' ] ';
    echo $s . "\n";
    flush();
}

function postRequest($action, $data) {
	global $argv;
	
    // Build URL.
    $get = [];
    foreach ($data as $key => $value) {
        $get[] = $key . '=' . $value;
    }
    $get = implode('&', $get);
    $url = 'http://' . $argv[2] . '/' . $action . '?' . $get;

    // Get and parse result.
    $response = file_get_contents($url);
    if ($action == 'get-updates' && $response == '{"success":true,"updates":[]}') {

    }
    else {
        mylog('URL Request: ' . $url);
        mylog('Response: ' . $response);
    }
    $response = json_decode($response, true);

    return $response;
}