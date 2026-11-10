<?php

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/mongodb.php';

function mysqlOptionFileValue(string $value): string
{
    $escaped = str_replace(
        ["\\", '"', "\n", "\r"],
        ["\\\\", '\\"', '\\n', '\\r'],
        $value
    );

    return '"' . $escaped . '"';
}

function createMySqlDump(array $settings): string
{
    $configPath = tempnam(sys_get_temp_dir(), 'swift-mysql-');
    if ($configPath === false) {
        throw new RuntimeException('No se pudo crear el archivo temporal de credenciales.');
    }

    $dumpPath = tempnam(sys_get_temp_dir(), 'swift-dump-');
    if ($dumpPath === false) {
        unlink($configPath);
        throw new RuntimeException('No se pudo crear el archivo temporal del respaldo.');
    }

    $errorPath = tempnam(sys_get_temp_dir(), 'swift-error-');
    if ($errorPath === false) {
        unlink($configPath);
        unlink($dumpPath);
        throw new RuntimeException('No se pudo crear el archivo temporal de errores.');
    }

    try {
        $configContents = "[client]\n"
            . 'user=' . mysqlOptionFileValue($settings['username']) . "\n"
            . 'password=' . mysqlOptionFileValue($settings['password']) . "\n";

        if (file_put_contents($configPath, $configContents, LOCK_EX) === false) {
            throw new RuntimeException('No se pudo escribir la configuración temporal de MySQL.');
        }

        @chmod($configPath, 0600);

        $dumpBinary = getenv('MYSQLDUMP_BIN');
        if ($dumpBinary === false || $dumpBinary === '') {
            $xamppDumpBinary = dirname(__DIR__, 3)
                . DIRECTORY_SEPARATOR . 'mysql'
                . DIRECTORY_SEPARATOR . 'bin'
                . DIRECTORY_SEPARATOR . 'mysqldump.exe';
            $dumpBinary = is_file($xamppDumpBinary) ? $xamppDumpBinary : 'mysqldump';
        }

        $command = [
            $dumpBinary,
            '--defaults-extra-file=' . $configPath,
            '--host=' . $settings['host'],
            '--port=' . $settings['port'],
            '--single-transaction',
            '--quick',
            '--routines',
            '--triggers',
            '--events',
            '--hex-blob',
            '--default-character-set=utf8mb4',
            '--databases',
            $settings['database']
        ];

        $process = proc_open($command, [
            0 => ['file', 'NUL', 'r'],
            1 => ['file', $dumpPath, 'wb'],
            2 => ['file', $errorPath, 'wb']
        ], $pipes);

        if (!is_resource($process)) {
            throw new RuntimeException('No se pudo iniciar mysqldump. Configura MYSQLDUMP_BIN con la ruta del ejecutable.');
        }

        $exitCode = proc_close($process);
        if ($exitCode !== 0) {
            $details = trim((string) file_get_contents($errorPath));
            throw new RuntimeException(
                'mysqldump terminó con código ' . $exitCode
                . ($details !== '' ? ': ' . $details : '. Verifica MYSQLDUMP_BIN y los permisos de MySQL.')
            );
        }

        return $dumpPath;
    } catch (Throwable $exception) {
        if (is_file($dumpPath)) {
            unlink($dumpPath);
        }
        throw $exception;
    } finally {
        if (is_file($configPath)) {
            unlink($configPath);
        }
        if (is_file($errorPath)) {
            unlink($errorPath);
        }
    }
}

try {
    $database = new Database();
    $settings = $database->getConnectionSettings();
    $dumpPath = createMySqlDump($settings);

    try {
        $dumpStream = fopen($dumpPath, 'rb');
        if ($dumpStream === false) {
            throw new RuntimeException('No se pudo leer el archivo de respaldo generado.');
        }

        $bucketName = getenv('MONGODB_BACKUP_BUCKET') ?: 'database_backups';
        $bucket = getMongoDatabase()->selectGridFSBucket(['bucketName' => $bucketName]);
        $filename = $settings['database'] . '_' . gmdate('Ymd_His') . '.sql';
        $fileId = $bucket->uploadFromStream($filename, $dumpStream, [
            'metadata' => [
                'source_database' => $settings['database'],
                'backup_format' => 'mysqldump',
                'includes' => ['schema', 'data', 'routines', 'triggers', 'events'],
                'created_at' => new MongoDB\BSON\UTCDateTime()
            ]
        ]);

        fclose($dumpStream);
        echo 'Respaldo completo guardado en MongoDB GridFS. Archivo: '
            . $filename . '; ID: ' . (string) $fileId . PHP_EOL;
    } finally {
        if (isset($dumpStream) && is_resource($dumpStream)) {
            fclose($dumpStream);
        }
        if (is_file($dumpPath)) {
            unlink($dumpPath);
        }
    }
} catch (Throwable $exception) {
    fwrite(STDERR, 'Error al crear el respaldo: ' . $exception->getMessage() . PHP_EOL);
    exit(1);
}
