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
    $response['message'] = "Erro de conexão: " . $conn->connect_error;
    echo json_encode($response);
    exit;
}

$conn->set_charset("utf8mb4");

$sql = "SELECT IDSom, IDMensagem, Hora, Som FROM Som ORDER BY IDSom DESC LIMIT 50";
$result = $conn->query($sql);

if ($result) {
    $data = array();
    while ($row = $result->fetch_assoc()) {
        $row['IDSom'] = (int)$row['IDSom'];
        $row['IDMensagem'] = $row['IDMensagem'] !== null ? (int)$row['IDMensagem'] : null;
        $row['Som'] = (float)$row['Som'];
        $data[] = $row;
    }
    $response['success'] = true;
    $response['data'] = array_reverse($data);
} else {
    $response['message'] = 'Erro: ' . $conn->error;
}

$conn->close();
echo json_encode($response);
?>
