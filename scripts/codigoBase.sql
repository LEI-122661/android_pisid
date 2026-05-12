CREATE DATABASE IF NOT EXISTS simulacao_labirinto
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE simulacao_labirinto;

SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET time_zone = '+00:00';

-- ============================================================
-- 1. Tabelas base
-- ============================================================

CREATE TABLE Utilizador (
  IDUtilizador INT AUTO_INCREMENT PRIMARY KEY,
  Nome VARCHAR(100),
  Telemovel VARCHAR(12),
  Tipo VARCHAR(3),
  Email VARCHAR(50),
  Password VARCHAR(255),
  DataNascimento DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE Simulacao (
  IDSimulacao INT NOT NULL AUTO_INCREMENT,
  Descricao TEXT DEFAULT NULL,
  CriadoPor INT DEFAULT NULL,
  DataHoraInicio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Estado ENUM('PENDENTE','A_DECORRER','TERMINADA') NOT NULL DEFAULT 'PENDENTE',
  EstadoAC TINYINT(1) DEFAULT 0,
  LimiteTemp DECIMAL(5,2) DEFAULT 30.00,
  LimiteRuido DECIMAL(5,2) DEFAULT 70.00,
  Pontuacao_Acumulada DECIMAL(10,2) DEFAULT 0.00,
  PRIMARY KEY (IDSimulacao),
  KEY fk_simulacao_criadopor (CriadoPor),
  CONSTRAINT fk_simulacao_criadopor
    FOREIGN KEY (CriadoPor) REFERENCES Utilizador(IDUtilizador)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE Marsami (
  IDMarsami INT,
  IDSimulacao INT,
  Tipo ENUM('Odd','Even'),
  Status INT DEFAULT 1,
  SalaAtual INT DEFAULT NULL,
  PRIMARY KEY (IDMarsami, IDSimulacao),
  KEY fk_marsami_simulacao (IDSimulacao),
  CONSTRAINT fk_marsami_simulacao
    FOREIGN KEY (IDSimulacao) REFERENCES Simulacao(IDSimulacao)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE MedicoesPassagens (
  IDMedicao INT NOT NULL AUTO_INCREMENT,
  IDSimulacao INT DEFAULT NULL,
  Hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  SalaOrigem INT DEFAULT NULL,
  SalaDestino INT DEFAULT NULL,
  Marsami INT DEFAULT NULL,
  Status INT DEFAULT NULL,
  PRIMARY KEY (IDMedicao),
  KEY fk_medicoes_simulacao (IDSimulacao),
  CONSTRAINT fk_medicoes_simulacao
    FOREIGN KEY (IDSimulacao) REFERENCES Simulacao(IDSimulacao)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE Mensagem (
  ID INT NOT NULL AUTO_INCREMENT,
  IDSimulacao INT DEFAULT NULL,
  Hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  Sala INT DEFAULT NULL,
  Sensor VARCHAR(10) DEFAULT NULL,
  Leitura DECIMAL(6,2) DEFAULT NULL,
  TipoAlerta VARCHAR(50) DEFAULT NULL,
  Msg VARCHAR(100) DEFAULT NULL,
  HoraEscrita TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  KEY fk_mensagens_simulacao (IDSimulacao),
  CONSTRAINT fk_mensagens_simulacao
    FOREIGN KEY (IDSimulacao) REFERENCES Simulacao(IDSimulacao)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE OcupacaoLabirinto (
  IDJogo INT NOT NULL AUTO_INCREMENT,
  IDSimulacao INT DEFAULT NULL,
  Sala INT DEFAULT NULL,
  NumeroMarsamisOdd INT DEFAULT 0,
  NumeroMarsamisEven INT DEFAULT 0,
  GatilhosUsados INT DEFAULT 0,
  PRIMARY KEY (IDJogo),
  UNIQUE KEY uq_ocupacao (IDSimulacao, Sala),
  CONSTRAINT fk_ocupacao_simulacao
    FOREIGN KEY (IDSimulacao) REFERENCES Simulacao(IDSimulacao)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE Temperatura (
  IDTemperatura INT NOT NULL AUTO_INCREMENT,
  IDMensagem INT DEFAULT NULL,
  Hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  Temperatura DECIMAL(5,2) DEFAULT NULL,
  PRIMARY KEY (IDTemperatura),
  KEY fk_temp_mensagem (IDMensagem),
  CONSTRAINT fk_temp_mensagem
    FOREIGN KEY (IDMensagem) REFERENCES Mensagem(ID)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE Som (
  IDSom INT NOT NULL AUTO_INCREMENT,
  IDMensagem INT DEFAULT NULL,
  Hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  Som DECIMAL(5,2) DEFAULT NULL,
  PRIMARY KEY (IDSom),
  KEY fk_som_mensagem (IDMensagem),
  CONSTRAINT fk_som_mensagem
    FOREIGN KEY (IDMensagem) REFERENCES Mensagem(ID)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



-- ============================================================
-- 2. Triggers
-- ============================================================

DELIMITER $$

CREATE TRIGGER After_Medicao_Insert
AFTER INSERT ON MedicoesPassagens
FOR EACH ROW
BEGIN
  DECLARE v_tipo VARCHAR(4);

  SELECT Tipo INTO v_tipo
  FROM Marsami
  WHERE IDMarsami = NEW.Marsami
    AND IDSimulacao = NEW.IDSimulacao
  LIMIT 1;

  UPDATE Marsami
     SET SalaAtual = NEW.SalaDestino,
         Status    = NEW.Status
   WHERE IDMarsami   = NEW.Marsami
     AND IDSimulacao = NEW.IDSimulacao;

  IF NEW.SalaOrigem > 0 THEN
    UPDATE OcupacaoLabirinto
       SET NumeroMarsamisOdd  = CASE WHEN v_tipo = 'Odd'  THEN GREATEST(0, NumeroMarsamisOdd  - 1) ELSE NumeroMarsamisOdd  END,
           NumeroMarsamisEven = CASE WHEN v_tipo = 'Even' THEN GREATEST(0, NumeroMarsamisEven - 1) ELSE NumeroMarsamisEven END
     WHERE IDSimulacao = NEW.IDSimulacao
       AND Sala        = NEW.SalaOrigem;
  END IF;

  IF NEW.SalaDestino > 0 THEN
    UPDATE OcupacaoLabirinto
       SET NumeroMarsamisOdd  = CASE WHEN v_tipo = 'Odd'  THEN NumeroMarsamisOdd  + 1 ELSE NumeroMarsamisOdd  END,
           NumeroMarsamisEven = CASE WHEN v_tipo = 'Even' THEN NumeroMarsamisEven + 1 ELSE NumeroMarsamisEven END
     WHERE IDSimulacao = NEW.IDSimulacao
       AND Sala        = NEW.SalaDestino;
  END IF;
END$$

DELIMITER ;

-- ============================================================
-- 3. SPs
-- ============================================================

DELIMITER $$

-- SP 1: Criar conta
CREATE PROCEDURE sp_CriarConta(
    IN p_Nome VARCHAR(100),
    IN p_Email VARCHAR(50),
    IN p_Password VARCHAR(255),
    IN p_Telemovel VARCHAR(12),
    IN p_DataNascimento DATE
)
BEGIN
    IF EXISTS (SELECT 1 FROM Utilizador WHERE Email = p_Email) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Este e-mail já está em uso.';
    ELSE
        INSERT INTO Utilizador (Nome, Email, Password, Telemovel, DataNascimento, Tipo)
        VALUES (p_Nome, p_Email, SHA2(p_Password, 256), p_Telemovel, p_DataNascimento, 'JOG');

        SET @sql = CONCAT('CREATE USER ''', p_Email, '''@''localhost'' IDENTIFIED BY ''', p_Password, '''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @sql = CONCAT('GRANT ''role_user'' TO ''', p_Email, '''@''localhost''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @sql = CONCAT('SET DEFAULT ROLE ''role_user'' FOR ''', p_Email, '''@''localhost''');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT LAST_INSERT_ID() AS NovoID;
    END IF;
END$$

-- SP 2: Remover conta (admin only)
CREATE PROCEDURE sp_RemoverConta(
    IN p_Email VARCHAR(50)
)
BEGIN
    DELETE FROM Utilizador WHERE Email = p_Email;

    SET @sql = CONCAT('DROP USER IF EXISTS ''', p_Email, '''@''localhost''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

-- SP 3: Atualizar proprio perfil
CREATE PROCEDURE sp_AtualizarProprioPerfil(
    IN p_Nome VARCHAR(100),
    IN p_Telemovel VARCHAR(12),
    IN p_Password VARCHAR(255)
)
BEGIN
    UPDATE Utilizador
    SET Nome      = p_Nome,
        Telemovel = p_Telemovel,
        Password  = SHA2(p_Password, 256)
    WHERE Email = SUBSTRING_INDEX(CURRENT_USER(), '@', 1);
END$$

-- SP 4: Atualizar perfil (admin only)
CREATE PROCEDURE sp_AtualizarPerfil(
    IN p_IDUtilizador INT,
    IN p_Nome VARCHAR(100),
    IN p_Telemovel VARCHAR(12),
    IN p_Password VARCHAR(255),
    IN p_DataNascimento DATE,
    IN p_Email VARCHAR(50)
)
BEGIN
    UPDATE Utilizador
    SET Nome           = p_Nome,
        Telemovel      = p_Telemovel,
        Password       = SHA2(p_Password, 256),
        DataNascimento = p_DataNascimento,
        Email          = p_Email
    WHERE IDUtilizador = p_IDUtilizador;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Utilizador não encontrado.';
    END IF;
END$$

-- SP 5: Criar simulacao
CREATE PROCEDURE sp_CriarSimulacao(
    IN p_Descricao TEXT,
    IN p_LimiteTemp DECIMAL(5,2),
    IN p_LimiteRuido DECIMAL(5,2)
)
BEGIN
    DECLARE v_IDUtilizador INT;

    SELECT IDUtilizador INTO v_IDUtilizador
    FROM Utilizador
    WHERE Email = SUBSTRING_INDEX(CURRENT_USER(), '@', 1);

    INSERT INTO Simulacao (Descricao, CriadoPor, LimiteTemp, LimiteRuido, Estado)
    VALUES (p_Descricao, v_IDUtilizador, p_LimiteTemp, p_LimiteRuido, 'PENDENTE');

    SELECT LAST_INSERT_ID() AS NovaSimulacaoID;
END$$

-- SP 6: Editar simulacao
CREATE PROCEDURE sp_EditarSimulacao(
    IN p_IDSimulacao INT,
    IN p_Descricao TEXT,
    IN p_LimiteTemp DECIMAL(5,2),
    IN p_LimiteRuido DECIMAL(5,2)
)
BEGIN
    DECLARE v_IDUtilizador INT;

    SELECT IDUtilizador INTO v_IDUtilizador
    FROM Utilizador
    WHERE Email = SUBSTRING_INDEX(CURRENT_USER(), '@', 1);

    UPDATE Simulacao
    SET Descricao   = p_Descricao,
        LimiteTemp  = p_LimiteTemp,
        LimiteRuido = p_LimiteRuido
    WHERE IDSimulacao = p_IDSimulacao
      AND CriadoPor   = v_IDUtilizador
      AND Estado      = 'PENDENTE';

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Sem permissão para editar esta simulação, ela não existe, ou não está em estado PENDENTE.';
    END IF;
END$$

-- SP 7: Iniciar simulacao
CREATE PROCEDURE sp_IniciarSimulacao(
    IN p_IDSimulacao INT
)
BEGIN
    DECLARE v_Estado ENUM('PENDENTE','A_DECORRER','TERMINADA');

    SELECT Estado INTO v_Estado
    FROM Simulacao
    WHERE IDSimulacao = p_IDSimulacao
    LIMIT 1;

    IF v_Estado IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Simulação inexistente.';
    END IF;

    IF v_Estado <> 'PENDENTE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Só é possível iniciar simulações em estado PENDENTE.';
    END IF;

    UPDATE Simulacao
    SET Estado = 'A_DECORRER',
        DataHoraInicio = CURRENT_TIMESTAMP
    WHERE IDSimulacao = p_IDSimulacao;
END$$

-- SP 8: Terminar simulacao
CREATE PROCEDURE sp_TerminarSimulacao(
    IN p_IDSimulacao INT
)
BEGIN
    DECLARE v_Estado ENUM('PENDENTE','A_DECORRER','TERMINADA');

    SELECT Estado INTO v_Estado
    FROM Simulacao
    WHERE IDSimulacao = p_IDSimulacao
    LIMIT 1;

    IF v_Estado IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Simulação inexistente.';
    END IF;

    IF v_Estado <> 'A_DECORRER' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Só é possível terminar simulações em curso.';
    END IF;

    UPDATE Simulacao
    SET Estado = 'TERMINADA'
    WHERE IDSimulacao = p_IDSimulacao;
END$$

-- SP 9: Registar Passagem (called by MQTT2SQL Java program)
-- Inserts a movement record, trigger fires automatically to update
-- Marsami location and OcupacaoLabirinto counts.
-- Returns comma-separated room IDs eligible for scoring trigger via OUT parameter.
CREATE PROCEDURE sp_RegistarPassagem(
    IN  p_IDSimulacao   INT,
    IN  p_SalaOrigem    INT,
    IN  p_SalaDestino   INT,
    IN  p_Marsami       INT,
    IN  p_Status        INT,
    IN  p_DataMovimento TIMESTAMP,
    OUT p_SalasGatilho  VARCHAR(255)
)
BEGIN
    -- Insert movement record (After_Medicao_Insert trigger fires here automatically)
    INSERT INTO MedicoesPassagens (IDSimulacao, Hora, SalaOrigem, SalaDestino, Marsami, Status)
    VALUES (p_IDSimulacao, p_DataMovimento, p_SalaOrigem, p_SalaDestino, p_Marsami, p_Status);

    -- Build comma-separated string of rooms where Odd == Even and GatilhosUsados < 3
    SET p_SalasGatilho = '';

    SELECT GROUP_CONCAT(Sala ORDER BY Sala SEPARATOR ',')
    INTO p_SalasGatilho
    FROM OcupacaoLabirinto
    WHERE IDSimulacao       = p_IDSimulacao
      AND NumeroMarsamisOdd  > 0
      AND NumeroMarsamisOdd  = NumeroMarsamisEven
      AND GatilhosUsados     < 3;

    -- If NULL (no eligible rooms), return empty string
    IF p_SalasGatilho IS NULL THEN
        SET p_SalasGatilho = '';
    END IF;

    -- Increment GatilhosUsados for all rooms being returned
    IF p_SalasGatilho <> '' THEN
        UPDATE OcupacaoLabirinto
        SET GatilhosUsados = GatilhosUsados + 1
        WHERE IDSimulacao = p_IDSimulacao
          AND FIND_IN_SET(Sala, p_SalasGatilho);
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- 4. SEGURANÇA: ROLES E GRANTS
-- ============================================================

CREATE ROLE IF NOT EXISTS 'role_admin';
CREATE ROLE IF NOT EXISTS 'role_user';
CREATE ROLE IF NOT EXISTS 'role_mqtt';
CREATE ROLE IF NOT EXISTS 'role_alerta';

-- ADMIN: full access + all SPs
GRANT ALL PRIVILEGES ON simulacao_labirinto.* TO 'role_admin';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_CriarConta           TO 'role_admin';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_RemoverConta         TO 'role_admin';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_AtualizarProprioPerfil TO 'role_admin';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_AtualizarPerfil      TO 'role_admin';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_CriarSimulacao       TO 'role_admin';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_EditarSimulacao      TO 'role_admin';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_IniciarSimulacao     TO 'role_admin';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_TerminarSimulacao    TO 'role_admin';

-- USER: read all, simulation management via SPs only — no direct INSERT
GRANT SELECT ON simulacao_labirinto.* TO 'role_user';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_AtualizarProprioPerfil TO 'role_user';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_CriarSimulacao       TO 'role_user';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_EditarSimulacao      TO 'role_user';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_IniciarSimulacao     TO 'role_user';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_TerminarSimulacao    TO 'role_user';

-- MQTT: insert sensor data, update maze state, handle scoring
GRANT INSERT ON simulacao_labirinto.Mensagem           TO 'role_mqtt';
GRANT INSERT ON simulacao_labirinto.MedicoesPassagens  TO 'role_mqtt';
GRANT INSERT ON simulacao_labirinto.Temperatura        TO 'role_mqtt';
GRANT INSERT ON simulacao_labirinto.Som                TO 'role_mqtt';
GRANT SELECT, UPDATE ON simulacao_labirinto.Marsami             TO 'role_mqtt';
GRANT SELECT, UPDATE ON simulacao_labirinto.OcupacaoLabirinto   TO 'role_mqtt';
GRANT SELECT, UPDATE ON simulacao_labirinto.Simulacao           TO 'role_mqtt';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_RegistarPassagem TO 'role_mqtt';

-- ALERTA: read sensor data and simulation state, terminate simulation
GRANT SELECT ON simulacao_labirinto.Simulacao          TO 'role_alerta';
GRANT SELECT ON simulacao_labirinto.Mensagem           TO 'role_alerta';
GRANT SELECT ON simulacao_labirinto.MedicoesPassagens  TO 'role_alerta';
GRANT SELECT ON simulacao_labirinto.Temperatura        TO 'role_alerta';
GRANT SELECT ON simulacao_labirinto.Som                TO 'role_alerta';
GRANT SELECT ON simulacao_labirinto.Marsami            TO 'role_alerta';
GRANT SELECT ON simulacao_labirinto.OcupacaoLabirinto  TO 'role_alerta';
GRANT UPDATE ON simulacao_labirinto.Simulacao          TO 'role_alerta';
GRANT EXECUTE ON PROCEDURE simulacao_labirinto.sp_TerminarSimulacao TO 'role_alerta';
