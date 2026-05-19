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
$db_pass = ''; // Ajuste conforme seu ambiente

$conn = new mysqli($host, $db_user, $db_pass, $database);

if ($conn->connect_error) {
    $response['message'] = "Erro de conexão: " . $conn->connect_error;
    echo json_encode($response);
    exit;
}

$conn->set_charset("utf8mb4");

$sql = "SELECT ID, IDSimulacao, Hora, Sala, Sensor, Leitura, Msg, HoraEscrita FROM Mensagem ORDER BY ID DESC LIMIT 50";
$result = $conn->query($sql);

if ($result) {
    $messages = array();
    while ($row = $result->fetch_assoc()) {
        // Converter tipos para garantir JSON correto
        $row['ID'] = (int)$row['ID'];
        $row['IDSimulacao'] = $row['IDSimulacao'] !== null ? (int)$row['IDSimulacao'] : null;
        $row['Sala'] = $row['Sala'] !== null ? (int)$row['Sala'] : null;
        $row['Leitura'] = $row['Leitura'] !== null ? (float)$row['Leitura'] : null;
        $messages[] = $row;
    }
    $response['success'] = true;
    $response['data'] = $messages;
} else {
    $response['message'] = 'Erro na consulta: ' . $conn->error;
}

$conn->close();
echo json_encode($response);
?>
