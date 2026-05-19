<?php
/*
 * ═════════════════════════════════════════════════════════════════════════
 * LOGIN DEBUG - Teste detalhado de todos os componentes
 * ═════════════════════════════════════════════════════════════════════════
 *
 * USE: http://192.168.1.14:8000/maze_app_php/debug_login.php
 *
 * Este script mostra:
 * 1. Parâmetros recebidos
 * 2. Conectividade MySQL
 * 3. Existência da base de dados
 * 4. Existência do utilizador
 * 5. Validação de password
 *
 * ═════════════════════════════════════════════════════════════════════════
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: application/json; charset=utf-8');

$debug = array(
    'timestamp' => date('Y-m-d H:i:s'),
    'php_version' => phpversion(),
    'mysqli_enabled' => extension_loaded('mysqli') ? true : false,
    'parameters' => array(),
    'mysql_connection' => array(),
    'database_check' => array(),
    'user_check' => array(),
    'password_check' => array(),
    'final_result' => array()
);

// ═════════════════════════════════════════════════════════════════════════
// PASSO 1: Parâmetros
// ═════════════════════════════════════════════════════════════════════════

$debug['parameters'] = array(
    'username' => $_REQUEST['username'] ?? '[NÃO ENVIADO]',
    'password' => $_REQUEST['password'] ?? '[NÃO ENVIADO]',
    'database' => $_REQUEST['database'] ?? '[NÃO ENVIADO]'
);

$username = $_REQUEST['username'] ?? '';
$password = $_REQUEST['password'] ?? '';
$database = $_REQUEST['database'] ?? '';

if (empty($username) || empty($password) || empty($database)) {
    $debug['final_result'] = array(
        'error' => 'PARÂMETROS INCOMPLETOS',
        'missing' => array(
            'username' => empty($username),
            'password' => empty($password),
            'database' => empty($database)
        )
    );
    echo json_encode($debug, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

// ═════════════════════════════════════════════════════════════════════════
// PASSO 2: Conectar ao MySQL
// ═════════════════════════════════════════════════════════════════════════

$host = '127.0.0.1';
$db_user = 'root';
$db_pass = 'root';

@$conn = new mysqli($host, $db_user, $db_pass, $database);

$debug['mysql_connection'] = array(
    'host' => $host,
    'port' => 3306,
    'user' => $db_user,
    'database' => $database,
    'connection_error' => $conn->connect_error ?: null
);

if ($conn->connect_error) {
    $debug['final_result'] = array(
        'error' => 'ERRO DE CONEXÃO MYSQL',
        'details' => $conn->connect_error
    );
    echo json_encode($debug, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

// ═════════════════════════════════════════════════════════════════════════
// PASSO 3: Verificar base de dados
// ═════════════════════════════════════════════════════════════════════════

$result = $conn->query("SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$database'");
$db_exists = $result && $result->num_rows > 0;

$debug['database_check'] = array(
    'database_name' => $database,
    'exists' => $db_exists,
    'query_error' => $conn->error ?: null
);

if (!$db_exists) {
    $debug['final_result'] = array(
        'error' => 'BASE DE DADOS NÃO ENCONTRADA',
        'database' => $database
    );
    echo json_encode($debug, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

// ═════════════════════════════════════════════════════════════════════════
// PASSO 4: Verificar tabela Utilizador
// ═════════════════════════════════════════════════════════════════════════

$result = $conn->query("SHOW TABLES LIKE 'Utilizador'");
$table_exists = $result && $result->num_rows > 0;

$debug['database_check']['table_exists'] = $table_exists;

if (!$table_exists) {
    $debug['final_result'] = array(
        'error' => 'TABELA UTILIZADOR NÃO ENCONTRADA',
        'database' => $database
    );
    echo json_encode($debug, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

// ═════════════════════════════════════════════════════════════════════════
// PASSO 5: Procurar utilizador
// ═════════════════════════════════════════════════════════════════════════

$sql = "SELECT IDUtilizador, Email, Password FROM Utilizador WHERE Email = ?";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    $debug['final_result'] = array(
        'error' => 'ERRO AO PREPARAR QUERY',
        'details' => $conn->error
    );
    echo json_encode($debug, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

$debug['user_check'] = array(
    'email_procurado' => $username,
    'utilizador_encontrado' => $user ? true : false,
    'id_utilizador' => $user['IDUtilizador'] ?? null
);

if (!$user) {
    $debug['final_result'] = array(
        'error' => 'UTILIZADOR NÃO ENCONTRADO',
        'email' => $username,
        'suggestion' => 'Insira dados via scripts/dados_teste.sql'
    );
    echo json_encode($debug, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
    exit;
}

// ═════════════════════════════════════════════════════════════════════════
// PASSO 6: Validar password
// ═════════════════════════════════════════════════════════════════════════

$passwordHash = $user['Password'];

// Detectar tipo de hash
$isHash = (strlen($passwordHash) === 64 && ctype_xdigit($passwordHash));

$debug['password_check'] = array(
    'password_tipo' => $isHash ? 'SHA2-256 (64 caract hex)' : 'Texto plano',
    'password_hash_length' => strlen($passwordHash),
    'password_input_length' => strlen($password)
);

if ($isHash) {
    // Password está em SHA2-256
    $providedPasswordHash = hash('sha256', $password);
    $passwordMatches = ($passwordHash === $providedPasswordHash);
    $debug['password_check']['comparacao'] = 'SHA2-256';
} else {
    // Password está em texto plano
    $passwordMatches = ($passwordHash === $password);
    $debug['password_check']['comparacao'] = 'Texto plano';
}

$debug['password_check']['correspondencia'] = $passwordMatches ? 'SIM' : 'NÃO';

// ═════════════════════════════════════════════════════════════════════════
// RESULTADO FINAL
// ═════════════════════════════════════════════════════════════════════════

if ($passwordMatches) {
    $debug['final_result'] = array(
        'success' => true,
        'message' => 'Login bem-sucedido!',
        'IDUtilizador' => $user['IDUtilizador']
    );
} else {
    $debug['final_result'] = array(
        'success' => false,
        'message' => 'Password incorrecta',
        'hint' => 'A password enviada não corresponde à do banco de dados'
    );
}

$stmt->close();
$conn->close();

// ═════════════════════════════════════════════════════════════════════════
// OUTPUT
// ═════════════════════════════════════════════════════════════════════════

echo json_encode($debug, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);

?>

