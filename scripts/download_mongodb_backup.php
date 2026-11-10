<?php

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require_once __DIR__ . '/../config/mongodb.php';

if ($argc !== 3 || !preg_match('/\A[0-9a-f]{24}\z/i', $argv[1])) {
    fwrite(STDERR, "Uso: php scripts/download_mongodb_backup.php <id-del-respaldo> <archivo-salida.sql>\n");
    exit(2);
}

try {
    $outputPath = $argv[2];
    if (file_exists($outputPath)) {
        throw new RuntimeException('El archivo de salida ya existe; elige otra ruta para evitar sobrescribirlo.');
    }

    $bucketName = getenv('MONGODB_BACKUP_BUCKET') ?: 'database_backups';
    $bucket = getMongoDatabase()->selectGridFSBucket(['bucketName' => $bucketName]);
    $source = $bucket->openDownloadStream(new MongoDB\BSON\ObjectId($argv[1]));
    $destination = fopen($outputPath, 'xb');

    if ($destination === false) {
        fclose($source);
        throw new RuntimeException('No se pudo crear el archivo de salida.');
    }

    try {
        if (stream_copy_to_stream($source, $destination) === false) {
            throw new RuntimeException('No se pudo descargar por completo el respaldo desde MongoDB.');
        }
    } catch (Throwable $exception) {
        fclose($source);
        fclose($destination);
        unlink($outputPath);
        throw $exception;
    }

    fclose($source);
    fclose($destination);

    echo 'Respaldo descargado en: ' . $outputPath . PHP_EOL;
} catch (Throwable $exception) {
    fwrite(STDERR, 'Error al descargar el respaldo: ' . $exception->getMessage() . PHP_EOL);
    exit(1);
}
