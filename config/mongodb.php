<?php

require_once __DIR__ . '/../vendor/autoload.php';

function getMongoDatabase(): MongoDB\Database
{
    static $database = null;

    if ($database instanceof MongoDB\Database) {
        return $database;
    }

    // Carga manual del archivo .env si existe en la raíz
    $envFile = __DIR__ . '/../.env';
    if (file_exists($envFile)) {
        $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            if (strpos(trim($line), '#') === 0) continue;
            list($name, $value) = explode('=', $line, 2);
            $name = trim($name);
            $value = trim($value, " \"'");
            if (!array_key_exists($name, $_ENV)) {
                $_ENV[$name] = $value;
                putenv("$name=$value");
            }
        }
    }

    $mongoUri = getenv('MONGODB_URI');
    if ($mongoUri === false || $mongoUri === '') {
        throw new RuntimeException('MONGODB_URI debe configurarse.');
    }

    $databaseName = getenv('MONGODB_DATABASE') ?: 'swift_invoice';
    $client = new MongoDB\Client($mongoUri);
    $database = $client->selectDatabase($databaseName);

    return $database;
}
