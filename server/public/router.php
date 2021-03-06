<?
// Set timezone, necessary for Apple Push Notification Service
date_default_timezone_set('Europe/Bucharest');

// Set our autoloader.
spl_autoload_register(function ($class) {
    include '../src/' . $class . '.php';
});

// Get URL without the first "/" character.
$url = $_SERVER['REDIRECT_URL'];
$url = substr($url, 1);

// Run the requested page.
$r = new Router();
$r->route($url);