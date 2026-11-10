<?php
class Database {
    private $conn;

    public function getConnectionSettings() {
        $environment = strtolower(getenv('APP_ENV') ?: 'development');
        $host = getenv('DB_HOST') ?: 'localhost';
        $port = getenv('DB_PORT') ?: '3306';
        $database = getenv('DB_NAME') ?: 'swift_invoice_db';
        $username = getenv('DB_USER');
        $password = getenv('DB_PASSWORD');

        if ($username === false || $username === '') {
            if ($environment === 'production') {
                throw new RuntimeException('DB_USER debe configurarse en producción.');
            }
            $username = 'root';
        }

        if ($password === false || $password === '') {
            if ($environment === 'production') {
                throw new RuntimeException('DB_PASSWORD debe configurarse en producción.');
            }
            $password = '';
        }

        return [
            'host' => $host,
            'port' => $port,
            'database' => $database,
            'username' => $username,
            'password' => $password
        ];
    }

    public function connect() {
        if ($this->conn instanceof PDO) {
            return $this->conn;
        }

        $settings = $this->getConnectionSettings();
        $dsn = sprintf(
            'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
            $settings['host'],
            $settings['port'],
            $settings['database']
        );

        $this->conn = new PDO($dsn, $settings['username'], $settings['password'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
            PDO::ATTR_STRINGIFY_FETCHES => false
        ]);

        return $this->conn;
    }
}
