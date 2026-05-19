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

// 1. Definimos o valor máximo absoluto assumido para ruído como 70
$valorReferenciaRuido = 70.0;

// 2. Pegar o limite (percentagem) da simulação ativa
$sql = "SELECT LimiteRuido FROM Simulacao WHERE Estado = 'A_DECORRER' ORDER BY IDSimulacao DESC LIMIT 1";
$result = $conn->query($sql);

$percentagem = 70.0; // Valor default de segurança se não houver simulação

if ($result && $row = $result->fetch_assoc()) {
    $percentagem = (float)$row['LimiteRuido'];
} else {
    // Tenta fallback para a última simulação criada
    $sqlFallback = "SELECT LimiteRuido FROM Simulacao ORDER BY IDSimulacao DESC LIMIT 1";
    $resFallback = $conn->query($sqlFallback);
    if ($resFallback && $row = $resFallback->fetch_assoc()) {
        $percentagem = (float)$row['LimiteRuido'];
    }
}

// 3. O valor da linha vermelha no Android será a percentagem aplicada aos 70.0
$valorSeguranca = ($percentagem / 100) * $valorReferenciaRuido;

$response['success'] = true;
$response['data'] = array(
    "maximo" => round($valorSeguranca, 2)
);

$conn->close();
echo json_encode($response);
?>
