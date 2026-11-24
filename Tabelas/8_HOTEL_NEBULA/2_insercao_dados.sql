USE hotel_nebula;

INSERT INTO quartos (numero, andar, tipo, capacidade, preco_diaria, status, descricao) VALUES
('101', 1, 'STANDARD', 2, 250.00, 'DISPONIVEL', 'Cama de casal, vista para o jardim'),
('102', 1, 'STANDARD', 2, 250.00, 'DISPONIVEL', 'Duas camas de solteiro'),
('103', 1, 'FAMILIA',  4, 420.00, 'DISPONIVEL', 'Casal + beliche'),
('201', 2, 'LUXO',     2, 380.00, 'DISPONIVEL', 'Varanda e banheira'),
('202', 2, 'LUXO',     3, 400.00, 'DISPONIVEL', 'Varanda, casal + solteiro'),
('203', 2, 'STANDARD', 2, 260.00, 'MANUTENCAO', 'Ar-condicionado em conserto'),
('301', 3, 'SUITE',    2, 650.00, 'DISPONIVEL', 'Suíte com hidromassagem'),
('302', 3, 'SUITE',    4, 780.00, 'DISPONIVEL', 'Suíte com sala de estar'),
('303', 3, 'FAMILIA',  5, 480.00, 'DISPONIVEL', 'Dois quartos conjugados'),
('401', 4, 'SUITE',    2, 950.00, 'DISPONIVEL', 'Suíte Nebula: cobertura com teto de vidro');

INSERT INTO funcionarios (nome, cargo, email, telefone, data_admissao, salario) VALUES
('Lúcia Andrade',  'Recepcionista',          'lucia.andrade@hotelnebula.com',  '(11) 98000-0001', '2021-03-01', 2800.00),
('Rafael Moreira', 'Recepcionista',          'rafael.moreira@hotelnebula.com', '(11) 98000-0002', '2022-07-15', 2800.00),
('Bruno Tavares',  'Recepcionista Noturno',  'bruno.tavares@hotelnebula.com',  '(11) 98000-0003', '2023-01-10', 3100.00),
('Helena Duarte',  'Gerente',                'helena.duarte@hotelnebula.com',  '(11) 98000-0004', '2019-05-20', 7500.00),
('Joana Prado',    'Camareira',              'joana.prado@hotelnebula.com',    '(11) 98000-0005', '2020-09-01', 2200.00),
('Camila Rocha',   'Massoterapeuta',         'camila.rocha@hotelnebula.com',   '(11) 98000-0006', '2022-02-14', 3400.00),
('Diego Freitas',  'Motorista',              'diego.freitas@hotelnebula.com',  '(11) 98000-0007', '2021-11-03', 2600.00),
('Marcos Lima',    'Garçom',                 'marcos.lima@hotelnebula.com',    '(11) 98000-0008', '2023-06-01', 2300.00);

INSERT INTO hospedes (nome, email, cpf, documento, telefone, data_nascimento, cidade, pais, data_cadastro) VALUES
('Ana Beatriz Souza',  'ana.souza@email.com',      '111.222.333-01', NULL,          '(11) 99100-0001', '1990-04-12', 'São Paulo',      'Brasil',    '2026-01-02'),
('Carlos Mendes',      'carlos.mendes@email.com',  '111.222.333-02', NULL,          '(21) 99100-0002', '1985-09-30', 'Rio de Janeiro', 'Brasil',    '2026-01-05'),
('Fernanda Lopes',     'fernanda.lopes@email.com', '111.222.333-03', NULL,          '(31) 99100-0003', '1982-01-18', 'Belo Horizonte', 'Brasil',    '2026-01-20'),
('Ricardo Almeida',    'ricardo.almeida@email.com','111.222.333-04', NULL,          '(41) 99100-0004', '1978-07-05', 'Curitiba',       'Brasil',    '2026-02-10'),
('Juliana Castro',     'juliana.castro@email.com', '111.222.333-05', NULL,          '(11) 99100-0005', '1995-11-22', 'Campinas',       'Brasil',    '2026-02-15'),
('John Carter',        'john.carter@email.com',    NULL,             'US-P1234567', '+1 555 010 0006', '1988-03-03', 'Chicago',        'EUA',       '2026-03-01'),
('Mariana Ribeiro',    'mariana.ribeiro@email.com','111.222.333-07', NULL,          '(51) 99100-0007', '1987-06-14', 'Porto Alegre',   'Brasil',    '2026-03-20'),
('Sofia Martínez',     'sofia.martinez@email.com', NULL,             'AR-AB998877', '+54 11 5555 0008','1993-12-01', 'Buenos Aires',   'Argentina', '2026-04-20'),
('Pedro Henrique Lima','pedro.lima@email.com',     '111.222.333-09', NULL,          '(81) 99100-0009', '1980-02-27', 'Recife',         'Brasil',    '2026-05-10'),
('Larissa Nogueira',   'larissa.nogueira@email.com','111.222.333-10',NULL,          '(71) 99100-0010', '1998-08-08', 'Salvador',       'Brasil',    '2026-06-01'),
('Thiago Barbosa',     'thiago.barbosa@email.com', '111.222.333-11', NULL,          '(61) 99100-0011', '1991-10-19', 'Brasília',       'Brasil',    '2026-06-20'),
('Yuki Tanaka',        'yuki.tanaka@email.com',    NULL,             'JP-TK554433', '+81 3 5555 0012', '1975-05-05', 'Tóquio',         'Japão',     '2026-08-01');

INSERT INTO servicos (nome, categoria, descricao, preco) VALUES
('Café da manhã no quarto',  'ALIMENTACAO', 'Café completo servido no quarto (por pessoa)', 45.00),
('Jantar no restaurante',    'ALIMENTACAO', 'Menu degustação do restaurante Órbita',         120.00),
('Frigobar',                 'ALIMENTACAO', 'Consumo de frigobar (por item)',                 30.00),
('Massagem relaxante',       'BEM-ESTAR',   '50 minutos',                                    180.00),
('Day spa',                  'BEM-ESTAR',   'Circuito completo de spa',                      350.00),
('Transfer aeroporto',       'TRANSPORTE',  'Ida ou volta, até 4 pessoas',                   150.00),
('Lavanderia',               'LAVANDERIA',  'Por peça',                                       20.00),
('Noite no observatório',    'LAZER',       'Observação do céu no terraço com telescópio',   200.00);

-- reservas
INSERT INTO reservas (id_hospede, id_quarto, id_funcionario, data_reserva, data_checkin, data_checkout, qtd_hospedes, valor_diaria, canal, status, data_cancelamento, motivo_cancelamento) VALUES
( 1,  1, 1,    '2026-01-02 10:00', '2026-01-10', '2026-01-13', 2, 250.00, 'BALCAO',   'CONCLUIDA',  NULL, NULL),
( 2,  7, NULL, '2026-01-05 21:15', '2026-01-15', '2026-01-18', 2, 650.00, 'SITE',     'CONCLUIDA',  NULL, NULL),
( 3,  3, 2,    '2026-01-20 09:30', '2026-02-01', '2026-02-05', 4, 420.00, 'TELEFONE', 'CONCLUIDA',  NULL, NULL),
( 1,  4, NULL, '2026-02-01 18:40', '2026-02-14', '2026-02-16', 2, 380.00, 'SITE',     'CONCLUIDA',  NULL, NULL),
( 4,  8, NULL, '2026-02-10 14:00', '2026-03-01', '2026-03-05', 4, 780.00, 'AGENCIA',  'CONCLUIDA',  NULL, NULL),
( 5,  2, 1,    '2026-02-15 11:20', '2026-03-10', '2026-03-12', 1, 250.00, 'BALCAO',   'CANCELADA',  '2026-03-05 16:00', 'Mudança de planos'),
( 6, 10, NULL, '2026-03-01 08:05', '2026-03-20', '2026-03-23', 2, 950.00, 'SITE',     'CONCLUIDA',  NULL, NULL),
( 2,  5, NULL, '2026-03-15 22:10', '2026-04-02', '2026-04-06', 3, 400.00, 'SITE',     'CONCLUIDA',  NULL, NULL),
( 7,  9, 2,    '2026-03-20 15:45', '2026-04-10', '2026-04-15', 5, 480.00, 'TELEFONE', 'CONCLUIDA',  NULL, NULL),
( 3,  1, NULL, '2026-04-01 19:00', '2026-04-18', '2026-04-20', 2, 250.00, 'SITE',     'CANCELADA',  '2026-04-10 07:30', 'Voo cancelado'),
( 8,  7, NULL, '2026-04-20 13:00', '2026-05-01', '2026-05-04', 2, 650.00, 'AGENCIA',  'CONCLUIDA',  NULL, NULL),
( 1, 10, 4,    '2026-05-02 10:10', '2026-05-20', '2026-05-22', 2, 950.00, 'BALCAO',   'CONCLUIDA',  NULL, NULL),
( 9,  3, NULL, '2026-05-10 20:30', '2026-06-05', '2026-06-09', 3, 420.00, 'SITE',     'CONCLUIDA',  NULL, NULL),
(10,  4, NULL, '2026-06-01 12:00', '2026-06-12', '2026-06-15', 2, 380.00, 'SITE',     'CANCELADA',  '2026-06-10 09:00', 'Problema de saúde'),
( 4,  8, 2,    '2026-06-10 16:20', '2026-07-03', '2026-07-10', 4, 780.00, 'AGENCIA',  'CONCLUIDA',  NULL, NULL),
(11,  2, NULL, '2026-06-20 23:50', '2026-07-15', '2026-07-17', 1, 260.00, 'SITE',     'CONCLUIDA',  NULL, NULL),
( 2,  7, NULL, '2026-07-10 10:00', '2026-08-08', '2026-08-11', 2, 650.00, 'SITE',     'CONCLUIDA',  NULL, NULL),
(12,  5, 1,    '2026-08-01 09:15', '2026-08-20', '2026-08-23', 3, 400.00, 'TELEFONE', 'CONCLUIDA',  NULL, NULL),
( 6, 10, NULL, '2026-08-15 17:30', '2026-09-10', '2026-09-13', 2, 950.00, 'SITE',     'CANCELADA',  '2026-09-01 10:45', 'Encontrou preço melhor'),
( 7,  9, NULL, '2026-09-05 14:10', '2026-10-01', '2026-10-04', 4, 480.00, 'SITE',     'CONCLUIDA',  NULL, NULL),
( 1,  1, 3,    '2026-10-10 02:00', '2026-10-24', '2026-10-26', 2, 250.00, 'BALCAO',   'CONCLUIDA',  NULL, NULL),
( 5,  4, NULL, '2026-11-01 18:00', '2026-11-21', '2026-11-25', 2, 380.00, 'SITE',     'CONFIRMADA', NULL, NULL),
( 8,  7, NULL, '2026-11-10 11:00', '2026-12-20', '2026-12-27', 2, 650.00, 'AGENCIA',  'CONFIRMADA', NULL, NULL),
( 3,  3, NULL, '2026-11-15 20:00', '2026-12-22', '2026-12-26', 4, 450.00, 'SITE',     'CONFIRMADA', NULL, NULL),
(10,  8, 2,    '2026-11-18 15:00', '2026-12-28', '2027-01-02', 4, 820.00, 'TELEFONE', 'PENDENTE',   NULL, NULL),
( 9, 10, NULL, '2026-11-20 21:00', '2026-12-23', '2026-12-26', 2, 990.00, 'SITE',     'CONFIRMADA', NULL, NULL);

-- hospedagens (so das reservas concluidas + 1 que ta hospedada agora)
INSERT INTO hospedagens (id_reserva, id_funcionario, checkin_real, checkout_real, observacoes) VALUES
( 1, 1, '2026-01-10 14:05', '2026-01-13 11:00', NULL),
( 2, 2, '2026-01-15 15:30', '2026-01-18 10:40', 'Aniversário de casamento'),
( 3, 1, '2026-02-01 13:50', '2026-02-05 11:20', 'Pediram berço extra'),
( 4, 3, '2026-02-14 22:15', '2026-02-16 12:00', 'Chegada tarde, voo atrasado'),
( 5, 2, '2026-03-01 14:00', '2026-03-05 10:55', NULL),
( 7, 4, '2026-03-20 16:10', '2026-03-23 11:30', 'Hóspede estrangeiro, check-in em inglês'),
( 8, 1, '2026-04-02 14:20', '2026-04-06 11:05', NULL),
( 9, 2, '2026-04-10 15:00', '2026-04-15 10:30', NULL),
(11, 1, '2026-05-01 14:45', '2026-05-04 11:10', NULL),
(12, 4, '2026-05-20 14:00', '2026-05-22 11:00', 'Cliente recorrente, upgrade de cortesia'),
(13, 3, '2026-06-05 23:40', '2026-06-09 11:45', NULL),
(15, 2, '2026-07-03 14:10', '2026-07-10 10:50', 'Férias em família'),
(16, 1, '2026-07-15 13:30', '2026-07-17 09:15', 'Viagem a trabalho'),
(17, 2, '2026-08-08 14:35', '2026-08-11 11:00', NULL),
(18, 1, '2026-08-20 15:15', '2026-08-23 10:20', NULL),
(20, 3, '2026-10-01 22:30', '2026-10-04 11:40', NULL),
(21, 1, '2026-10-24 14:00', '2026-10-26 11:00', NULL),
(22, 2, '2026-11-21 14:25', NULL,               'Ainda hospedada');

-- consumo de servicos
INSERT INTO hospedagem_servicos (id_hospedagem, id_servico, id_funcionario, data_consumo, quantidade, preco_unitario) VALUES
( 1, 1, 8, '2026-01-11 08:00', 2,  45.00),
( 1, 3, 5, '2026-01-12 20:00', 3,  30.00),
( 2, 2, 8, '2026-01-15 20:30', 2, 120.00),
( 2, 4, 6, '2026-01-16 16:00', 2, 180.00),
( 2, 8, 4, '2026-01-16 22:00', 2, 200.00),
( 3, 1, 8, '2026-02-02 08:30', 4,  45.00),
( 3, 1, 8, '2026-02-03 08:30', 4,  45.00),
( 3, 7, 5, '2026-02-03 10:00', 6,  20.00),
( 4, 2, 8, '2026-02-14 23:00', 2, 120.00),
( 4, 1, 8, '2026-02-15 09:00', 2,  45.00),
( 5, 6, 7, '2026-03-01 11:00', 1, 150.00),
( 5, 5, 6, '2026-03-03 10:00', 2, 350.00),
( 5, 3, 5, '2026-03-04 21:00', 5,  30.00),
( 5, 6, 7, '2026-03-05 11:30', 1, 150.00),
( 6, 6, 7, '2026-03-20 14:00', 1, 150.00),
( 6, 8, 4, '2026-03-21 22:00', 2, 200.00),
( 6, 2, 8, '2026-03-22 20:00', 2, 120.00),
( 7, 1, 8, '2026-04-03 08:00', 3,  45.00),
( 7, 3, 5, '2026-04-04 19:00', 2,  30.00),
( 8, 1, 8, '2026-04-11 08:15', 5,  45.00),
( 8, 8, 4, '2026-04-12 22:00', 5, 200.00),
( 9, 4, 6, '2026-05-02 15:00', 2, 180.00),
( 9, 1, 8, '2026-05-03 08:00', 2,  45.00),
(10, 5, 6, '2026-05-21 10:00', 2, 350.00),
(10, 2, 8, '2026-05-21 20:30', 2, 120.00),
(11, 1, 8, '2026-06-06 08:00', 3,  45.00),
(11, 3, 5, '2026-06-07 22:00', 4,  30.00),
(12, 1, 8, '2026-07-04 08:00', 4,  48.00),
(12, 1, 8, '2026-07-06 08:00', 4,  48.00),
(12, 7, 5, '2026-07-07 10:00', 8,  20.00),
(12, 8, 4, '2026-07-08 22:00', 4, 200.00),
(13, 7, 5, '2026-07-16 09:00', 3,  20.00),
(14, 4, 6, '2026-08-09 15:00', 2, 180.00),
(14, 8, 4, '2026-08-09 22:00', 2, 200.00),
(15, 6, 7, '2026-08-20 13:00', 1, 150.00),
(15, 1, 8, '2026-08-21 08:00', 3,  48.00),
(16, 1, 8, '2026-10-02 08:00', 4,  48.00),
(16, 3, 5, '2026-10-03 20:00', 2,  30.00),
(17, 1, 8, '2026-10-25 08:00', 2,  48.00),
(18, 3, 5, '2026-11-22 21:00', 2,  30.00);

-- pagamentos
-- valor = diarias + servicos de cada hospedagem que ja fez checkout
INSERT INTO pagamentos (id_hospedagem, data_pagamento, valor, metodo, parcelas, status)
SELECT h.id_hospedagem,
       h.checkout_real,
       DATEDIFF(r.data_checkout, r.data_checkin) * r.valor_diaria
         + COALESCE((SELECT SUM(hs.quantidade * hs.preco_unitario) FROM hospedagem_servicos hs WHERE hs.id_hospedagem = h.id_hospedagem), 0),
       CASE MOD(h.id_hospedagem, 4) WHEN 0 THEN 'PIX' WHEN 1 THEN 'CREDITO' WHEN 2 THEN 'DEBITO' ELSE 'CREDITO' END,
       CASE WHEN MOD(h.id_hospedagem, 4) = 3 THEN 3 ELSE 1 END,
       'APROVADO'
FROM hospedagens h
JOIN reservas r ON r.id_reserva = h.id_reserva
WHERE h.checkout_real IS NOT NULL;

-- estorno, sinal e um pendente
INSERT INTO pagamentos (id_hospedagem, data_pagamento, valor, metodo, parcelas, status) VALUES
( 6, '2026-03-23 11:35', 240.00, 'CREDITO', 1, 'ESTORNADO'),
(18, '2026-11-21 14:30', 760.00, 'PIX',     1, 'APROVADO'),
(18, '2026-11-22 21:05',  60.00, 'DEBITO',  1, 'PENDENTE');

-- feedbacks
INSERT INTO feedbacks (id_hospedagem, data_feedback, nota_geral, nota_limpeza, nota_atendimento, comentario) VALUES
( 1, '2026-01-13 18:00', 4, 4, 5, 'Quarto simples mas muito limpo. Recepção super atenciosa.'),
( 2, '2026-01-19 10:00', 5, 5, 5, 'A noite no observatório foi inesquecível!'),
( 3, '2026-02-06 09:00', 4, 4, 4, 'Bom pra família, só o café demorou um pouco.'),
( 4, '2026-02-17 12:00', 5, 5, 4, 'Banheira maravilhosa.'),
( 5, '2026-03-06 15:00', 5, 5, 5, 'Suíte enorme, o spa vale cada centavo.'),
( 6, '2026-03-24 08:00', 3, 5, 2, 'Room was amazing, but I was charged twice for dinner.'),
( 7, '2026-04-07 20:00', 4, 4, 5, NULL),
( 8, '2026-04-16 11:00', 5, 4, 5, 'Crianças adoraram o telescópio.'),
( 9, '2026-05-05 10:00', 5, 5, 5, 'Excelente, volto com certeza.'),
(10, '2026-05-23 09:30', 5, 5, 5, 'Melhor quarto do hotel, a vista do teto de vidro é linda.'),
(11, '2026-06-10 14:00', 3, 3, 4, 'Ar-condicionado barulhento.'),
(12, '2026-07-11 16:00', 4, 4, 4, 'Ótimo para férias, mas o café subiu de preço.'),
(13, '2026-07-17 19:00', 2, 2, 3, 'Encontrei o quarto com poeira e a toalha manchada.'),
(15, '2026-08-24 07:00', 4, 5, 4, 'Very clean and quiet.'),
(17, '2026-10-27 10:00', 4, 4, 5, 'Sempre bem recebida.');
