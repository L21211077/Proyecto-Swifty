<?php
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../vendor/autoload.php';

// Cargar variables desde tu archivo .env si existen
$envPath = __DIR__ . '/../.env';
if (file_exists($envPath)) {
    foreach (file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (strpos(trim($line), '#') === 0 || !strpos($line, '=')) continue;
        list($k, $v) = explode('=', $line, 2);
        $_ENV[trim($k)] = trim($v, " \t\n\r\0\x0B\"'");
    }
}

$action = $_GET['action'] ?? 'report';

// 1. Conexión independiente a Fuente A (MariaDB / MySQL Local)
$dbHost = $_ENV['DB_HOST'] ?? '127.0.0.1';
$dbName = $_ENV['DB_NAME'] ?? 'swift_invoice_db';
$dbUser = $_ENV['DB_USER'] ?? 'root';
$dbPass = $_ENV['DB_PASS'] ?? '';

try {
    $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4", $dbUser, $dbPass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["error" => "Error en Fuente A (MariaDB): " . $e->getMessage()]);
    exit;
}

// 2. Conexión independiente a Fuente B (MongoDB Atlas)
$mongoOnline = true;
$collection = null;
$mongoError = null;

$mongoUri = $_ENV['MONGODB_URI'] ?? $_ENV['MONGO_URI'] ?? "mongodb+srv://l21211077_db_user:h2x8I0tIXRwhQC6l@cluster0.qebbyge.mongodb.net/?retryWrites=true&w=majority";
$mongoDbName = $_ENV['MONGODB_DATABASE'] ?? 'swift_invoice';
$mongoColName = $_ENV['MONGODB_COLLECTION'] ?? 'user_snapshots';

try {
    // tlsAllowInvalidCertificates evita bloqueos SSL comunes de XAMPP en Windows
    $mongoClient = new MongoDB\Client($mongoUri, ['tlsAllowInvalidCertificates' => true]);
    $mongoClient->selectDatabase($mongoDbName)->command(['ping' => 1]);
    $collection = $mongoClient->selectDatabase($mongoDbName)->selectCollection($mongoColName);
} catch (Throwable $e) {
    $mongoOnline = false;
    $mongoError = $e->getMessage();
}

// ACCIÓN 1: CONSULTA GLOBAL INTEGRADA
if ($action === 'report') {
    $stmt = $pdo->query("SELECT id, username, first_name, last_name, phone, email FROM users");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $snapshotsMap = [];
    if ($mongoOnline && $collection) {
        $cursor = $collection->find([]);
        foreach ($cursor as $doc) {
            $fechaExp = isset($doc['exported_at']) ? (string)$doc['exported_at'] : 'Sin fecha';
            if (isset($doc['users'])) {
                foreach ($doc['users'] as $snapUser) {
                    $uidSnap = (int)$snapUser['id'];
                    $snapshotsMap[$uidSnap] = [
                        'snapshot_id' => (string)$doc['_id'],
                        'fecha_snapshot_utc' => $fechaExp,
                        'telefono_en_snapshot' => $snapUser['phone'] ?? null,
                        'correo_en_snapshot' => $snapUser['email'] ?? null
                    ];
                }
            }
        }
    }

    $resultado = [];
    foreach ($users as $u) {
        $uid = (int)$u['id'];
        $fila = [
            'user_id' => $uid,
            'usuario' => $u['username'],
            'nombre_completo' => trim($u['first_name'] . ' ' . $u['last_name']),
            'telefono_actual_mariadb' => $u['phone'],
            'correo_actual_mariadb' => $u['email']
        ];

        if ($mongoOnline && isset($snapshotsMap[$uid])) {
            $snap = $snapshotsMap[$uid];
            $fila['auditoria_mongodb'] = $snap;
            $fila['estado_sincronizacion'] = ($u['phone'] === $snap['telefono_en_snapshot'])
                ? 'SINCRONIZADO'
                : 'DESACTUALIZADO_EN_NUBE';
        } else {
            $fila['auditoria_mongodb'] = null;
            $fila['estado_sincronizacion'] = 'NO_VERIFICABLE_NODO_OFFLINE';
        }

        $resultado[] = $fila;
    }

    $responsePayload = [
        'fuente_a_mariadb' => 'ONLINE',
        'fuente_b_mongodb' => $mongoOnline ? 'ONLINE' : 'OFFLINE',
        'estado_integracion' => $mongoOnline ? 'COMPLETO' : 'DEGRADADO (Nodo MongoDB desconectado)',
        'datos' => $resultado
    ];

    if (!$mongoOnline && $mongoError) {
        $responsePayload['detalle_error_mongo'] = $mongoError;
    }

    http_response_code($mongoOnline ? 200 : 206);
    echo json_encode($responsePayload, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}

// ACCIÓN 2: ACTUALIZACIÓN Y MANEJO DE CAMBIOS INCOMPLETOS
elseif ($action === 'update') {
    $userId = 8;
    $nuevoTelefono = "6649998877";

    // Paso 1: Actualizar dato en Fuente A (MariaDB)
    $stmt = $pdo->prepare("UPDATE users SET phone = ? WHERE id = ?");
    $stmt->execute([$nuevoTelefono, $userId]);

    // Paso 2: Actualizar el elemento correspondiente en MongoDB Atlas
    if ($mongoOnline && $collection) {
        $collection->updateOne(
            ['source_table' => 'users', 'users.id' => $userId],
            ['$set' => [
                'users.$.phone' => $nuevoTelefono,
                'exported_at' => new MongoDB\BSON\UTCDateTime()
            ]]
        );

        echo json_encode([
            'status' => 'ACTUALIZADO_EN_AMBAS_FUENTES',
            'user_id' => $userId,
            'nuevo_telefono' => $nuevoTelefono
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    } else {
        $pdo->prepare("INSERT INTO audit_log (table_name, action_type, record_id, modified_by) VALUES ('users', 'UPDATE', ?, 'PENDIENTE_SNAPSHOT_MONGO')")
            ->execute([$userId]);

        http_response_code(202);
        echo json_encode([
            'status' => 'CAMBIO_INCOMPLETO_CONTROLADO',
            'mensaje' => 'Teléfono actualizado en MariaDB, pero MongoDB Atlas no respondió. Registrado en audit_log.'
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
}