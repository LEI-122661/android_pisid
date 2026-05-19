-- ═════════════════════════════════════════════════════════════════════════════
-- SCRIPT DE DADOS DE TESTE PARA TESTES DA APLICAÇÃO ANDROID
-- ═════════════════════════════════════════════════════════════════════════════
--
-- Execute este script DEPOIS de rodar codigoBase.sql
-- Ele insere dados básicos para testes da app
--
-- ═════════════════════════════════════════════════════════════════════════════

USE simulacao_labirinto;

-- ═════════════════════════════════════════════════════════════════════════════
-- 1. LIMPAR DADOS ANTIGOS (OPCIONAL - descomente se necessário)
-- ═════════════════════════════════════════════════════════════════════════════

-- DELETE FROM Utilizador WHERE Email IN ('root@gmail.com', 'teste@email.com');
-- DELETE FROM Simulacao WHERE IDSimulacao > 0;


-- ═════════════════════════════════════════════════════════════════════════════
-- 2. INSERIR UTILIZAÇÃO DE TESTE
-- ═════════════════════════════════════════════════════════════════════════════

INSERT INTO Utilizador (Nome, Email, Password, Telemovel, Tipo, DataNascimento)
VALUES ('Utilizador Teste', 'root@gmail.com', 'root', '912345678', 'JOG', '2000-01-01');

INSERT INTO Utilizador (Nome, Email, Password, Telemovel, Tipo, DataNascimento)
VALUES ('Utilizador Admin', 'admin@gmail.com', 'admin123', '987654321', 'ADM', '1990-05-15');

INSERT INTO Utilizador (Nome, Email, Password, Telemovel, Tipo, DataNascimento)
VALUES ('Utilizador Teste 2', 'teste@email.com', 'senha123', '999999999', 'JOG', '2002-03-20');

-- ═════════════════════════════════════════════════════════════════════════════
-- 3. INSERIR SIMULAÇÃO DE TESTE
-- ═════════════════════════════════════════════════════════════════════════════

INSERT INTO Simulacao (Descricao, CriadoPor, Estado, LimiteTemp, LimiteRuido)
VALUES ('Simulação de Teste 1', 1, 'A_DECORRER', 25.00, 75.00);

INSERT INTO Simulacao (Descricao, CriadoPor, Estado, LimiteTemp, LimiteRuido)
VALUES ('Simulação de Teste 2', 2, 'PENDENTE', 30.00, 70.00);

-- ═════════════════════════════════════════════════════════════════════════════
-- 4. INSERIR DADOS DE OCUPAÇÃO DE SALAS (para MarsamiRoomFragment)
-- ═════════════════════════════════════════════════════════════════════════════

INSERT INTO OcupacaoLabirinto (IDSimulacao, Sala, NumeroMarsamisOdd, NumeroMarsamisEven, GatilhosUsados)
VALUES (1, 1, 2, 3, 0);

INSERT INTO OcupacaoLabirinto (IDSimulacao, Sala, NumeroMarsamisOdd, NumeroMarsamisEven, GatilhosUsados)
VALUES (1, 2, 1, 2, 1);

INSERT INTO OcupacaoLabirinto (IDSimulacao, Sala, NumeroMarsamisOdd, NumeroMarsamisEven, GatilhosUsados)
VALUES (1, 3, 4, 4, 2);

INSERT INTO OcupacaoLabirinto (IDSimulacao, Sala, NumeroMarsamisOdd, NumeroMarsamisEven, GatilhosUsados)
VALUES (1, 4, 0, 1, 0);

-- ═════════════════════════════════════════════════════════════════════════════
-- 5. INSERIR MENSAGENS DE TESTE (para MazeMessagesFragment)
-- ═════════════════════════════════════════════════════════════════════════════

INSERT INTO Mensagem (IDSimulacao, Sala, Sensor, Leitura, TipoAlerta, Msg, Leitura)
VALUES (1, 1, 'TEMP', 22.5, 'AVISO', 'Temperatura moderada', 22.5);

INSERT INTO Mensagem (IDSimulacao, Sala, Sensor, Leitura, TipoAlerta, Msg, Leitura)
VALUES (1, 2, 'RUIDO', 68.3, 'INFO', 'Nível de ruído normal', 68.3);

INSERT INTO Mensagem (IDSimulacao, Sala, Sensor, Leitura, TipoAlerta, Msg, Leitura)
VALUES (1, 3, 'TEMP', 28.0, 'CRITICO', 'TEMPERATURA ALTA!', 28.0);

-- ═════════════════════════════════════════════════════════════════════════════
-- 6. INSERIR DADOS DE TEMPERATURA (para MazeTemperatureFragment)
-- ═════════════════════════════════════════════════════════════════════════════

INSERT INTO Temperatura (IDMensagem, Temperatura)
SELECT ID, Leitura FROM Mensagem WHERE Sensor = 'TEMP' LIMIT 2;

-- ═════════════════════════════════════════════════════════════════════════════
-- 7. INSERIR DADOS DE SOM (para MazeSoundFragment)
-- ═════════════════════════════════════════════════════════════════════════════

INSERT INTO Som (IDMensagem, Som)
SELECT ID, Leitura FROM Mensagem WHERE Sensor = 'RUIDO' LIMIT 1;

-- ═════════════════════════════════════════════════════════════════════════════
-- 8. VERIFICAÇÃO FINAL
-- ═════════════════════════════════════════════════════════════════════════════

-- Verificar se utilizador foi inserido correctamente:
SELECT '=== UTILIZADORES CRIADOS ===' AS INFO;
SELECT IDUtilizador, Nome, Email, Password FROM Utilizador;

SELECT '=== SIMULAÇÕES CRIADAS ===' AS INFO;
SELECT IDSimulacao, Descricao, Estado FROM Simulacao;

SELECT '=== OCUPAÇÃO DE SALAS ===' AS INFO;
SELECT IDJogo, IDSimulacao, Sala, NumeroMarsamisOdd, NumeroMarsamisEven FROM OcupacaoLabirinto;

SELECT '=== MENSAGENS ===' AS INFO;
SELECT ID, IDSimulacao, Sala, TipoAlerta, Msg FROM Mensagem;

-- ═════════════════════════════════════════════════════════════════════════════
-- TESTE DE LOGIN
-- ═════════════════════════════════════════════════════════════════════════════
--
-- Agora teste o login com:
--   Email: root@gmail.com
--   Password: root
--   Database: simulacao_labirinto
--
-- Acesse: http://192.168.1.14:8000/maze_app_php/login.php?username=root@gmail.com&password=root&database=simulacao_labirinto
--
-- Resposta esperada:
-- {
--   "success": true,
--   "message": "Login bem-sucedido.",
--   "IDUtilizador": "1"
-- }
--
-- ═════════════════════════════════════════════════════════════════════════════

