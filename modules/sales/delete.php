<?php
require_once '../../config/setup.php';
requireAuth();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['id'])) {
    $saleId = (int) $_POST['id'];

    $db   = new Database();
    $conn = $db->connect();

    try {

    $usuario = $_SESSION['username'] ?? 'Sistema';

    $stmtAudit = $conn->prepare("
        INSERT INTO current_audit_user (username)
        VALUES (:username)
    ");

    $stmtAudit->bindParam(':username', $usuario);
    $stmtAudit->execute();
        
        // Iniciar transacción
        $conn->beginTransaction();

        // 1) Borrar detalles de la venta
        $delDetails = $conn->prepare("DELETE FROM sale_details WHERE sale_id = :id");
        $delDetails->bindParam(':id', $saleId, PDO::PARAM_INT);
        $delDetails->execute();

        // 2) Borrar la venta
        $delSale = $conn->prepare("DELETE FROM sales WHERE id = :id");
        $delSale->bindParam(':id', $saleId, PDO::PARAM_INT);
        $delSale->execute();

        // Confirmar cambios
        $conn->commit();
        $_SESSION['success_message'] = "Venta eliminada correctamente.";
    } catch (Exception $e) {
        // Revertir si algo falla
        $conn->rollBack();
        $_SESSION['error_message'] = "No se pudo eliminar la venta: " . $e->getMessage();
    }
}

header("Location: index.php");
exit;
