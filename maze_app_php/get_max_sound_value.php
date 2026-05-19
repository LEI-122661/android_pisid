<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);
header('Content-Type: application/json');

$response = array('success' => false, 'message' => '', 'data' => null);

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

$sql = "SELECT LimiteRuido FROM Simulacao WHERE Estado = 'A_DECORRER' ORDER BY IDSimulacao DESC LIMIT 1";
$result = $conn->query($sql);

if ($result && $row = $result->fetch_assoc()) {
    $response['success'] = true;
    $response['data'] = array(
        "maximo" => (float)$row['LimiteRuido']
    );
} else {
    $sqlFallback = "SELECT LimiteRuido FROM Simulacao ORDER BY IDSimulacao DESC LIMIT 1";
    $resFallback = $conn->query($sqlFallback);
    if ($resFallback && $row = $resFallback->fetch_assoc()) {
        $response['success'] = true;
        $response['data'] = array("maximo" => (float)$row['LimiteRuido']);
    } else {
        $response['success'] = true;
        $response['data'] = array("maximo" => 70.0);
    }
}

$conn->close();
echo json_encode($response);
?>
