<?php

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/export_users_to_mongodb.php';

$mysql = (new Database())->connect();
$snapshotId = exportUsersSnapshotToMongoDB($mysql);

echo 'Snapshot de usuarios creado: ' . $snapshotId . PHP_EOL;
