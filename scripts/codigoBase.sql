-- ============================================================
-- SISTEMA DE SIMULAÇÃO DE LABIRINTO - PISID 25/26 (FINAL)
-- Full database with CURRENT_USER() + TRIGGER security (FIXED)
-- ============================================================

DROP DATABASE IF EXISTS simulacao_labirinto;

CREATE DATABASE IF NOT EXISTS simulacao_labirinto
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_general_ci;

USE simulacao_labirinto;

SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET time_zone = '+00:00';

-- ============================================================
-- 1. TABELAS BASE
-- ============================================================

CREATE TABLE IF NOT EXISTS Utilizador
(
    IDUtilizador   INT AUTO_INCREMENT PRIMARY KEY,
    Nome           VARCHAR(100),
    Telemovel      VARCHAR(12),
    Tipo           VARCHAR(3),
    Email          VARCHAR(50),
    Password       VARCHAR(255),
    DataNascimento DATE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS Simulacao
(
    IDSimulacao         INT                                        NOT NULL AUTO_INCREMENT,
    Descricao           TEXT                                                DEFAULT NULL,
    CriadoPor           INT                                                 DEFAULT NULL,
    DataHoraInicio      TIMESTAMP                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Estado              ENUM ('PENDENTE','A_DECORRER','TERMINADA') NOT NULL DEFAULT 'PENDENTE',
    EstadoAC            TINYINT(1)                                          DEFAULT 0,
    LimiteTemp          DECIMAL(5, 2)                                       DEFAULT 30.00,
    LimiteRuido         DECIMAL(5, 2)                                       DEFAULT 70.00,
    Pontuacao_Acumulada DECIMAL(10, 2)                                      DEFAULT 0.00,
    PRIMARY KEY (IDSimulacao),
    KEY fk_simulacao_criadopor (CriadoPor),
    CONSTRAINT fk_simulacao_criadopor
        FOREIGN KEY (CriadoPor) REFERENCES Utilizador (IDUtilizador)
            ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS Marsami
(
    IDMarsami   INT,
    IDSimulacao INT,
    Tipo        ENUM ('Odd','Even'),
    Status      INT DEFAULT 1,
    SalaAtual   INT DEFAULT NULL,
    PRIMARY KEY (IDMarsami, IDSimulacao),
    KEY fk_marsami_simulacao (IDSimulacao),
    CONSTRAINT fk_marsami_simulacao
        FOREIGN KEY (IDSimulacao) REFERENCES Simulacao (IDSimulacao)
            ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS MedicoesPassagens
(
    IDMedicao   INT       NOT NULL AUTO_INCREMENT,
    IDSimulacao INT                DEFAULT NULL,
    Hora        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    SalaOrigem  INT                DEFAULT NULL,
    SalaDestino INT                DEFAULT NULL,
    Marsami     INT                DEFAULT NULL,
    Status      INT                DEFAULT NULL,
    PRIMARY KEY (IDMedicao),
    KEY fk_medicoes_simulacao (IDSimulacao),
    CONSTRAINT fk_medicoes_simulacao
        FOREIGN KEY (IDSimulacao) REFERENCES Simulacao (IDSimulacao)
            ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS Mensagem
(
    ID          INT       NOT NULL AUTO_INCREMENT,
    IDSimulacao INT                DEFAULT NULL,
    Hora        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Sala        INT                DEFAULT NULL,
    Sensor      VARCHAR(10)        DEFAULT NULL,
    Leitura     DECIMAL(6, 2)      DEFAULT NULL,
    Msg         VARCHAR(100)       DEFAULT NULL,
    HoraEscrita TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    UNIQUE KEY uq_mensagem_msg (Msg),
    KEY fk_mensagens_simulacao (IDSimulacao),
    CONSTRAINT fk_mensagens_simulacao
        FOREIGN KEY (IDSimulacao) REFERENCES Simulacao (IDSimulacao)
            ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS Alerta
(
    IDAlerta    INT       NOT NULL AUTO_INCREMENT,
    IDSimulacao INT       NOT NULL,
    Sensor      VARCHAR(15)        DEFAULT NULL,
    TipoAlerta  VARCHAR(20)        DEFAULT NULL,
    Valor       DECIMAL(6, 2)      DEFAULT NULL,
    DataAlerta  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Descricao   VARCHAR(100)       DEFAULT NULL,
    PRIMARY KEY (IDAlerta),
    KEY fk_alerta_simulacao (IDSimulacao),
    CONSTRAINT fk_alerta_simulacao
        FOREIGN KEY (IDSimulacao) REFERENCES Simulacao (IDSimulacao)
            ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS OcupacaoLabirinto
(
    IDJogo             INT NOT NULL AUTO_INCREMENT,
    IDSimulacao        INT DEFAULT NULL,
    Sala               INT DEFAULT NULL,
    NumeroMarsamisOdd  INT DEFAULT 0,
    NumeroMarsamisEven INT DEFAULT 0,
    GatilhosUsados     INT DEFAULT 0,
    PRIMARY KEY (IDJogo),
    UNIQUE KEY uq_ocupacao (IDSimulacao, Sala),
    CONSTRAINT fk_ocupacao_simulacao
        FOREIGN KEY (IDSimulacao) REFERENCES Simulacao (IDSimulacao)
            ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS Temperatura
(
    IDTemperatura INT       NOT NULL AUTO_INCREMENT,
    IDMensagem    INT                DEFAULT NULL,
    Hora          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Temperatura   DECIMAL(5, 2)      DEFAULT NULL,
    PRIMARY KEY (IDTemperatura),
    KEY fk_temp_mensagem (IDMensagem),
    CONSTRAINT fk_temp_mensagem
        FOREIGN KEY (IDMensagem) REFERENCES Mensagem (ID)
            ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS Som
(
    IDSom      INT       NOT NULL AUTO_INCREMENT,
    IDMensagem INT                DEFAULT NULL,
    Hora       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    Som        DECIMAL(5, 2)      DEFAULT NULL,
    PRIMARY KEY (IDSom),
    KEY fk_som_mensagem (IDMensagem),
    CONSTRAINT fk_som_mensagem
        FOREIGN KEY (IDMensagem) REFERENCES Mensagem (ID)
            ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci;

-- ============================================================
-- 2. TRIGGERS
-- ============================================================

DELIMITER $$

-- TRIGGER 1: Auto-cria Marsami e atualiza ocupação de salas (STATUS-AWARE)
CREATE OR REPLACE TRIGGER After_Medicao_Insert
    AFTER INSERT
    ON MedicoesPassagens
    FOR EACH ROW
BEGIN
    DECLARE v_tipo VARCHAR(4);
    DECLARE v_marsami_exists INT DEFAULT 0;
    DECLARE v_sala_atual INT DEFAULT NULL;

    -- Verifica se o Marsami já existe na tabela Marsami
    SELECT COUNT(*)
    INTO v_marsami_exists
    FROM Marsami
    WHERE IDMarsami = NEW.Marsami
      AND IDSimulacao = NEW.IDSimulacao;

    -- Se não existir, cria automaticamente
    -- Apenas define SalaAtual quando Status = 1 (movimento real)
    IF v_marsami_exists = 0 THEN
        INSERT INTO Marsami (IDMarsami, IDSimulacao, Tipo, Status, SalaAtual)
        VALUES (NEW.Marsami,
                NEW.IDSimulacao,
                CASE WHEN NEW.Marsami % 2 = 1 THEN 'Odd' ELSE 'Even' END,
                NEW.Status,
                CASE WHEN NEW.Status = 1 THEN NEW.SalaDestino ELSE NULL END);
    END IF;

    -- Obtém o tipo do Marsami (sempre existe neste ponto)
    SELECT Tipo
    INTO v_tipo
    FROM Marsami
    WHERE IDMarsami = NEW.Marsami
      AND IDSimulacao = NEW.IDSimulacao
    LIMIT 1;

    -- Lê a sala atual antes de atualizar
    SELECT SalaAtual
    INTO v_sala_atual
    FROM Marsami
    WHERE IDMarsami = NEW.Marsami
      AND IDSimulacao = NEW.IDSimulacao
    LIMIT 1;

    -- Atualiza status e localização
    -- Apenas atualiza SalaAtual quando Status = 1 (movimento real)
    UPDATE Marsami
    SET SalaAtual = CASE WHEN NEW.Status = 1 THEN NEW.SalaDestino ELSE SalaAtual END,
        Status    = NEW.Status
    WHERE IDMarsami = NEW.Marsami
      AND IDSimulacao = NEW.IDSimulacao;

    -- Apenas ajusta contadores quando Status = 1 (movimento real)
    -- e quando há mudança de sala efetiva
    IF NEW.Status = 1 AND (v_sala_atual IS NULL OR v_sala_atual <> NEW.SalaDestino) THEN
        -- Auto-cria rows em OcupacaoLabirinto se não existirem
        INSERT IGNORE INTO OcupacaoLabirinto (IDSimulacao, Sala, NumeroMarsamisOdd, NumeroMarsamisEven,
                                              GatilhosUsados)
        VALUES (NEW.IDSimulacao, COALESCE(v_sala_atual, NEW.SalaOrigem), 0, 0, 0);

        INSERT IGNORE INTO OcupacaoLabirinto (IDSimulacao, Sala, NumeroMarsamisOdd, NumeroMarsamisEven,
                                              GatilhosUsados)
        VALUES (NEW.IDSimulacao, NEW.SalaDestino, 0, 0, 0);

        -- Decrementa contador na sala de origem (se não for sala 0)
        IF COALESCE(v_sala_atual, NEW.SalaOrigem) > 0 THEN
            UPDATE OcupacaoLabirinto
            SET NumeroMarsamisOdd  = CASE
                                         WHEN v_tipo = 'Odd' THEN GREATEST(0, NumeroMarsamisOdd - 1)
                                         ELSE NumeroMarsamisOdd END,
                NumeroMarsamisEven = CASE
                                         WHEN v_tipo = 'Even' THEN GREATEST(0, NumeroMarsamisEven - 1)
                                         ELSE NumeroMarsamisEven END
            WHERE IDSimulacao = NEW.IDSimulacao
              AND Sala = COALESCE(v_sala_atual, NEW.SalaOrigem);
        END IF;

        -- Incrementa contador na sala de destino (se não for sala 0)
        IF NEW.SalaDestino > 0 THEN
            UPDATE OcupacaoLabirinto
            SET NumeroMarsamisOdd  = CASE WHEN v_tipo = 'Odd' THEN NumeroMarsamisOdd + 1 ELSE NumeroMarsamisOdd END,
                NumeroMarsamisEven = CASE
                                         WHEN v_tipo = 'Even' THEN NumeroMarsamisEven + 1
                                         ELSE NumeroMarsamisEven END
            WHERE IDSimulacao = NEW.IDSimulacao
              AND Sala = NEW.SalaDestino;
        END IF;
    END IF;
END$$

-- TRIGGER 2: Prevent unauthorized direct SQL updates on Simulacao (ALLOWS ADMIN)
CREATE OR REPLACE TRIGGER Before_Simulacao_Update
    BEFORE UPDATE
    ON Simulacao
    FOR EACH ROW
BEGIN
    DECLARE v_IDUser INT;
    DECLARE v_Tipo VARCHAR(3);
    DECLARE v_Email VARCHAR(50);

    -- Extrai email do utilizador autenticado
    SET v_Email = LEFT(USER(), LOCATE('@', USER(), LOCATE('@', USER()) + 1) - 1);
    SELECT IDUtilizador, Tipo INTO v_IDUser, v_Tipo FROM Utilizador WHERE Email = v_Email LIMIT 1;

    -- Permite se o utilizador é o criador OU é admin
    IF NEW.CriadoPor != v_IDUser AND v_Tipo != 'ADM' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sem permissão para editar esta simulação.';
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- 3. STORED PROCEDURES
-- ============================================================

DELIMITER $$

-- SP 1: Criar conta de utilizador (Admin only)
CREATE OR REPLACE PROCEDURE sp_AdminCriarConta(
    IN p_Nome VARCHAR(100),
    IN p_Email VARCHAR(50),
    IN p_Password VARCHAR(255),
    IN p_Telemovel VARCHAR(12),
    IN p_DataNascimento DATE,
    IN p_Tipo VARCHAR(3)
)
BEGIN
    IF EXISTS (SELECT 1 FROM Utilizador WHERE Email = p_Email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este e-mail já está em uso.';
    ELSE
        INSERT INTO Utilizador (Nome, Email, Password, Telemovel, DataNascimento, Tipo)
        VALUES (p_Nome, p_Email, SHA2(p_Password, 256), p_Telemovel, p_DataNascimento, p_Tipo);

        SET @sql = CONCAT('CREATE USER ''', p_Email, '''@''%'' IDENTIFIED BY ''', p_Password, '''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        IF p_Tipo = 'ADM' THEN
            SET @sql = CONCAT('GRANT `role_admin` TO ''', p_Email, '''@''%''');
        ELSE
            SET @sql = CONCAT('GRANT `role_user` TO ''', p_Email, '''@''%''');
        END IF;
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        IF p_Tipo = 'ADM' THEN
            SET @sql = CONCAT('SET DEFAULT ROLE `role_admin` FOR ''', p_Email, '''@''%''');
        ELSE
            SET @sql = CONCAT('SET DEFAULT ROLE `role_user` FOR ''', p_Email, '''@''%''');
        END IF;
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

-- SP 2: Remover conta (Admin only)
CREATE OR REPLACE PROCEDURE sp_AdminRemoverConta(
    IN p_Email VARCHAR(50)
)
BEGIN
    DELETE FROM Utilizador WHERE Email = p_Email;
    SET @sql = CONCAT('DROP USER IF EXISTS ''', p_Email, '''@''%''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

-- SP 3: Atualizar próprio perfil (DEFINER + USER for UPDATE privilege)
CREATE OR REPLACE PROCEDURE sp_AtualizarProprioPerfil(
    IN p_Nome VARCHAR(100),
    IN p_Telemovel VARCHAR(12),
    IN p_Password VARCHAR(255)
)
    SQL SECURITY DEFINER
BEGIN
    DECLARE v_Email VARCHAR(50);

    -- Formula corrigida para emails com múltiplos @
    SET v_Email = LEFT(USER(), LOCATE('@', USER(), LOCATE('@', USER()) + 1) - 1);

    IF p_Password IS NOT NULL AND p_Password != '' THEN
        UPDATE Utilizador
        SET Nome      = p_Nome,
            Telemovel = p_Telemovel,
            Password  = SHA2(p_Password, 256)
        WHERE Email = v_Email;

        SET @sql = CONCAT('ALTER USER IF EXISTS ''', v_Email, '''@''%'' IDENTIFIED BY ''', p_Password, '''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    ELSE
        UPDATE Utilizador
        SET Nome      = p_Nome,
            Telemovel = p_Telemovel
        WHERE Email = v_Email;
    END IF;
END$$

-- SP 4: Editar perfil de qualquer utilizador (Admin only)
CREATE OR REPLACE PROCEDURE sp_AdminEditarPerfil(
    IN p_IDUtilizador INT,
    IN p_Nome VARCHAR(100),
    IN p_Telemovel VARCHAR(12),
    IN p_Password VARCHAR(255),
    IN p_DataNascimento DATE,
    IN p_EmailNovo VARCHAR(50),
    IN p_TipoNovo VARCHAR(3)
)
BEGIN
    DECLARE v_EmailAntigo VARCHAR(50);

    SELECT Email INTO v_EmailAntigo FROM Utilizador WHERE IDUtilizador = p_IDUtilizador;
    IF v_EmailAntigo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Utilizador não encontrado.';
    END IF;

    UPDATE Utilizador
    SET Nome           = p_Nome,
        Telemovel      = p_Telemovel,
        Password       = CASE
                             WHEN p_Password IS NOT NULL AND p_Password != ''
                                 THEN SHA2(p_Password, 256)
                             ELSE Password END,
        DataNascimento = p_DataNascimento,
        Email          = p_EmailNovo,
        Tipo           = p_TipoNovo
    WHERE IDUtilizador = p_IDUtilizador;

    IF v_EmailAntigo != p_EmailNovo THEN
        SET @sql = CONCAT('RENAME USER ''', v_EmailAntigo, '''@''%'' TO ''', p_EmailNovo, '''@''%''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;

    IF p_Password IS NOT NULL AND p_Password != '' THEN
        SET @sql = CONCAT('ALTER USER IF EXISTS ''', p_EmailNovo, '''@''%'' IDENTIFIED BY ''', p_Password, '''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;

    DELETE
    FROM mysql.roles_mapping
    WHERE User = p_EmailNovo
      AND Host = '%'
      AND Role IN ('role_admin', 'role_user');
    FLUSH PRIVILEGES;

    IF p_TipoNovo = 'ADM' THEN
        SET @sql = CONCAT('GRANT `role_admin` TO ''', p_EmailNovo, '''@''%''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SET @sql = CONCAT('SET DEFAULT ROLE `role_admin` FOR ''', p_EmailNovo, '''@''%''');
    ELSE
        SET @sql = CONCAT('GRANT `role_user` TO ''', p_EmailNovo, '''@''%''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SET @sql = CONCAT('SET DEFAULT ROLE `role_user` FOR ''', p_EmailNovo, '''@''%''');
    END IF;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

-- SP 5: Criar simulação (INVOKER + CURRENT_USER)
CREATE OR REPLACE PROCEDURE sp_CriarSimulacao(
    IN p_Descricao TEXT,
    IN p_LimiteTemp DECIMAL(5, 2),
    IN p_LimiteRuido DECIMAL(5, 2)
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_IDUser INT;
    DECLARE v_Email VARCHAR(50);

    IF p_LimiteTemp < 0 OR p_LimiteTemp > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Limite de temperatura deve ser entre 0 e 100%.';
    END IF;

    IF p_LimiteRuido < 0 OR p_LimiteRuido > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Limite de ruído deve ser entre 0 e 100%.';
    END IF;

    SET v_Email = LEFT(CURRENT_USER(), LOCATE('@', CURRENT_USER(), LOCATE('@', CURRENT_USER()) + 1) - 1);
    SELECT IDUtilizador INTO v_IDUser FROM Utilizador WHERE Email = v_Email;

    INSERT INTO Simulacao (Descricao, CriadoPor, LimiteTemp, LimiteRuido, Estado)
    VALUES (p_Descricao, v_IDUser, p_LimiteTemp, p_LimiteRuido, 'PENDENTE');

    SELECT LAST_INSERT_ID() AS NovaSimulacaoID;
END$$

-- SP 6: Editar simulação (INVOKER + CURRENT_USER + TRIGGER protection)
CREATE OR REPLACE PROCEDURE sp_EditarSimulacao(
    IN p_IDSimulacao INT,
    IN p_Descricao TEXT,
    IN p_LimiteTemp DECIMAL(5, 2),
    IN p_LimiteRuido DECIMAL(5, 2)
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_IDUser INT;
    DECLARE v_Email VARCHAR(50);

    IF p_LimiteTemp < 0 OR p_LimiteTemp > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Limite de temperatura deve ser entre 0 e 100%.';
    END IF;

    IF p_LimiteRuido < 0 OR p_LimiteRuido > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Limite de ruído deve ser entre 0 e 100%.';
    END IF;

    SET v_Email = LEFT(CURRENT_USER(), LOCATE('@', CURRENT_USER(), LOCATE('@', CURRENT_USER()) + 1) - 1);
    SELECT IDUtilizador INTO v_IDUser FROM Utilizador WHERE Email = v_Email;

    UPDATE Simulacao
    SET Descricao   = p_Descricao,
        LimiteTemp  = p_LimiteTemp,
        LimiteRuido = p_LimiteRuido
    WHERE IDSimulacao = p_IDSimulacao
      AND CriadoPor = v_IDUser
      AND Estado = 'PENDENTE';

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
                'Sem permissão para editar esta simulação, ela não existe, ou não está em estado PENDENTE.';
    END IF;
END$$

-- SP 7: Editar simulação (Admin - sem restrições)
CREATE OR REPLACE PROCEDURE sp_AdminEditarSimulacao(
    IN p_IDSimulacao INT,
    IN p_Descricao TEXT,
    IN p_LimiteTemp DECIMAL(5, 2),
    IN p_LimiteRuido DECIMAL(5, 2)
)
BEGIN
    IF p_LimiteTemp < 0 OR p_LimiteTemp > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Limite de temperatura deve ser entre 0 e 100%.';
    END IF;

    IF p_LimiteRuido < 0 OR p_LimiteRuido > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Limite de ruído deve ser entre 0 e 100%.';
    END IF;

    UPDATE Simulacao
    SET Descricao   = p_Descricao,
        LimiteTemp  = p_LimiteTemp,
        LimiteRuido = p_LimiteRuido
    WHERE IDSimulacao = p_IDSimulacao;
END$$

-- SP 8: Iniciar simulação (INVOKER + CURRENT_USER + TRIGGER protection)
CREATE OR REPLACE PROCEDURE sp_IniciarSimulacao(
    IN p_IDSimulacao INT
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_Estado ENUM ('PENDENTE','A_DECORRER','TERMINADA');
    DECLARE v_CriadoPor INT;
    DECLARE v_IDUser INT;
    DECLARE v_Email VARCHAR(50);

    IF EXISTS (SELECT 1 FROM Simulacao WHERE Estado = 'A_DECORRER') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
                'Já existe uma simulação em curso. Termine-a antes de iniciar outra.';
    END IF;

    SELECT Estado, CriadoPor
    INTO v_Estado, v_CriadoPor
    FROM Simulacao
    WHERE IDSimulacao = p_IDSimulacao
    LIMIT 1;

    IF v_Estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Simulação inexistente.';
    END IF;

    SET v_Email = LEFT(CURRENT_USER(), LOCATE('@', CURRENT_USER(), LOCATE('@', CURRENT_USER()) + 1) - 1);
    SELECT IDUtilizador INTO v_IDUser FROM Utilizador WHERE Email = v_Email;

    IF v_CriadoPor != v_IDUser THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sem permissão para iniciar esta simulação.';
    END IF;

    IF v_Estado <> 'PENDENTE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Só é possível iniciar simulações em estado PENDENTE.';
    END IF;

    UPDATE Simulacao
    SET Estado         = 'A_DECORRER',
        DataHoraInicio = CURRENT_TIMESTAMP
    WHERE IDSimulacao = p_IDSimulacao;
END$$

-- SP 9: Iniciar simulação (Admin)
CREATE OR REPLACE PROCEDURE sp_AdminIniciarSimulacao(
    IN p_IDSimulacao INT
)
BEGIN
    IF EXISTS (SELECT 1 FROM Simulacao WHERE Estado = 'A_DECORRER') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
                'Já existe uma simulação em curso. Termine-a antes de iniciar outra.';
    END IF;

    UPDATE Simulacao
    SET Estado         = 'A_DECORRER',
        DataHoraInicio = CURRENT_TIMESTAMP
    WHERE IDSimulacao = p_IDSimulacao
      AND Estado = 'PENDENTE';
END$$

-- SP 10: Terminar simulação (INVOKER + CURRENT_USER + TRIGGER protection)
CREATE OR REPLACE PROCEDURE sp_TerminarSimulacao(
    IN p_IDSimulacao INT
)
    SQL SECURITY INVOKER
BEGIN
    DECLARE v_Estado ENUM ('PENDENTE','A_DECORRER','TERMINADA');
    DECLARE v_CriadoPor INT;
    DECLARE v_IDUser INT;
    DECLARE v_Email VARCHAR(50);

    SELECT Estado, CriadoPor
    INTO v_Estado, v_CriadoPor
    FROM Simulacao
    WHERE IDSimulacao = p_IDSimulacao
    LIMIT 1;

    IF v_Estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Simulação inexistente.';
    END IF;

    SET v_Email = LEFT(CURRENT_USER(), LOCATE('@', CURRENT_USER(), LOCATE('@', CURRENT_USER()) + 1) - 1);
    SELECT IDUtilizador INTO v_IDUser FROM Utilizador WHERE Email = v_Email;

    IF v_CriadoPor != v_IDUser THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sem permissão para terminar esta simulação.';
    END IF;

    IF v_Estado <> 'A_DECORRER' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Só é possível terminar simulações em curso.';
    END IF;

    UPDATE Simulacao
    SET Estado = 'TERMINADA'
    WHERE IDSimulacao = p_IDSimulacao;
END$$

-- SP 11: Terminar simulação (Admin)
CREATE OR REPLACE PROCEDURE sp_AdminTerminarSimulacao(
    IN p_IDSimulacao INT
)
BEGIN
    DECLARE v_Estado ENUM ('PENDENTE','A_DECORRER','TERMINADA');

    SELECT Estado INTO v_Estado FROM Simulacao WHERE IDSimulacao = p_IDSimulacao LIMIT 1;

    IF v_Estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Simulação inexistente.';
    END IF;

    IF v_Estado <> 'A_DECORRER' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Só é possível terminar simulações em curso.';
    END IF;

    UPDATE Simulacao SET Estado = 'TERMINADA' WHERE IDSimulacao = p_IDSimulacao;
END$$

-- SP 12: Terminar simulação (Alerta - sem verificação de criador)
CREATE OR REPLACE PROCEDURE sp_AlertaTerminarSimulacao(
    IN p_IDSimulacao INT
)
BEGIN
    DECLARE v_Estado ENUM ('PENDENTE','A_DECORRER','TERMINADA');

    SELECT Estado INTO v_Estado FROM Simulacao WHERE IDSimulacao = p_IDSimulacao LIMIT 1;

    IF v_Estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Simulação inexistente.';
    END IF;

    IF v_Estado <> 'A_DECORRER' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Só é possível terminar simulações em curso.';
    END IF;

    UPDATE Simulacao SET Estado = 'TERMINADA' WHERE IDSimulacao = p_IDSimulacao;
END$$

-- SP 13: Registar passagem (called by MQTT2SQL Java program)
CREATE OR REPLACE PROCEDURE sp_RegistarPassagem(
    IN p_IDSimulacao INT,
    IN p_SalaOrigem INT,
    IN p_SalaDestino INT,
    IN p_Marsami INT,
    IN p_Status INT,
    IN p_DataMovimento TIMESTAMP,
    OUT p_SalasGatilho VARCHAR(255)
)
BEGIN
    -- Insere movimento (trigger dispara automaticamente)
    INSERT INTO MedicoesPassagens (IDSimulacao, Hora, SalaOrigem, SalaDestino, Marsami, Status)
    VALUES (p_IDSimulacao, p_DataMovimento, p_SalaOrigem, p_SalaDestino, p_Marsami, p_Status);

    -- Constrói string com salas onde Odd==Even e GatilhosUsados<3
    SELECT GROUP_CONCAT(Sala ORDER BY Sala SEPARATOR ',')
    INTO p_SalasGatilho
    FROM OcupacaoLabirinto
    WHERE IDSimulacao = p_IDSimulacao
      AND NumeroMarsamisOdd > 0
      AND NumeroMarsamisOdd = NumeroMarsamisEven
      AND GatilhosUsados < 3;
END$$

DELIMITER ;

-- ============================================================
-- 4. ROLES E GRANTS
-- ============================================================

CREATE ROLE IF NOT EXISTS `role_admin`;
CREATE ROLE IF NOT EXISTS `role_user`;
CREATE ROLE IF NOT EXISTS `role_mqtt`;
CREATE ROLE IF NOT EXISTS `role_alerta`;
CREATE ROLE IF NOT EXISTS `role_android`;

-- ADMIN: acesso total
GRANT ALL PRIVILEGES ON simulacao_labirinto.* TO `role_admin`;

-- USER: leitura + gestão própria de simulações (WITH TRIGGER protection)
GRANT SELECT ON simulacao_labirinto.* TO `role_user`;
GRANT INSERT, UPDATE ON simulacao_labirinto.Simulacao TO `role_user`;
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_AtualizarProprioPerfil TO `role_user`;
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_CriarSimulacao TO `role_user`;
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_EditarSimulacao TO `role_user`;
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_IniciarSimulacao TO `role_user`;
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_TerminarSimulacao TO `role_user`;

-- MQTT: inserir dados sensoriais
GRANT INSERT ON simulacao_labirinto.Mensagem TO `role_mqtt`;
GRANT INSERT ON simulacao_labirinto.MedicoesPassagens TO `role_mqtt`;
GRANT INSERT ON simulacao_labirinto.Temperatura TO `role_mqtt`;
GRANT INSERT ON simulacao_labirinto.Som TO `role_mqtt`;
GRANT SELECT, UPDATE ON simulacao_labirinto.Marsami TO `role_mqtt`;
GRANT SELECT, UPDATE ON simulacao_labirinto.OcupacaoLabirinto TO `role_mqtt`;
GRANT SELECT ON simulacao_labirinto.Simulacao TO `role_mqtt`;
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_RegistarPassagem TO `role_mqtt`;

-- ALERTA: ler dados e terminar
GRANT SELECT ON simulacao_labirinto.Simulacao TO `role_alerta`;
GRANT SELECT ON simulacao_labirinto.Mensagem TO `role_alerta`;
GRANT SELECT ON simulacao_labirinto.MedicoesPassagens TO `role_alerta`;
GRANT SELECT ON simulacao_labirinto.Temperatura TO `role_alerta`;
GRANT SELECT ON simulacao_labirinto.Som TO `role_alerta`;
GRANT SELECT ON simulacao_labirinto.Marsami TO `role_alerta`;
GRANT SELECT ON simulacao_labirinto.OcupacaoLabirinto TO `role_alerta`;
GRANT UPDATE ON simulacao_labirinto.Simulacao TO `role_alerta`;
GRANT INSERT ON simulacao_labirinto.Alerta TO `role_alerta`;
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_AlertaTerminarSimulacao TO `role_alerta`;

-- ANDROID: ler dados
GRANT SELECT ON simulacao_labirinto.* TO `role_android`;

FLUSH PRIVILEGES;
