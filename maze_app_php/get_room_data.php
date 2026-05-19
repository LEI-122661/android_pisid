<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);
header('Content-Type: application/json');

$response = array('success' => false, 'message' => '', 'data' => array());

$username = $_REQUEST['username'] ?? '';
$password = $_REQUEST['password'] ?? '';
$database = $_REQUEST['database'] ?? '';

$host = '127.0.0.1';
$db_user = 'root';
$db_pass = '';

$conn = new mysqli($host, $db_user, $db_pass, $database);

if ($conn->connect_error) {
    $response['message'] = "Erro: " . $conn->connect_error;
    echo json_encode($response);
    exit;
}

$conn->set_charset("utf8mb4");

$sql = "SELECT IDJogo, IDSimulacao, Sala, NumeroMarsamisOdd, NumeroMarsamisEven, GatilhosUsados FROM OcupacaoLabirinto ORDER BY Sala ASC";
$result = $conn->query($sql);

if ($result) {
    $rooms = array();
    while ($row = $result->fetch_assoc()) {
        $row['IDJogo'] = (int)$row['IDJogo'];
        $row['IDSimulacao'] = (int)$row['IDSimulacao'];
        $row['Sala'] = (int)$row['Sala'];
        $row['NumeroMarsamisOdd'] = (int)$row['NumeroMarsamisOdd'];
        $row['NumeroMarsamisEven'] = (int)$row['NumeroMarsamisEven'];
        $row['GatilhosUsados'] = (int)$row['GatilhosUsados'];
        $rooms[] = $row;
    }
    $response['success'] = true;
    $response['data'] = $rooms;
} else {
    $response['message'] = 'Erro: ' . $conn->error;
}

$conn->close();
echo json_encode($response);
?>
