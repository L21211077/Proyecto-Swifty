<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once '../../config/database.php';

header('Content-Type: application/json');

$db = new Database();
$conn = $db->connect();

$tipo = $_GET['tipo'] ?? '';
$valor = $_GET['valor'] ?? '';

try {

    $stmt = $conn->prepare("CALL sp_buscar_facturas(?, ?)");

    $stmt->execute([$tipo, $valor]);

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $stmt->closeCursor();

    echo json_encode($results);

} catch (PDOException $e) {

    echo json_encode([
        'error' => $e->getMessage()
    ]);
}