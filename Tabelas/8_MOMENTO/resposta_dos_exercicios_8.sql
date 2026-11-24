USE momento;
SET SQL_SAFE_UPDATES = 0;

-- 1.1 Me incluindo no sistema (TI, Desenvolvedor Web, 5500 USD)

INSERT INTO funcionarios (funcionario_id, primeiro_nome, sobrenome, email, telefone, data_contratacao, cargo_id, salario, moeda_salario, gerente_id, departamento_id, status_funcionario_id)
VALUES (222, 'Vinicius', 'Araujo', 'vinicius.araujo@momento.org', '+55-11-90000-0222', CURDATE(),
        (SELECT cargo_id FROM cargos WHERE cargo_nome = 'Desenvolvedor Web'), 5500.00, 'USD', 103,
        (SELECT departamento_id FROM departamentos WHERE departamento_nome = 'Tecnologia da Informação'), 1);

SELECT * FROM funcionarios WHERE funcionario_id = 222;


-- 6.1 Novo departamento Inovações no Wayne Offices

INSERT INTO departamentos (departamento_id, departamento_nome, educacional, escritorio_id)
VALUES (31, 'Inovações', 0, (SELECT escritorio_id FROM escritorios WHERE escritorio_nome = 'Wayne Offices'));

SELECT * FROM departamentos WHERE departamento_nome = 'Inovações';


-- 6.2 Transferir 2 de TI para Inovações (Peter Parker e Samus Aran)

SELECT funcionario_id, primeiro_nome, sobrenome, cargo_id FROM funcionarios WHERE departamento_id = 6;
UPDATE funcionarios SET departamento_id = 31 WHERE funcionario_id IN (139, 144);
SELECT funcionario_id, primeiro_nome, sobrenome, departamento_id FROM funcionarios WHERE departamento_id = 31;


-- 6.3 Aumento de 10% para TI

SELECT funcionario_id, primeiro_nome, salario FROM funcionarios WHERE departamento_id = 6;
UPDATE funcionarios SET salario = ROUND(salario * 1.10, 2) WHERE departamento_id = 6;
SELECT funcionario_id, primeiro_nome, salario FROM funcionarios WHERE departamento_id = 6;


-- 6.4 Bruce Ernst promovido a Senior Web Developer com 5000
-- obs: ele ganhava 6600 depois do 6.3, então 5000 é redução e fica abaixo do mínimo do cargo (7000)

UPDATE funcionarios
SET cargo_id = (SELECT cargo_id FROM cargos WHERE cargo_nome = 'Senior Web Developer'),
    salario = 5000.00
WHERE primeiro_nome = 'Bruce' AND sobrenome = 'Ernst';

SELECT * FROM radar_salarial WHERE funcionario_nome = 'Bruce Ernst';


-- 6.5 15 Headsets a 150 no Wayne Offices

INSERT INTO suprimentos (suprimento_id, referencia_compra, suprimento_nome, quantidade_estoque, custo_unitario, moeda, data_compra, escritorio_id)
VALUES (106, 'PO-1400-08', 'Headsets', 15, 150.00, 'USD', CURDATE(),
        (SELECT escritorio_id FROM escritorios WHERE escritorio_nome = 'Wayne Offices'));

SELECT * FROM suprimentos WHERE escritorio_id = 1400 AND suprimento_nome = 'Headsets';


-- 6.6 Aposentar quem foi contratado antes de 1990
-- primeiro o SELECT (8 pessoas)

SELECT funcionario_id, primeiro_nome, sobrenome, data_contratacao
FROM funcionarios
WHERE data_contratacao < '1990-01-01';

-- o que está ligado a eles
SELECT 'dependentes', COUNT(*) FROM dependentes WHERE funcionario_id IN (SELECT funcionario_id FROM funcionarios WHERE data_contratacao < '1990-01-01')
UNION ALL
SELECT 'audit_log', COUNT(*) FROM audit_log WHERE funcionario_id IN (SELECT funcionario_id FROM funcionarios WHERE data_contratacao < '1990-01-01');

-- o DELETE dá ERROR 1451 por causa da FK de dependentes (ON DELETE RESTRICT)
-- deixei comentado pra não parar o script. O jeito certo é INATIVO (nível 12)
-- DELETE FROM funcionarios WHERE data_contratacao < '1990-01-01';


-- ===== NÍVEL 11: ETL DO CSV =====

-- 11.1 EXTRACT: carregar o CSV como chegou (sem converter nada)
-- (no Workbench também dá pelo Table Data Import Wizard, delimitador ;)
-- troque pelo caminho do arquivo na sua máquina. Precisa do local_infile ligado:
-- SET GLOBAL local_infile = 1;  e na conexão do Workbench: OPT_LOCAL_INFILE=1
LOAD DATA LOCAL INFILE 'vendas_campanha_bruto.csv'
INTO TABLE stg_vendas_csv
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(source_row_id, lote_origem, pedido_ref, item_seq, data_venda_raw, locale_origem, sku_raw,
 quantidade_raw, preco_unitario_raw, moeda_raw, email_vendedor_raw, canal_raw, status_raw);

-- conferir: tem que dar 28 linhas
SELECT COUNT(*) AS linhas_importadas FROM stg_vendas_csv;
SELECT * FROM stg_vendas_csv;

-- 11.2 TRANSFORM
-- o status 2 da tabela status_venda veio com o nome '1' (erro da base). Corrigindo para PENDENTE
UPDATE status_venda SET nome = 'PENDENTE' WHERE status_venda_id = 2;

-- tabela de trabalho com os campos já convertidos (a stg continua intacta)
CREATE TABLE stg_vendas_tratada (
  source_row_id INT PRIMARY KEY,
  pedido_ref VARCHAR(48),
  item_seq INT,
  locale_origem VARCHAR(20),
  data_venda DATE,
  sku VARCHAR(40),
  produto_id INT,
  quantidade INT,
  preco_unitario DECIMAL(10,2),
  moeda CHAR(3),
  email_vendedor VARCHAR(128),
  funcionario_id INT,
  canal_venda_id TINYINT,
  status_venda_id TINYINT,
  situacao VARCHAR(16) DEFAULT 'OK',
  campo_problema VARCHAR(48),
  motivo VARCHAR(255)
);

INSERT INTO stg_vendas_tratada (source_row_id, pedido_ref, item_seq, locale_origem, sku, quantidade, moeda, email_vendedor, canal_venda_id, status_venda_id)
SELECT s.source_row_id,
       TRIM(s.pedido_ref),
       CAST(s.item_seq AS UNSIGNED),
       TRIM(s.locale_origem),
       UPPER(TRIM(s.sku_raw)),
       -- quantidade: só converte se for número inteiro (com sinal)
       CASE WHEN TRIM(s.quantidade_raw) REGEXP '^-?[0-9]+$' THEN CAST(TRIM(s.quantidade_raw) AS SIGNED) END,
       -- moeda: só aceita as moedas que a empresa usa
       CASE WHEN UPPER(TRIM(s.moeda_raw)) IN ('USD', 'BRL', 'EUR', 'GBP') THEN UPPER(TRIM(s.moeda_raw)) END,
       LOWER(TRIM(s.email_vendedor_raw)),
       -- canal padronizado
       CASE LOWER(TRIM(s.canal_raw))
            WHEN 'web' THEN 2 WHEN 'online' THEN 2
            WHEN 'loja' THEN 1 WHEN 'loja física' THEN 1
            WHEN 'app' THEN 3
            WHEN 'marketplace' THEN 4
            WHEN 'b2b' THEN 5
       END,
       -- status padronizado
       CASE LOWER(TRIM(s.status_raw))
            WHEN 'paid' THEN 1 WHEN 'pago' THEN 1 WHEN 'concluída' THEN 1 WHEN 'concluida' THEN 1
            WHEN 'pending' THEN 2 WHEN 'pendente' THEN 2
            WHEN 'cancelado' THEN 3 WHEN 'cancelada' THEN 3
       END
FROM stg_vendas_csv s;

-- data: interpretar de acordo com o locale (ISO = aaaa-mm-dd, pt-BR = dd/mm/aaaa, en-US = mm/dd/aaaa)
-- antes de converter confere se o dia existe naquele mês (31/02 não existe)
UPDATE stg_vendas_tratada t
JOIN (
  SELECT source_row_id,
         CASE
           WHEN locale_origem = 'ISO'   AND data_venda_raw REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
             THEN CONCAT(SUBSTRING(data_venda_raw, 1, 4), '-', SUBSTRING(data_venda_raw, 6, 2), '-', SUBSTRING(data_venda_raw, 9, 2))
           WHEN locale_origem = 'pt-BR' AND data_venda_raw REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
             THEN CONCAT(SUBSTRING(data_venda_raw, 7, 4), '-', SUBSTRING(data_venda_raw, 4, 2), '-', SUBSTRING(data_venda_raw, 1, 2))
           WHEN locale_origem = 'en-US' AND data_venda_raw REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
             THEN CONCAT(SUBSTRING(data_venda_raw, 7, 4), '-', SUBSTRING(data_venda_raw, 1, 2), '-', SUBSTRING(data_venda_raw, 4, 2))
         END AS data_txt
  FROM stg_vendas_csv
) d ON d.source_row_id = t.source_row_id
SET t.data_venda = d.data_txt
WHERE d.data_txt IS NOT NULL
  AND SUBSTRING(d.data_txt, 6, 2) BETWEEN '01' AND '12'
  AND CAST(SUBSTRING(d.data_txt, 9, 2) AS UNSIGNED) BETWEEN 1 AND DAY(LAST_DAY(CONCAT(SUBSTRING(d.data_txt, 1, 7), '-01')));

-- preço: tira símbolo de moeda e espaços; pt-BR usa ponto no milhar e vírgula no decimal, ISO/en-US usam vírgula no milhar
UPDATE stg_vendas_tratada t
JOIN (
  SELECT source_row_id, locale_origem,
         TRIM(REPLACE(REPLACE(REPLACE(preco_unitario_raw, 'US$', ''), 'R$', ''), '$', '')) AS preco_txt
  FROM stg_vendas_csv
) p ON p.source_row_id = t.source_row_id
SET t.preco_unitario = CASE
      WHEN p.locale_origem = 'pt-BR' AND p.preco_txt REGEXP '^[0-9]{1,3}(\\.[0-9]{3})*(,[0-9]{1,2})?$'
        THEN CAST(REPLACE(REPLACE(p.preco_txt, '.', ''), ',', '.') AS DECIMAL(10,2))
      WHEN p.locale_origem IN ('ISO', 'en-US') AND p.preco_txt REGEXP '^[0-9]{1,3}(,[0-9]{3})*(\\.[0-9]{1,2})?$'
        THEN CAST(REPLACE(p.preco_txt, ',', '') AS DECIMAL(10,2))
      WHEN p.locale_origem IN ('ISO', 'en-US') AND p.preco_txt REGEXP '^[0-9]+(\\.[0-9]{1,2})?$'
        THEN CAST(p.preco_txt AS DECIMAL(10,2))
    END;

-- conferir SKU e vendedor nas tabelas da empresa
UPDATE stg_vendas_tratada t JOIN produtos p ON p.sku = t.sku SET t.produto_id = p.produto_id;
UPDATE stg_vendas_tratada t JOIN funcionarios f ON f.email = t.email_vendedor SET t.funcionario_id = f.funcionario_id;

-- ver como ficou a conversão lado a lado com o bruto
SELECT s.source_row_id, s.data_venda_raw, t.data_venda, s.sku_raw, t.produto_id, s.quantidade_raw, t.quantidade,
       s.preco_unitario_raw, t.preco_unitario, s.moeda_raw, t.moeda, t.funcionario_id, s.canal_raw, t.canal_venda_id, s.status_raw, t.status_venda_id
FROM stg_vendas_csv s JOIN stg_vendas_tratada t ON t.source_row_id = s.source_row_id;

-- 11.3 VALIDAÇÃO: marcar cada problema (a ordem importa: o primeiro problema encontrado fica registrado)
UPDATE stg_vendas_tratada t JOIN stg_vendas_csv s ON s.source_row_id = t.source_row_id
SET t.situacao = 'REVISAR', t.campo_problema = 'locale_origem', t.motivo = 'Localidade não identificada (?): data 05/06/25 e preço 239,29 são ambíguos, não dá pra escolher interpretação'
WHERE t.situacao = 'OK' AND t.locale_origem NOT IN ('ISO', 'pt-BR', 'en-US');

UPDATE stg_vendas_tratada t
SET t.situacao = 'REJEITAR', t.campo_problema = 'data_venda_raw', t.motivo = 'Data impossível (dia não existe no mês)'
WHERE t.situacao = 'OK' AND t.data_venda IS NULL;

UPDATE stg_vendas_tratada t
SET t.situacao = 'REJEITAR', t.campo_problema = 'sku_raw', t.motivo = 'SKU não existe no catálogo de produtos'
WHERE t.situacao = 'OK' AND t.produto_id IS NULL;

UPDATE stg_vendas_tratada t
SET t.situacao = 'REVISAR', t.campo_problema = 'email_vendedor_raw', t.motivo = 'Vendedor sem correspondência na tabela funcionarios'
WHERE t.situacao = 'OK' AND t.funcionario_id IS NULL;

UPDATE stg_vendas_tratada t JOIN stg_vendas_csv s ON s.source_row_id = t.source_row_id
SET t.situacao = 'REVISAR', t.campo_problema = 'quantidade_raw', t.motivo = 'Quantidade escrita por extenso, precisa de confirmação manual'
WHERE t.situacao = 'OK' AND t.quantidade IS NULL;

UPDATE stg_vendas_tratada t
SET t.situacao = 'REJEITAR', t.campo_problema = 'quantidade_raw', t.motivo = 'Quantidade zero ou negativa não é uma venda válida'
WHERE t.situacao = 'OK' AND t.quantidade <= 0;

UPDATE stg_vendas_tratada t JOIN stg_vendas_csv s ON s.source_row_id = t.source_row_id
SET t.situacao = 'REJEITAR', t.campo_problema = 'preco_unitario_raw', t.motivo = 'Preço não interpretável'
WHERE t.situacao = 'OK' AND t.preco_unitario IS NULL;

UPDATE stg_vendas_tratada t JOIN stg_vendas_csv s ON s.source_row_id = t.source_row_id
SET t.situacao = 'REVISAR', t.campo_problema = 'moeda_raw', t.motivo = 'Moeda vazia: o símbolo $ sozinho não identifica a moeda'
WHERE t.situacao = 'OK' AND t.moeda IS NULL AND TRIM(s.moeda_raw) = '';

UPDATE stg_vendas_tratada t JOIN stg_vendas_csv s ON s.source_row_id = t.source_row_id
SET t.situacao = 'REJEITAR', t.campo_problema = 'moeda_raw', t.motivo = 'Código de moeda inválido'
WHERE t.situacao = 'OK' AND t.moeda IS NULL;

UPDATE stg_vendas_tratada t
SET t.situacao = 'REVISAR', t.campo_problema = 'canal_raw', t.motivo = 'Canal de venda não cadastrado (TikTok Shop)'
WHERE t.situacao = 'OK' AND t.canal_venda_id IS NULL;

-- duplicatas: mesmo pedido/item com TODOS os campos iguais -> fica a primeira linha, as outras são DUPLICATA
UPDATE stg_vendas_tratada t
JOIN stg_vendas_tratada o
  ON o.pedido_ref = t.pedido_ref AND o.item_seq = t.item_seq AND o.source_row_id < t.source_row_id
 AND o.data_venda = t.data_venda AND o.produto_id = t.produto_id AND o.quantidade = t.quantidade
 AND o.preco_unitario = t.preco_unitario AND o.moeda = t.moeda AND o.funcionario_id = t.funcionario_id
 AND o.canal_venda_id = t.canal_venda_id AND o.status_venda_id = t.status_venda_id
SET t.situacao = 'DUPLICATA', t.campo_problema = 'pedido_ref/item_seq', t.motivo = CONCAT('Cópia idêntica da linha ', o.source_row_id);

-- conflito: mesmo pedido/item mas com algum campo diferente -> não dá pra saber qual é o certo
UPDATE stg_vendas_tratada t
JOIN (
  SELECT pedido_ref, item_seq
  FROM stg_vendas_tratada
  WHERE situacao IN ('OK')
  GROUP BY pedido_ref, item_seq
  HAVING COUNT(*) > 1
) c ON c.pedido_ref = t.pedido_ref AND c.item_seq = t.item_seq
SET t.situacao = 'REVISAR', t.campo_problema = 'quantidade_raw', t.motivo = 'Conflito: mesmo pedido/item com quantidades diferentes (2 x 3)'
WHERE t.situacao = 'OK';

-- critério do pedido: se uma linha do pedido está em revisão, o pedido INTEIRO fica em revisão
-- (não quero carregar um pedido pela metade e depois ter que remendar)
UPDATE stg_vendas_tratada t
JOIN (SELECT DISTINCT pedido_ref FROM stg_vendas_tratada WHERE situacao = 'REVISAR') r ON r.pedido_ref = t.pedido_ref
SET t.situacao = 'REVISAR', t.campo_problema = 'pedido_ref', t.motivo = 'Linha válida, mas o pedido tem outra linha em revisão'
WHERE t.situacao = 'OK';

-- resumo da validação
SELECT situacao, COUNT(*) FROM stg_vendas_tratada GROUP BY situacao;
SELECT source_row_id, pedido_ref, item_seq, situacao, campo_problema, motivo FROM stg_vendas_tratada ORDER BY source_row_id;

-- 11.4 LOAD
START TRANSACTION;

-- pedidos (um por pedido_ref). venda_id continua a numeração que já existe
INSERT INTO vendas (venda_id, referencia_origem, data_venda, cliente_id, funcionario_id, canal_venda_id, status_venda_id)
SELECT (SELECT MAX(venda_id) FROM vendas) + ROW_NUMBER() OVER (ORDER BY pedido_ref),
       pedido_ref, data_venda, NULL, funcionario_id, canal_venda_id, status_venda_id
FROM (SELECT DISTINCT pedido_ref, data_venda, funcionario_id, canal_venda_id, status_venda_id
      FROM stg_vendas_tratada WHERE situacao = 'OK') p;

-- itens, guardando o source_row_id pra saber de qual linha do CSV veio
INSERT INTO itens_venda (item_venda_id, venda_id, numero_item, produto_id, quantidade, preco_unitario, moeda, source_row_id)
SELECT (SELECT MAX(item_venda_id) FROM itens_venda) + ROW_NUMBER() OVER (ORDER BY t.source_row_id),
       v.venda_id, t.item_seq, t.produto_id, t.quantidade, t.preco_unitario, t.moeda, t.source_row_id
FROM stg_vendas_tratada t
JOIN vendas v ON v.referencia_origem = t.pedido_ref
WHERE t.situacao = 'OK';

-- rejeições, duplicatas e revisões documentadas (valor original preservado)
INSERT INTO etl_rejeicoes (rejeicao_id, source_row_id, campo, valor_original, motivo, acao_etl_id)
SELECT ROW_NUMBER() OVER (ORDER BY t.source_row_id),
       t.source_row_id,
       t.campo_problema,
       CASE t.campo_problema
            WHEN 'locale_origem'      THEN CONCAT(s.locale_origem, ' | ', s.data_venda_raw, ' | ', s.preco_unitario_raw)
            WHEN 'data_venda_raw'     THEN s.data_venda_raw
            WHEN 'sku_raw'            THEN s.sku_raw
            WHEN 'email_vendedor_raw' THEN s.email_vendedor_raw
            WHEN 'quantidade_raw'     THEN s.quantidade_raw
            WHEN 'preco_unitario_raw' THEN s.preco_unitario_raw
            WHEN 'moeda_raw'          THEN CONCAT('[', s.moeda_raw, '] ', s.preco_unitario_raw)
            WHEN 'canal_raw'          THEN s.canal_raw
            ELSE CONCAT(s.pedido_ref, ' / item ', s.item_seq)
       END,
       t.motivo,
       (SELECT acao_etl_id FROM acoes_etl WHERE nome = t.situacao)
FROM stg_vendas_tratada t
JOIN stg_vendas_csv s ON s.source_row_id = t.source_row_id
WHERE t.situacao <> 'OK';

-- conferências antes do COMMIT
-- toda linha do CSV tem que estar OU em itens_venda OU em etl_rejeicoes (28 no total)
SELECT (SELECT COUNT(*) FROM itens_venda WHERE source_row_id IS NOT NULL) AS carregadas,
       (SELECT COUNT(*) FROM etl_rejeicoes) AS documentadas,
       (SELECT COUNT(*) FROM stg_vendas_csv) AS total_csv;

SELECT s.source_row_id FROM stg_vendas_csv s
WHERE s.source_row_id NOT IN (SELECT source_row_id FROM itens_venda WHERE source_row_id IS NOT NULL)
  AND s.source_row_id NOT IN (SELECT source_row_id FROM etl_rejeicoes);

SELECT * FROM relatorio_vendas WHERE referencia_origem LIKE 'EXT-%' ORDER BY ticket;

SELECT r.rejeicao_id, r.source_row_id, a.nome AS acao, r.campo, r.valor_original, r.motivo
FROM etl_rejeicoes r JOIN acoes_etl a ON a.acao_etl_id = r.acao_etl_id
ORDER BY r.source_row_id;

COMMIT;


-- ===== NÍVEL 12: ALTERAÇÕES SEGURAS =====
-- tudo numa transação, com SELECT de conferência depois de cada passo

START TRANSACTION;

-- 1) departamento novo em escritório existente
INSERT INTO departamentos (departamento_id, departamento_nome, educacional, escritorio_id)
VALUES ((SELECT MAX(d.departamento_id) + 1 FROM departamentos d), 'Games e Realidade Virtual', 0,
        (SELECT escritorio_id FROM escritorios WHERE escritorio_nome = 'Stark Tower'));
SELECT * FROM departamentos WHERE departamento_nome = 'Games e Realidade Virtual';

-- 2) cargo Senior Web Developer (já existe na base, então só cadastra se não existir) + promoção do Bruce
-- 7500 fica dentro da faixa do cargo (7000 a 16000)
INSERT INTO cargos (cargo_id, cargo_nome, min_salario, max_salario)
SELECT (SELECT MAX(c.cargo_id) + 1 FROM cargos c), 'Senior Web Developer', 7000.00, 16000.00
WHERE NOT EXISTS (SELECT 1 FROM cargos WHERE cargo_nome = 'Senior Web Developer');

UPDATE funcionarios
SET cargo_id = (SELECT cargo_id FROM cargos WHERE cargo_nome = 'Senior Web Developer'),
    salario  = 7500.00
WHERE email = 'bruce.ernst@momento.org';

SELECT f.primeiro_nome, f.sobrenome, c.cargo_nome, f.salario, c.min_salario, c.max_salario
FROM funcionarios f JOIN cargos c ON c.cargo_id = f.cargo_id
WHERE f.email = 'bruce.ernst@momento.org';

-- 3) transferir 2 pessoas de Tecnologia da Informação para o novo departamento
-- Valli Stark e Diana Lorentz: devs experientes, e TI continua com Alexander, David, Ariel e eu como devs
SELECT f.funcionario_id, f.primeiro_nome, f.sobrenome, c.cargo_nome, f.data_contratacao
FROM funcionarios f JOIN cargos c ON c.cargo_id = f.cargo_id
WHERE f.departamento_id = (SELECT departamento_id FROM departamentos WHERE departamento_nome = 'Tecnologia da Informação');

UPDATE funcionarios
SET departamento_id = (SELECT departamento_id FROM (SELECT departamento_id FROM departamentos WHERE departamento_nome = 'Games e Realidade Virtual') x)
WHERE email IN ('valli.stark@momento.org', 'diana.lorentz@momento.org');

SELECT funcionario_id, primeiro_nome, sobrenome, departamento_id FROM funcionarios
WHERE departamento_id = (SELECT departamento_id FROM departamentos WHERE departamento_nome = 'Games e Realidade Virtual');

-- 4) reajuste de 5% para quem ficou em Tecnologia da Informação
SELECT COUNT(*) AS vao_receber, SUM(salario) AS folha_antes FROM funcionarios
WHERE departamento_id = (SELECT departamento_id FROM departamentos WHERE departamento_nome = 'Tecnologia da Informação');

UPDATE funcionarios
SET salario = ROUND(salario * 1.05, 2)
WHERE departamento_id = (SELECT departamento_id FROM (SELECT departamento_id FROM departamentos WHERE departamento_nome = 'Tecnologia da Informação') x);

SELECT COUNT(*) AS receberam, SUM(salario) AS folha_depois FROM funcionarios
WHERE departamento_id = (SELECT departamento_id FROM departamentos WHERE departamento_nome = 'Tecnologia da Informação');

-- 5) compra de headsets
INSERT INTO suprimentos (suprimento_id, referencia_compra, suprimento_nome, quantidade_estoque, custo_unitario, moeda, data_compra, escritorio_id)
VALUES ((SELECT MAX(s.suprimento_id) + 1 FROM suprimentos s), 'PO-1500-HS-2025', 'Headsets', 20, 149.90, 'USD', CURDATE(),
        (SELECT escritorio_id FROM escritorios WHERE escritorio_nome = 'Stark Tower'));
SELECT * FROM suprimentos WHERE referencia_compra = 'PO-1500-HS-2025';

-- 6) aposentadoria: muda o status para INATIVO, sem apagar nada
SELECT f.funcionario_id, f.primeiro_nome, f.sobrenome, f.data_contratacao, s.nome AS status
FROM funcionarios f JOIN status_funcionario s ON s.status_funcionario_id = f.status_funcionario_id
WHERE f.email = 'neena.kochhar@momento.org';

UPDATE funcionarios
SET status_funcionario_id = (SELECT status_funcionario_id FROM status_funcionario WHERE nome = 'INATIVO')
WHERE email = 'neena.kochhar@momento.org';

SELECT f.funcionario_id, f.primeiro_nome, f.sobrenome, s.nome AS status,
       (SELECT COUNT(*) FROM dependentes d WHERE d.funcionario_id = f.funcionario_id) AS dependentes_mantidos,
       (SELECT COUNT(*) FROM audit_log a WHERE a.funcionario_id = f.funcionario_id) AS logs_mantidos
FROM funcionarios f JOIN status_funcionario s ON s.status_funcionario_id = f.status_funcionario_id
WHERE f.email = 'neena.kochhar@momento.org';

ROLLBACK; -- trocar por COMMIT depois de conferir tudo

-- conferindo que o ROLLBACK desfez (tem que dar 0)
SELECT COUNT(*) AS depois_do_rollback FROM departamentos WHERE departamento_nome = 'Games e Realidade Virtual';
