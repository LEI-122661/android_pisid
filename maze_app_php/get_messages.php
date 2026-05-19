<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);
header('Content-Type: application/json');

$response = array('success' => false, 'message' => '', 'data' => array());

$username = $_REQUEST['username'] ?? '';
$password = $_REQUEST['password'] ?? '';
$database = $_REQUEST['database'] ?? '';

if (empty($username) || empty($password) || empty($database)) {
    $response['message'] = 'Preencha todos os campos.';
    echo json_encode($response);
    exit;
}

$host = '127.0.0.1';
$db_user = 'root';
$db_pass = '';

$conn = new mysqli($host, $db_user, $db_pass, $database);

if ($conn->connect_error) {
    $response['message'] = "Erro de conexão: " . $conn->connect_error;
    echo json_encode($response);
    exit;
}

$conn->set_charset("utf8mb4");

$sql = "SELECT IDAlerta as ID, IDSimulacao, Sensor, TipoAlerta, Valor, DataAlerta, Descricao FROM Alerta ORDER BY IDAlerta DESC LIMIT 50";
$result = $conn->query($sql);

if ($result) {
    $alerts = array();
    while ($row = $result->fetch_assoc()) {
        $row['ID'] = (int)$row['ID'];
        $row['IDSimulacao'] = (int)$row['IDSimulacao'];
        $row['Valor'] = $row['Valor'] !== null ? (float)$row['Valor'] : null;
        $alerts[] = $row;
    }
    $response['success'] = true;
    $response['data'] = $alerts;
} else {
    $response['message'] = 'Erro na consulta de alertas: ' . $conn->error;
}

$conn->close();
echo json_encode($response);
?>
