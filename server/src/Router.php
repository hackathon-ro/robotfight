<?
class Router {
    private $map = [
        'login' => 'LoginPage',
        'fire' => 'FirePage',
        'get-updates' => 'GetUpdatesPage'
    ];

    public function route($class) {
        if ($class != '' && array_key_exists($class, $this->map)) {
            $page = new $this->map[$class];
            $page->run();
            $page->echoResult();
        }
        else {
            header('HTTP/1.0 404 Not Found');
        }
    }
}