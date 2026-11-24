DROP DATABASE IF EXISTS hotel_nebula;
CREATE DATABASE hotel_nebula CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE hotel_nebula;

CREATE TABLE hospedes (
  id_hospede      INT PRIMARY KEY AUTO_INCREMENT,
  nome            VARCHAR(100) NOT NULL,
  email           VARCHAR(100) NOT NULL UNIQUE,
  cpf             VARCHAR(14) UNIQUE,
  documento       VARCHAR(30),  -- passaporte pra estrangeiro
  telefone        VARCHAR(20),
  data_nascimento DATE,
  cidade          VARCHAR(60),
  pais            VARCHAR(60) NOT NULL DEFAULT 'Brasil',
  data_cadastro   DATE NOT NULL DEFAULT (CURRENT_DATE),
  CHECK (cpf IS NOT NULL OR documento IS NOT NULL)
);

CREATE TABLE quartos (
  id_quarto    INT PRIMARY KEY AUTO_INCREMENT,
  numero       VARCHAR(10) NOT NULL UNIQUE,
  andar        INT NOT NULL,
  tipo         VARCHAR(50) NOT NULL,
  capacidade   INT NOT NULL,
  preco_diaria DECIMAL(10,2) NOT NULL,
  status       VARCHAR(20) NOT NULL DEFAULT 'DISPONIVEL',
  descricao    VARCHAR(255),
  CHECK (tipo IN ('STANDARD', 'LUXO', 'SUITE', 'FAMILIA')),
  CHECK (capacidade BETWEEN 1 AND 6),
  CHECK (preco_diaria > 0),
  CHECK (status IN ('DISPONIVEL', 'MANUTENCAO', 'INATIVO'))
);

CREATE TABLE funcionarios (
  id_funcionario INT PRIMARY KEY AUTO_INCREMENT,
  nome           VARCHAR(100) NOT NULL,
  cargo          VARCHAR(50) NOT NULL,
  email          VARCHAR(100) NOT NULL UNIQUE,
  telefone       VARCHAR(20),
  data_admissao  DATE NOT NULL,
  salario        DECIMAL(10,2) NOT NULL,
  ativo          BOOLEAN NOT NULL DEFAULT TRUE,
  CHECK (salario > 0)
);

CREATE TABLE reservas (
  id_reserva          INT PRIMARY KEY AUTO_INCREMENT,
  id_hospede          INT NOT NULL,
  id_quarto           INT NOT NULL,
  id_funcionario      INT,  -- null quando foi pelo site
  data_reserva        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  data_checkin        DATE NOT NULL,
  data_checkout       DATE NOT NULL,
  qtd_hospedes        INT NOT NULL DEFAULT 1,
  valor_diaria        DECIMAL(10,2) NOT NULL,
  canal               VARCHAR(20) NOT NULL DEFAULT 'SITE',
  status              VARCHAR(20) NOT NULL DEFAULT 'CONFIRMADA',
  data_cancelamento   DATETIME,
  motivo_cancelamento VARCHAR(255),
  CHECK (data_checkout > data_checkin),
  CHECK (qtd_hospedes > 0),
  CHECK (valor_diaria > 0),
  CHECK (canal IN ('SITE', 'TELEFONE', 'BALCAO', 'AGENCIA')),
  CHECK (status IN ('PENDENTE', 'CONFIRMADA', 'CANCELADA', 'CONCLUIDA')),
  CHECK (status <> 'CANCELADA' OR data_cancelamento IS NOT NULL),
  CONSTRAINT fk_reserva_hospede FOREIGN KEY (id_hospede) REFERENCES hospedes(id_hospede)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_reserva_quarto FOREIGN KEY (id_quarto) REFERENCES quartos(id_quarto)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_reserva_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE hospedagens (
  id_hospedagem  INT PRIMARY KEY AUTO_INCREMENT,
  id_reserva     INT NOT NULL UNIQUE,
  id_funcionario INT NOT NULL,  -- quem fez o check-in
  checkin_real   DATETIME NOT NULL,
  checkout_real  DATETIME,      -- null = ainda ta hospedado
  observacoes    VARCHAR(255),
  CHECK (checkout_real IS NULL OR checkout_real > checkin_real),
  CONSTRAINT fk_hospedagem_reserva FOREIGN KEY (id_reserva) REFERENCES reservas(id_reserva)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_hospedagem_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE servicos (
  id_servico INT PRIMARY KEY AUTO_INCREMENT,
  nome       VARCHAR(80) NOT NULL UNIQUE,
  categoria  VARCHAR(30) NOT NULL,
  descricao  VARCHAR(255),
  preco      DECIMAL(10,2) NOT NULL,
  ativo      BOOLEAN NOT NULL DEFAULT TRUE,
  CHECK (preco >= 0),
  CHECK (categoria IN ('ALIMENTACAO', 'BEM-ESTAR', 'TRANSPORTE', 'LAVANDERIA', 'LAZER'))
);

CREATE TABLE hospedagem_servicos (
  id_consumo     INT PRIMARY KEY AUTO_INCREMENT,
  id_hospedagem  INT NOT NULL,
  id_servico     INT NOT NULL,
  id_funcionario INT,
  data_consumo   DATETIME NOT NULL,
  quantidade     INT NOT NULL DEFAULT 1,
  preco_unitario DECIMAL(10,2) NOT NULL,
  CHECK (quantidade > 0),
  CHECK (preco_unitario >= 0),
  CONSTRAINT fk_consumo_hospedagem FOREIGN KEY (id_hospedagem) REFERENCES hospedagens(id_hospedagem)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_consumo_servico FOREIGN KEY (id_servico) REFERENCES servicos(id_servico)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_consumo_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE pagamentos (
  id_pagamento   INT PRIMARY KEY AUTO_INCREMENT,
  id_hospedagem  INT NOT NULL,
  data_pagamento DATETIME NOT NULL,
  valor          DECIMAL(10,2) NOT NULL,
  metodo         VARCHAR(30) NOT NULL,
  parcelas       INT NOT NULL DEFAULT 1,
  status         VARCHAR(20) NOT NULL DEFAULT 'APROVADO',
  CHECK (valor > 0),
  CHECK (metodo IN ('PIX', 'CREDITO', 'DEBITO', 'DINHEIRO')),
  CHECK (parcelas BETWEEN 1 AND 12),
  CHECK (metodo = 'CREDITO' OR parcelas = 1),
  CHECK (status IN ('PENDENTE', 'APROVADO', 'ESTORNADO')),
  CONSTRAINT fk_pagamento_hospedagem FOREIGN KEY (id_hospedagem) REFERENCES hospedagens(id_hospedagem)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE feedbacks (
  id_feedback      INT PRIMARY KEY AUTO_INCREMENT,
  id_hospedagem    INT NOT NULL UNIQUE,
  data_feedback    DATETIME NOT NULL,
  nota_geral       TINYINT NOT NULL,
  nota_limpeza     TINYINT,
  nota_atendimento TINYINT,
  comentario       TEXT,
  CHECK (nota_geral BETWEEN 1 AND 5),
  CHECK (nota_limpeza IS NULL OR nota_limpeza BETWEEN 1 AND 5),
  CHECK (nota_atendimento IS NULL OR nota_atendimento BETWEEN 1 AND 5),
  CONSTRAINT fk_feedback_hospedagem FOREIGN KEY (id_hospedagem) REFERENCES hospedagens(id_hospedagem)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX idx_reservas_periodo ON reservas (id_quarto, data_checkin, data_checkout);
CREATE INDEX idx_pagamentos_data ON pagamentos (data_pagamento);
