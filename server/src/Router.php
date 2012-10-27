<?
class Router {
    private $map = [
        'login' => 'Login'
    ];

    public function route($class) {
        if (array_key_exists($class, $this->map)) {
            $page = new $this->map[$class];
            $page->run();
            $page->echoResult();
        }
        else {
            header('HTTP/1.0 404 Not Found');
        }
    }
}