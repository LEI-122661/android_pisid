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

// Pegar o limite da simulação mais recente a decorrer ou a última criada
$sql = "SELECT LimiteTemp FROM Simulacao WHERE Estado = 'A_DECORRER' OR Estado = 'PENDENTE' ORDER BY IDSimulacao DESC LIMIT 1";
$result = $conn->query($sql);

if ($result && $row = $result->fetch_assoc()) {
    $response['success'] = true;
    $response['data'] = array(
        "minimo" => 0.0,
        "maximo" => (float)$row['LimiteTemp']
    );
} else {
    $response['message'] = "Nenhum limite de temperatura definido.";
    // Valores default caso não haja simulações
    $response['success'] = true;
    $response['data'] = array("minimo" => 0.0, "maximo" => 30.0);
}

$conn->close();
echo json_encode($response);
?>
