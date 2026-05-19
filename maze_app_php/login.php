<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);
header('Content-Type: application/json');

$response = array('success' => false, 'message' => '');

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
    $response['message'] = "Erro: " . $conn->connect_error;
    echo json_encode($response);
    exit;
}

$conn->set_charset("utf8mb4");

// O utilizador na tabela Utilizador tem a pass em SHA2-256 (64 chars)
$sql = "SELECT IDUtilizador, Password FROM Utilizador WHERE Email = ?";
$stmt = $conn->prepare($sql);

if ($stmt) {
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();

    if ($user) {
        $dbPassword = $user['Password'];
        $providedPasswordHash = hash('sha256', $password);

        if ($dbPassword === $providedPasswordHash || $dbPassword === $password) {
            $response['success'] = true;
            $response['IDUtilizador'] = (int)$user['IDUtilizador'];
            $response['message'] = 'Login bem-sucedido.';
        } else {
            $response['message'] = 'Password incorreta.';
        }
    } else {
        $response['message'] = 'Utilizador não encontrado.';
    }
    $stmt->close();
} else {
    $response['message'] = 'Erro na query.';
}

$conn->close();
echo json_encode($response);
?>
