# Momento 

Bem-vindo à base de dados da empresa **Momento**!

A Momento vende produtos de cultura pop e mantém escritórios em diferentes países, além de manter uma escola como seu projeto educacional. A equipe de dados recebeu duas fontes: uma base relacional usada pela empresa para gestão geral e um CSV exportado por um sistema de vendas recém-integrado para vendas.

Nestes exercícios, você vai explorar o banco de dados da empresa e responder perguntas que revelam insights importantes sobre o negócio. Prepare-se para usar queries básicas, agregações complexas, e operações avançadas!


## Ambiente e arquivos

Esses são os arquivos para vocês trabalharem

- [0_Base.sql](0_Base.sql)`: cria e preenche uma base MySQL para as consultas. Requer MySQL 8.0 ou superior.
- [vendas_campanha_bruto.csv](vendas_campanha_bruto.csv): exportação externa que será usada no exercício de ETL.
- [resposta_dos_exercicios_8.sql](resposta_dos_exercicios_8.sql): meu script com as alterações (1.1, nível 6), o ETL completo (nível 11) e as transações (nível 12).

O script SQL usa o banco `momento` e **não apaga bancos nem tabelas existentes**. Execute-o em um banco/schema vazio. Ele cria uma área de pouso chamada `stg_vendas_csv`; essa tabela começa vazia para que a turma carregue o CSV. Os campos brutos dessa tabela são texto de propósito: a extração deve preservar os valores recebidos.

> O material é de SQL relacional e usa MySQL. As etapas de ETL podem ser feitas em SQL, Python ou Power Query, desde que o grupo documente as transformações e mantenha a rastreabilidade.

> **Obs:** rodei os níveis na ordem do README. Então as respostas dos níveis 7 a 10 já consideram eu cadastrado (1.1) e as alterações do nível 6. O [1_Views.sql](1_Views.sql) também foi executado.

## Desafios 

Prepare dados que ajudem a equipe a responder perguntas sobre pessoas, departamentos, escritórios, produtos, vendas e atividade do sistema. Entregue consultas que possam ser explicadas e reproduzidas por outra pessoa.

---

### Etapa 0 — Explorar

Uma das técnicas mais utilizadas pelos profissional de dados é a Exploratory Data Analysis (EDA) (Análise de Dados Exploratória, em português). 

A Análise Exploratória de Dados (AED) é o processo inicial crucial de examinar, limpar e visualizar um conjunto de dados para compreender suas principais características, identificar anomalias e descobrir padrões antes de construir modelos estatísticos ou de aprendizado de máquina formais.

Objetivos principais da AED

• Descobrir padrões e estruturas: Permitir que os dados sugiram tendências e relações sem viés preestabelecido.

• Detectar anomalias e outliers: Identificar entradas corrompidas, erros de digitação ou valores extremos que distorcem os resultados.

• Lidar com dados faltantes: Decidir se deve descartar ou imputar registros incompletos usando métodos estatísticos ou de aprendizado de máquina.

Sua missão nesse momento, é explorar os dados. 

R: O que encontrei explorando a base:

- 123 funcionários, 30 departamentos, 20 escritórios, 36 produtos, 54 vendas com 80 itens.
- **Salários em 4 moedas diferentes** (USD 90, GBP 15, EUR 10, BRL 8). Somar ou tirar média de tudo junto dá número errado, então nas perguntas de salário eu separo por moeda ou uso só USD.
- O departamento "Tecnologia" na base se chama **Tecnologia da Informação** (existe também "Tecnologias Avançadas", que é outro).
- "Recursos Humanos" aparece 2 vezes (um em Sala Winter e outro em Shuri's Palace).
- Na tabela `status_venda` o status 2 veio com o nome `'1'` em vez de um nome de verdade (provavelmente era PENDENTE). Corrigi no ETL.
- 4 vendas canceladas e 4 com esse status "1". Para faturamento eu considero só as **CONCLUIDA**.
- 12 produtos do catálogo nunca foram vendidos.
- 5 escritórios não têm nenhum suprimento cadastrado.
- Ninfadora Tonks dá aula mas o cargo dela é "Oficial de Segurança Biológia" (com erro de digitação no nome do cargo).
- Muitas tabelas de domínio (status, canais, níveis) para evitar texto solto nas tabelas principais.

```sql
SELECT table_name, table_rows FROM information_schema.tables WHERE table_schema = 'momento';
SELECT moeda_salario, COUNT(*) FROM funcionarios GROUP BY moeda_salario;
SELECT * FROM status_venda;
SELECT departamento_nome, COUNT(*) FROM departamentos GROUP BY departamento_nome HAVING COUNT(*) > 1;
SELECT p.produto_nome FROM produtos p LEFT JOIN itens_venda i ON i.produto_id = p.produto_id WHERE i.item_venda_id IS NULL;
```

## Nível 1: Conhecendo a Empresa

### Seu Primeiro Dia na Momento

**1.1** Você acabou de ser contratado pela Momento! Vamos começar incluindo você no sistema, escolha um departamento, cargo e salário.

R: Entrei em Tecnologia da Informação como Desenvolvedor Web, salário de 5.500 USD (dentro da faixa do cargo, 4.000 a 10.000).

```sql
INSERT INTO funcionarios (funcionario_id, primeiro_nome, sobrenome, email, telefone, data_contratacao, cargo_id, salario, moeda_salario, gerente_id, departamento_id, status_funcionario_id)
VALUES (222, 'Vinicius', 'Araujo', 'vinicius.araujo@momento.org', '+55-11-90000-0222', CURDATE(),
        (SELECT cargo_id FROM cargos WHERE cargo_nome = 'Desenvolvedor Web'), 5500.00, 'USD', 103,
        (SELECT departamento_id FROM departamentos WHERE departamento_nome = 'Tecnologia da Informação'), 1);

SELECT * FROM dados_funcionarios WHERE funcionario_nome = 'Vinicius Araujo';
```

**1.2** Agora que você faz parte da equipe, quantos funcionários temos ao total na empresa?

R: 124 funcionários (123 + eu)

```sql
SELECT COUNT(*) AS total_funcionarios FROM funcionarios;
```

**1.3** Quantos funcionários trabalham especificamente no Departamento de Tecnologia?

R: 10 funcionários

```sql
SELECT COUNT(*) AS funcionarios_ti
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE d.departamento_nome = 'Tecnologia da Informação';
```

**1.4** Liste todos os departamentos que existem na empresa. Quantos são?

R: 30 departamentos (29 nomes diferentes, porque Recursos Humanos existe em 2 escritórios). 22 são comerciais e 8 são da escola.

```sql
SELECT departamento_id, departamento_nome, educacional FROM departamentos ORDER BY departamento_nome;

SELECT COUNT(*) AS total_departamentos, COUNT(DISTINCT departamento_nome) AS nomes_diferentes FROM departamentos;
```

**1.5** Quantos escritórios a Momento possui? Em quais países?

R: 20 escritórios em 16 países. Estados Unidos e Reino Unido têm 3 cada; Argentina, Brasil, Brasil Bruxo, Canadá, Alemanha, França, França Mágica, Reino dos Mágos Unidos, Japão, Japão Místico, Peru, Portugal Bruxo, Wakanda e África do Sul têm 1 cada.

```sql
SELECT COUNT(*) AS total_escritorios FROM escritorios;

SELECT p.pais_nome, COUNT(*) AS escritorios
FROM escritorios e
JOIN paises p ON p.pais_id = e.pais_id
GROUP BY p.pais_nome
ORDER BY escritorios DESC;
```

---

## Nível 2: Análise Financeira Básica

O CFO precisa de relatórios urgentes sobre os custos da empresa.

**2.1** Quantos funcionários trabalham no Departamento de Vendas?

R: 5 funcionários

```sql
SELECT COUNT(*) AS funcionarios_vendas
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE d.departamento_nome = 'Vendas';
```

**2.2** Qual é o custo total com salários do Departamento de Vendas?

R: 59.390,76 USD (todos de Vendas recebem em dólar)

```sql
SELECT f.moeda_salario, SUM(f.salario) AS custo_total
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE d.departamento_nome = 'Vendas'
GROUP BY f.moeda_salario;
```

**2.3** Qual é a média salarial da empresa, excluindo os cargos de CEO, CMO e CFO?

R: Separando por moeda: USD 10.039,33 (88 pessoas) | GBP 7.586,67 | EUR 5.670,00 | BRL 15.537,50. Não dá pra fazer uma média só misturando moedas sem uma tabela de câmbio.

```sql
SELECT f.moeda_salario, ROUND(AVG(f.salario), 2) AS media_salarial, COUNT(*) AS funcionarios
FROM funcionarios f
JOIN cargos c ON c.cargo_id = f.cargo_id
WHERE c.cargo_nome NOT IN ('CEO', 'CMO', 'CFO')
GROUP BY f.moeda_salario;
```

**2.4** Qual é a média salarial do Departamento de Tecnologia?

R: 7.286,06 USD

```sql
SELECT ROUND(AVG(f.salario), 2) AS media_ti
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE d.departamento_nome = 'Tecnologia da Informação';
```

**2.5** Qual departamento possui a maior média salarial?

R: Biotecnologia, com 29.263,48 USD (comparando só quem recebe em USD; os departamentos da escola pagam em GBP, EUR e BRL, então não dá pra comparar direto).

```sql
SELECT d.departamento_nome, ROUND(AVG(f.salario), 2) AS media_salarial
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE f.moeda_salario = 'USD'
GROUP BY d.departamento_id, d.departamento_nome
ORDER BY media_salarial DESC
LIMIT 1;
```

**2.6** Qual departamento possui o menor número de funcionários?

R: Empate com 1 funcionário: Administração Executiva, Contabilidade e Recursos Humanos (o de Shuri's Palace)

```sql
SELECT d.departamento_nome, e.escritorio_nome, COUNT(f.funcionario_id) AS total_funcionarios
FROM departamentos d
JOIN escritorios e ON e.escritorio_id = d.escritorio_id
LEFT JOIN funcionarios f ON f.departamento_id = d.departamento_id
GROUP BY d.departamento_id, d.departamento_nome, e.escritorio_nome
ORDER BY total_funcionarios
LIMIT 5;
```

---

## Nível 3: Recursos Humanos

O RH está fazendo uma análise demográfica da empresa.

**3.1** Quantos funcionários da empresa Momento possuem cônjuges?

R: 15 funcionários

```sql
SELECT COUNT(DISTINCT funcionario_id) AS com_conjuge
FROM dependentes
WHERE relacionamento = 'Cônjuge';
```

**3.2** Quantos funcionários possuem filhos registrados?

R: 61 funcionários (com 80 filhos no total)

```sql
SELECT COUNT(DISTINCT funcionario_id) AS com_filhos, COUNT(*) AS total_filhos
FROM dependentes
WHERE relacionamento = 'Filha(o)';
```

**3.3** Qual funcionário foi contratado há mais tempo na empresa?

R: Madeleine Prior, contratada em 23/03/1987 (é a CEO)

```sql
SELECT primeiro_nome, sobrenome, data_contratacao
FROM funcionarios
ORDER BY data_contratacao
LIMIT 1;
```

**3.4** Qual funcionário foi contratado há menos tempo na empresa?

R: Eu (Vinicius Araujo), cadastrado no 1.1. Antes de mim era a Ariel Nunes, contratada em 12/05/2025.

```sql
SELECT primeiro_nome, sobrenome, data_contratacao
FROM funcionarios
ORDER BY data_contratacao DESC
LIMIT 1;
```

**3.5** Liste os 5 funcionários com mais tempo de casa, ordenados pela data de contratação.

R: Madeleine Prior (1987-03-23), Noah Kim (1987-04-11), Yuki Tanaka (1987-07-31), Neena Kochhar (1987-08-17) e Lex T.Challa (1988-02-08)

```sql
SELECT primeiro_nome, sobrenome, data_contratacao
FROM funcionarios
ORDER BY data_contratacao
LIMIT 5;
```

**3.6** Quantos funcionários foram contratados na década de 1990 (entre 1990-1999)?

R: 28 funcionários

```sql
SELECT COUNT(*) AS contratados_anos_90
FROM funcionarios
WHERE YEAR(data_contratacao) BETWEEN 1990 AND 1999;
```

**3.7** Como a média salarial da Momento evoluiu ao longo dos anos? Agrupe por ano de contratação e calcule a média salarial.

R: Não tem uma tendência clara, oscila bastante porque são poucas pessoas por ano (2 a 4). Os picos são 2008 (24.816,12 USD) e 2009 (19.891,30), anos em que entraram cientistas de dados. Os anos mais baixos são 1995/1996 (assistentes de compras) e 2019 (4.225,01). Usei só USD pra não misturar moeda.

```sql
SELECT YEAR(data_contratacao) AS ano, COUNT(*) AS contratados, ROUND(AVG(salario), 2) AS media_salarial
FROM funcionarios
WHERE moeda_salario = 'USD'
GROUP BY ano
ORDER BY ano;
```

---

## Nível 4: Operações e Escritórios

**4.1** Qual é o custo total de suprimentos em cada escritório? Ordene do mais caro ao mais barato.

R: O mais caro é Koboa Koboa (70.605,50) e o mais barato Wayne Offices (17.948,00). Torre de Paris, Paititi Operations, Instituto Rio, Castelo Principal e Tokyo Lab não têm suprimento cadastrado.

```sql
SELECT escritorio_nome, SUM(custo_total_item) AS custo_suprimentos
FROM custos_escritorios
GROUP BY escritorio_nome
ORDER BY custo_suprimentos DESC;
```

**4.2** Qual escritório possui a maior quantidade de diferentes tipos de suprimentos?

R: Empate: todos os 15 escritórios que têm suprimentos têm os mesmos 7 tipos (Computadores, Monitores, Teclados, Headsets, Papel, Impressoras, Planners).

```sql
SELECT e.escritorio_nome, COUNT(DISTINCT s.suprimento_nome) AS tipos
FROM suprimentos s
JOIN escritorios e ON e.escritorio_id = s.escritorio_id
GROUP BY e.escritorio_nome
ORDER BY tipos DESC;
```

**4.3** Qual é o suprimento mais caro (considerando preço unitário) em toda a empresa?

R: Computadores do escritório Koboa Koboa, 909,50 USD cada

```sql
SELECT s.suprimento_nome, s.custo_unitario, e.escritorio_nome
FROM suprimentos s
JOIN escritorios e ON e.escritorio_id = s.escritorio_id
ORDER BY s.custo_unitario DESC
LIMIT 1;
```

**4.4** Calcule o valor total do inventário de suprimentos da empresa (quantidade × preço unitário de todos os itens em todos os escritórios).

R: 700.535,50 USD

```sql
SELECT SUM(quantidade_estoque * custo_unitario) AS valor_inventario
FROM suprimentos;
```

---

## Nível 5: Produtos e Vendas

**5.1** Quais produtos foram vendidos pela Momento? Liste todos os produtos únicos.

R: 24 produtos diferentes (dos 36 do catálogo)

```sql
SELECT DISTINCT p.sku, p.produto_nome
FROM itens_venda i
JOIN produtos p ON p.produto_id = i.produto_id
ORDER BY p.produto_nome;

SELECT COUNT(DISTINCT produto_id) AS produtos_vendidos FROM itens_venda;
```

**5.2** Qual é o produto mais vendido (maior quantidade total)?

R: Reator Arc decorativo, 48 unidades

```sql
SELECT p.produto_nome, SUM(i.quantidade) AS unidades
FROM itens_venda i
JOIN produtos p ON p.produto_id = i.produto_id
GROUP BY p.produto_id, p.produto_nome
ORDER BY unidades DESC
LIMIT 1;
```

**5.3** Qual é o produto menos vendido?

R: Chapéu Seletor, só 1 unidade. Mas tem 12 produtos que nunca venderam nada (ex: Uniforme do Superman, Scouter, Omnitrix...).

```sql
SELECT p.produto_nome, SUM(i.quantidade) AS unidades
FROM itens_venda i
JOIN produtos p ON p.produto_id = i.produto_id
GROUP BY p.produto_id, p.produto_nome
ORDER BY unidades ASC
LIMIT 1;

-- produtos que nunca foram vendidos
SELECT p.produto_nome
FROM produtos p
LEFT JOIN itens_venda i ON i.produto_id = p.produto_id
WHERE i.item_venda_id IS NULL;
```

**5.4** Pensando na relação quantidade × valor unitário, qual produto gerou mais receita para a empresa?

R: Tesseract decorativo, 236.788,65 USD

```sql
SELECT p.produto_nome, SUM(i.quantidade * i.preco_unitario) AS receita
FROM itens_venda i
JOIN produtos p ON p.produto_id = i.produto_id
GROUP BY p.produto_id, p.produto_nome
ORDER BY receita DESC
LIMIT 1;
```

**5.5** Qual é o produto mais caro (maior preço unitário) no catálogo?

R: Tesseract decorativo, 7.000,00 USD

```sql
SELECT produto_nome, preco_catalogo
FROM produtos
ORDER BY preco_catalogo DESC
LIMIT 1;
```

**5.6** Qual foi o faturamento total da empresa em vendas?

R: 780.061,94 USD considerando só as vendas CONCLUIDA. Se somar tudo (com canceladas e a pendente) dá 863.042,05, mas venda cancelada não é faturamento.

```sql
SELECT sv.nome AS status, SUM(i.quantidade * i.preco_unitario) AS faturamento
FROM vendas v
JOIN itens_venda i ON i.venda_id = v.venda_id
JOIN status_venda sv ON sv.status_venda_id = v.status_venda_id
GROUP BY sv.nome;

SELECT SUM(receita_item) AS faturamento_total
FROM relatorio_vendas
WHERE status_venda = 'CONCLUIDA';
```

**5.7** Quantas vendas foram realizadas no mês de junho de 2023?

R: 2 vendas

```sql
SELECT COUNT(*) AS vendas_junho_2023
FROM vendas
WHERE data_venda BETWEEN '2023-06-01' AND '2023-06-30';
```

**5.8** Qual vendedor realizou mais vendas (em quantidade de transações)?

R: Empate com 11 vendas: John Russell, Karen Partners, Jonathon Taylor e Jack Livingston. Kimberly Grant fez 10.

```sql
SELECT f.primeiro_nome, f.sobrenome, COUNT(*) AS total_vendas
FROM vendas v
JOIN funcionarios f ON f.funcionario_id = v.funcionario_id
GROUP BY f.funcionario_id, f.primeiro_nome, f.sobrenome
ORDER BY total_vendas DESC;
```

**5.9** Qual vendedor gerou mais receita para a empresa?

R: Jack Livingston, 187.825,62 USD em vendas concluídas. Curiosidade: se contar as canceladas o primeiro vira o John Russell (196.953,14), então o status muda a resposta.

```sql
SELECT f.primeiro_nome, f.sobrenome, SUM(i.quantidade * i.preco_unitario) AS receita
FROM vendas v
JOIN itens_venda i ON i.venda_id = v.venda_id
JOIN funcionarios f ON f.funcionario_id = v.funcionario_id
JOIN status_venda sv ON sv.status_venda_id = v.status_venda_id
WHERE sv.nome = 'CONCLUIDA'
GROUP BY f.funcionario_id, f.primeiro_nome, f.sobrenome
ORDER BY receita DESC
LIMIT 1;
```

---

## Nível 6: Operações de Atualização

A empresa está crescendo e mudanças precisam acontecer!

> Os comandos completos estão no [resposta_dos_exercicios_8.sql](resposta_dos_exercicios_8.sql).

**6.1** Um novo departamento foi criado: **Inovações**. Ele será alocado no escritório "Wayne Offices". Adicione-o ao banco de dados.

```sql
INSERT INTO departamentos (departamento_id, departamento_nome, educacional, escritorio_id)
VALUES (31, 'Inovações', 0, (SELECT escritorio_id FROM escritorios WHERE escritorio_nome = 'Wayne Offices'));

SELECT * FROM departamentos WHERE departamento_nome = 'Inovações';
```

**6.2** O departamento de Inovações está sem funcionários. Transfira 2 funcionários do departamento de Tecnologia para Inovações.

R: Transferi Peter Parker (Desenvolvedor Web) e Samus Aran (Analista de Qualidade), um pra desenvolver e outro pra testar.

```sql
UPDATE funcionarios
SET departamento_id = 31
WHERE funcionario_id IN (139, 144);

SELECT funcionario_id, primeiro_nome, sobrenome, departamento_id FROM funcionarios WHERE departamento_id = 31;
```

**6.3** A empresa decidiu dar um aumento de 10% para todos os funcionários do departamento de Tecnologia. Atualize os salários.

R: 8 funcionários receberam (os 2 que foram pra Inovações já tinham saído)

```sql
UPDATE funcionarios
SET salario = ROUND(salario * 1.10, 2)
WHERE departamento_id = 6;

SELECT funcionario_id, primeiro_nome, salario FROM funcionarios WHERE departamento_id = 6;
```

**6.4** O funcionário "Bruce Ernst" foi promovido a "Senior Web Developer" e recebeu um aumento para $5.000. Atualize suas informações.

R: Feito, mas tem um problema: o Bruce já ganhava 6.000 (6.600 depois do 6.3), então 5.000 é uma **redução**, e fica abaixo do mínimo do cargo Senior Web Developer (7.000). A view `radar_salarial` mostra ele como "Abaixo da faixa". No nível 12 eu corrigi isso.

```sql
UPDATE funcionarios
SET cargo_id = (SELECT cargo_id FROM cargos WHERE cargo_nome = 'Senior Web Developer'),
    salario = 5000.00
WHERE primeiro_nome = 'Bruce' AND sobrenome = 'Ernst';

SELECT * FROM radar_salarial WHERE funcionario_nome = 'Bruce Ernst';
```

**6.5** Adicione um novo suprimento ao escritório "Wayne Offices": 15 unidades de "Headsets" com preço unitário de $150 cada.

```sql
INSERT INTO suprimentos (suprimento_id, referencia_compra, suprimento_nome, quantidade_estoque, custo_unitario, moeda, data_compra, escritorio_id)
VALUES (106, 'PO-1400-08', 'Headsets', 15, 150.00, 'USD', CURDATE(),
        (SELECT escritorio_id FROM escritorios WHERE escritorio_nome = 'Wayne Offices'));

SELECT * FROM suprimentos WHERE escritorio_id = 1400 AND suprimento_nome = 'Headsets';
```

**6.6** Todos os funcionários contratados antes de 1990 estão aposentando. Remova-os do banco de dados (CUIDADO: execute um **SELECT** antes para ver quantos serão afetados!).

R: O SELECT mostra 8 pessoas (Madeleine Prior, Neena Kochhar, Lex T.Challa, Alexander Hunold, Bruce Ernst, David Austin, Noah Kim e Yuki Tanaka), incluindo a CEO e o próprio Bruce que acabou de ser promovido. Eles têm 12 dependentes, 8 registros no audit_log e 24 subordinados. O **DELETE não funciona**: o MySQL bloqueia por causa da chave estrangeira de `dependentes` (ON DELETE RESTRICT):

```
ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails
(`momento`.`dependentes`, CONSTRAINT `fk_dependentes_funcionario` ...)
```

E mesmo se desse, apagar seria errado porque perderia o histórico. O certo é mudar o status para INATIVO (feito no nível 12).

```sql
SELECT funcionario_id, primeiro_nome, sobrenome, data_contratacao
FROM funcionarios
WHERE data_contratacao < '1990-01-01';

-- o que seria afetado
SELECT 'dependentes', COUNT(*) FROM dependentes WHERE funcionario_id IN (SELECT funcionario_id FROM funcionarios WHERE data_contratacao < '1990-01-01')
UNION ALL
SELECT 'audit_log', COUNT(*) FROM audit_log WHERE funcionario_id IN (SELECT funcionario_id FROM funcionarios WHERE data_contratacao < '1990-01-01');

DELETE FROM funcionarios WHERE data_contratacao < '1990-01-01'; -- ERROR 1451
```

---

## Nível 7: Da sala de aula ao impacto corporativo

Agora a história acompanha pessoas. A Momento quer entender se sua escola está formando talentos, ampliando acesso e criando pontes reais para o mundo do trabalho. Use os dados para contar essa jornada com cuidado: números revelam tendências, mas não substituem histórias individuais.

**7.1** Quais cursos estão ativos? Para cada um, mostre carga horária, nível e quantas turmas já foram abertas. 

R: Os 3 cursos estão ativos e cada um tem 1 turma:
- Tecnologia Criativa: 80h, INTRODUTORIO
- Narrativas e Cultura Pop: 60h, INTERMEDIARIO
- Laboratório de Dados: 100h, AVANCADO

```sql
SELECT c.curso_nome, c.carga_horaria, n.nome AS nivel, COUNT(t.turma_id) AS turmas_abertas
FROM cursos c
JOIN niveis_curso n ON n.nivel_curso_id = c.nivel_curso_id
LEFT JOIN turmas t ON t.curso_id = c.curso_id
WHERE c.ativo = 1
GROUP BY c.curso_id, c.curso_nome, c.carga_horaria, n.nome;
```

**7.2** Para cada turma, mostre curso, professores, capacidade e número de matrículas. 

R:

| Turma | Curso | Professor(a) | Capacidade | Matrículas |
|---|---|---|---|---|
| TEC-2025-01 | Tecnologia Criativa | Filius Flitwick | 30 | 2 |
| NAR-2025-01 | Narrativas e Cultura Pop | Ninfadora Tonks | 25 | 1 |
| DAD-2025-01 | Laboratório de Dados | Fleur Dascores | 20 | 1 |

As turmas estão muito vazias (4 matrículas para 75 vagas).

```sql
SELECT t.codigo AS turma, c.curso_nome, CONCAT(f.primeiro_nome, ' ', f.sobrenome) AS professor,
       t.capacidade, COUNT(m.matricula_id) AS matriculas
FROM turmas t
JOIN cursos c ON c.curso_id = t.curso_id
JOIN funcionarios f ON f.funcionario_id = t.professor_funcionario_id
LEFT JOIN matriculas m ON m.turma_id = t.turma_id
GROUP BY t.turma_id, t.codigo, c.curso_nome, f.primeiro_nome, f.sobrenome, t.capacidade;
```

**7.3** Quantos estudantes receberam bolsa, qual foi o percentual concedido e em quais cursos? 

R: 2 estudantes (de 4):
- Ariel Nunes: 100% em Tecnologia Criativa (bolsa de acesso para formação em tecnologia)
- Diego Ramos: 50% em Narrativas e Cultura Pop (bolsa de diversidade e inclusão)

```sql
SELECT a.nome AS estudante, c.curso_nome, b.percentual_desconto, b.criterio
FROM bolsas b
JOIN alunos a ON a.aluno_id = b.aluno_id
JOIN cursos c ON c.curso_id = b.curso_id;
```

**7.4** Por curso e turma, calcule matrículas, concluintes, certificados emitidos e nota média. Quais perguntas adicionais seriam necessárias antes de afirmar que um curso teve “mais sucesso” que outro?

R:

| Curso | Turma | Matrículas | Concluintes | Certificados | Nota média |
|---|---|---|---|---|---|
| Tecnologia Criativa | TEC-2025-01 | 2 | 2 | 2 | 88,75 |
| Narrativas e Cultura Pop | NAR-2025-01 | 1 | 0 | 0 | - |
| Laboratório de Dados | DAD-2025-01 | 1 | 0 | 0 | - |

Só Tecnologia Criativa tem resultado, mas não dá pra dizer que foi "mais sucesso". Perguntas antes de comparar:
- As outras turmas já terminaram? (as matrículas ainda estão ATIVAS)
- Com 1 ou 2 alunos por turma, qualquer média é estatisticamente fraca.
- Os cursos têm níveis e cargas horárias diferentes, a nota é comparável?
- Sucesso é nota, conclusão, ou o aluno conseguir estágio/emprego depois?
- Quantos se inscreveram e não conseguiram vaga? Quantos desistiram?
- O perfil de entrada dos alunos era parecido (bolsistas x não bolsistas)?

```sql
SELECT c.curso_nome, t.codigo AS turma,
       COUNT(m.matricula_id) AS matriculas,
       SUM(sm.nome = 'CONCLUIDA') AS concluintes,
       SUM(m.certificado_emitido) AS certificados,
       ROUND(AVG(m.nota_final), 2) AS nota_media
FROM cursos c
JOIN turmas t ON t.curso_id = c.curso_id
LEFT JOIN matriculas m ON m.turma_id = t.turma_id
LEFT JOIN status_matricula sm ON sm.status_matricula_id = m.status_matricula_id
GROUP BY c.curso_nome, t.codigo;
```

**7.5** Reconstrua a trajetória de Ariel Nunes: curso, turma, matrícula, bolsa, estágio e contratação. Em que momento a formação passou a se conectar com uma oportunidade corporativa?

R: Linha do tempo da Ariel:
- 10/01/2025: cadastro como aluna
- 12/01/2025: recebe bolsa de 100% em Tecnologia Criativa
- 15/01/2025: matrícula na turma TEC-2025-01 (aulas de 03/02 a 25/04/2025)
- Conclui com nota 91,50 e certificado
- 05/05/2025 a 11/05/2025: estágio em Tecnologia da Informação (ENCERRADO)
- 12/05/2025: contratada como Desenvolvedora Web em TI (vínculo ATIVO, funcionário 300)

A conexão com a empresa acontece no **estágio**, 10 dias depois do fim do curso. O estágio durou só 1 semana e já virou contratação. A bolsa de 100% foi o que permitiu ela entrar, então a trajetória toda começa no acesso.

```sql
SELECT a.nome, c.curso_nome, t.codigo AS turma, m.data_matricula, sm.nome AS status_matricula,
       m.nota_final, m.certificado_emitido, b.percentual_desconto, b.data_concessao,
       tv.nome AS tipo_vinculo, vt.data_inicio, vt.data_fim, sv.nome AS status_vinculo,
       d.departamento_nome, CONCAT(f.primeiro_nome, ' ', f.sobrenome) AS funcionario
FROM alunos a
JOIN matriculas m ON m.aluno_id = a.aluno_id
JOIN turmas t ON t.turma_id = m.turma_id
JOIN cursos c ON c.curso_id = t.curso_id
JOIN status_matricula sm ON sm.status_matricula_id = m.status_matricula_id
LEFT JOIN bolsas b ON b.aluno_id = a.aluno_id AND b.curso_id = c.curso_id
LEFT JOIN vinculos_talentos vt ON vt.aluno_id = a.aluno_id
LEFT JOIN tipos_vinculo tv ON tv.tipo_vinculo_id = vt.tipo_vinculo_id
LEFT JOIN status_vinculo sv ON sv.status_vinculo_id = vt.status_vinculo_id
LEFT JOIN departamentos d ON d.departamento_id = vt.departamento_id
LEFT JOIN funcionarios f ON f.funcionario_id = vt.funcionario_id
WHERE a.nome = 'Ariel Nunes'
ORDER BY vt.data_inicio;
```

**7.6** Liste os vínculos de talentos com estudante, tipo de vínculo, departamento, status e, quando existir, a pessoa funcionária associada. Quantas pessoas passaram por estágio e quantas chegaram à contratação?

R: 2 vínculos, os dois da Ariel Nunes: 1 estágio (ENCERRADO, sem funcionário associado porque ela ainda não era funcionária) e 1 contratação (ATIVO, funcionária Ariel Nunes). Então **1 pessoa** passou por estágio e **1 pessoa** foi contratada.

```sql
SELECT a.nome AS estudante, tv.nome AS tipo_vinculo, d.departamento_nome, sv.nome AS status,
       vt.data_inicio, vt.data_fim, CONCAT(f.primeiro_nome, ' ', f.sobrenome) AS funcionario
FROM vinculos_talentos vt
JOIN alunos a ON a.aluno_id = vt.aluno_id
JOIN tipos_vinculo tv ON tv.tipo_vinculo_id = vt.tipo_vinculo_id
JOIN departamentos d ON d.departamento_id = vt.departamento_id
JOIN status_vinculo sv ON sv.status_vinculo_id = vt.status_vinculo_id
LEFT JOIN funcionarios f ON f.funcionario_id = vt.funcionario_id;

SELECT tv.nome AS tipo_vinculo, COUNT(DISTINCT vt.aluno_id) AS pessoas
FROM vinculos_talentos vt
JOIN tipos_vinculo tv ON tv.tipo_vinculo_id = vt.tipo_vinculo_id
GROUP BY tv.nome;
```

**7.7** Quais departamentos recebem talentos da escola? 

R: Só Tecnologia da Informação (Wayne Offices, Gotham)

```sql
SELECT d.departamento_nome, e.escritorio_nome, COUNT(*) AS vinculos
FROM vinculos_talentos vt
JOIN departamentos d ON d.departamento_id = vt.departamento_id
JOIN escritorios e ON e.escritorio_id = d.escritorio_id
GROUP BY d.departamento_nome, e.escritorio_nome;
```

**7.8**: Crie uma única consulta que apresente: total de alunos, matrículas ativas, concluintes, bolsas concedidas, estágios, contratações e departamentos que receberam talentos. 

R: 4 alunos | 2 matrículas ativas | 2 concluintes | 2 bolsas | 1 estágio | 1 contratação | 1 departamento

```sql
SELECT
  (SELECT COUNT(*) FROM alunos) AS total_alunos,
  (SELECT COUNT(*) FROM matriculas m JOIN status_matricula s ON s.status_matricula_id = m.status_matricula_id WHERE s.nome = 'ATIVA') AS matriculas_ativas,
  (SELECT COUNT(*) FROM matriculas m JOIN status_matricula s ON s.status_matricula_id = m.status_matricula_id WHERE s.nome = 'CONCLUIDA') AS concluintes,
  (SELECT COUNT(*) FROM bolsas) AS bolsas_concedidas,
  (SELECT COUNT(*) FROM vinculos_talentos vt JOIN tipos_vinculo t ON t.tipo_vinculo_id = vt.tipo_vinculo_id WHERE t.nome = 'ESTAGIO') AS estagios,
  (SELECT COUNT(*) FROM vinculos_talentos vt JOIN tipos_vinculo t ON t.tipo_vinculo_id = vt.tipo_vinculo_id WHERE t.nome = 'CONTRATACAO') AS contratacoes,
  (SELECT COUNT(DISTINCT departamento_id) FROM vinculos_talentos) AS departamentos_com_talentos;
```

**7.11** O que faz a tabela **__vinculos_talentos__**?

R: É a "ponte" entre a escola e a empresa. Aluno e funcionário são tabelas separadas (aluno não é funcionário), e essa tabela registra quando um aluno tem uma oportunidade formal na Momento: o tipo (ESTAGIO ou CONTRATACAO), em qual departamento, período (data_inicio/data_fim) e status (ATIVO, ENCERRADO, CANCELADO). O `funcionario_id` é opcional: fica vazio no estágio e só é preenchido quando a pessoa vira funcionária de verdade. Assim dá pra acompanhar a trajetória completa sem misturar as duas coisas.

```sql
DESCRIBE vinculos_talentos;
```

## Nível 8: Duas Frentes, Duas Operações

**8.1** Quanto custa manter a frente educacional em comparação à operação comercial? (Faça uma análise de custo total com salários, suprimentos e despesas gerais para cada departamento.)

R: 

| Frente | Funcionários | Folha salarial |
|---|---|---|
| Comercial | 74 | 825.322,29 USD |
| Educacional | 50 | 111.300 USD + 113.800 GBP + 56.700 EUR + 124.300 BRL |

Suprimentos ficam por **escritório**, não por departamento. Escritórios só comerciais: 525.553,50 USD. Só educacionais: 70.605,50 (Koboa Koboa; os outros 5 da escola não têm suprimento). Mistos (Verstebona e Castelo Encantado): 106.626,50.

A comercial é bem maior em pessoas e custo. Limitações: não existe tabela de despesas gerais (aluguel, energia...), e sem câmbio não dá pra somar a folha educacional numa moeda só.

```sql
-- folha por frente e moeda
SELECT IF(d.educacional = 1, 'Educacional', 'Comercial') AS frente, f.moeda_salario,
       COUNT(*) AS funcionarios, SUM(f.salario) AS folha
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
GROUP BY frente, f.moeda_salario
ORDER BY frente, f.moeda_salario;

-- folha por departamento
SELECT d.departamento_nome, IF(d.educacional = 1, 'Educacional', 'Comercial') AS frente,
       f.moeda_salario, COUNT(*) AS funcionarios, SUM(f.salario) AS folha
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
GROUP BY d.departamento_id, d.departamento_nome, d.educacional, f.moeda_salario
ORDER BY frente, folha DESC;

-- suprimentos por escritório e quais frentes ele tem
SELECT e.escritorio_nome,
       GROUP_CONCAT(DISTINCT IF(d.educacional = 1, 'Educacional', 'Comercial')) AS frentes,
       (SELECT SUM(s.quantidade_estoque * s.custo_unitario) FROM suprimentos s WHERE s.escritorio_id = e.escritorio_id) AS suprimentos
FROM escritorios e
LEFT JOIN departamentos d ON d.escritorio_id = e.escritorio_id
GROUP BY e.escritorio_id, e.escritorio_nome
ORDER BY frentes;
```

**8.2** Quais escritórios concentram equipes comerciais e quais concentram equipes da escola?

R:
- **Comerciais:** Sala Winter (17 funcionários), Wayne Offices (13), Stark Tower (7), Arkham Base, Umbrella Corp, House of Mystery, Shuri's Palace, Campus de Lisboa, Cape Town Studio, Daily Planet Bureau, Archies Mad House, Baxter Building.
- **Escola:** Koboa Koboa (8), Castelo Principal (7), Paititi Operations (7), Instituto Rio (6), Torre de Paris (4), Tokyo Lab (3).
- **Os dois:** Castelo Encantado (10 escola + 3 comercial) e Verstebona (5 escola + 3 comercial).

As 3 turmas acontecem em Castelo Encantado, Instituto Rio e Torre de Paris.

```sql
SELECT e.escritorio_nome, p.pais_nome,
       SUM(d.educacional = 0) AS deps_comerciais,
       SUM(d.educacional = 1) AS deps_escola,
       (SELECT COUNT(*) FROM funcionarios f JOIN departamentos d2 ON d2.departamento_id = f.departamento_id
         WHERE d2.escritorio_id = e.escritorio_id AND d2.educacional = 0) AS funcionarios_comerciais,
       (SELECT COUNT(*) FROM funcionarios f JOIN departamentos d2 ON d2.departamento_id = f.departamento_id
         WHERE d2.escritorio_id = e.escritorio_id AND d2.educacional = 1) AS funcionarios_escola
FROM escritorios e
JOIN paises p ON p.pais_id = e.pais_id
LEFT JOIN departamentos d ON d.escritorio_id = e.escritorio_id
GROUP BY e.escritorio_id, e.escritorio_nome, p.pais_nome
ORDER BY deps_escola, e.escritorio_nome;
```

**8.3** A receita das vendas consegue sustentar investimentos educacionais?

R: Pelos dados, **não**. A receita concluída foi 340.924,58 (2023), 265.665,29 (2024) e 173.472,07 (2025), caindo todo ano. Só a parte da folha educacional paga em USD já é 111.300, ou seja, ~42% da receita de 2024 inteira, e isso é um mês de salário (se for mensal) e só uma das 4 moedas. Na verdade a receita não cobre nem a folha comercial (825 mil). A escola depende de outra fonte de dinheiro, ou a base de vendas é só uma amostra. Pra responder certo precisaria de câmbio, saber se salário é mensal e ter as despesas gerais.

```sql
SELECT YEAR(v.data_venda) AS ano, SUM(i.quantidade * i.preco_unitario) AS receita
FROM vendas v
JOIN itens_venda i ON i.venda_id = v.venda_id
JOIN status_venda sv ON sv.status_venda_id = v.status_venda_id
WHERE sv.nome = 'CONCLUIDA'
GROUP BY ano;

SELECT f.moeda_salario, SUM(f.salario) AS folha_educacional
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE d.educacional = 1
GROUP BY f.moeda_salario;
```

**8.4** Quais cargos e departamentos são compartilhados pelas duas frentes?

R: **Nenhum.** Os cargos da escola (Diretor, Professor Titular, Professor Assistente, Mestre de Poções, Guardião etc.) só aparecem em departamentos educacionais, e os comerciais só nos comerciais. O único nome de departamento repetido é Recursos Humanos, mas os dois são comerciais. As duas frentes só se encontram em:
- os escritórios mistos (Castelo Encantado e Verstebona);
- a tabela `vinculos_talentos`, que leva aluno pra TI;
- os professores, que também são funcionários.

```sql
-- cargos que aparecem nas duas frentes (volta vazio)
SELECT c.cargo_nome, SUM(d.educacional = 0) AS comercial, SUM(d.educacional = 1) AS educacional
FROM funcionarios f
JOIN cargos c ON c.cargo_id = f.cargo_id
JOIN departamentos d ON d.departamento_id = f.departamento_id
GROUP BY c.cargo_nome
HAVING comercial > 0 AND educacional > 0;

-- departamentos com o mesmo nome nas duas frentes (volta vazio)
SELECT departamento_nome
FROM departamentos
GROUP BY departamento_nome
HAVING COUNT(DISTINCT educacional) > 1;
```

**8.5** Como a expansão internacional afeta vendas, equipes e o projeto educacional?

R:
- **Vendas:** são 20 escritórios em 16 países, mas as 54 vendas saíram todas do departamento de Vendas da Umbrella Corp (Oxford, Reino Unido), mesmo com clientes nos EUA, Brasil, França e Japão. A venda não acompanha a expansão. O CSV novo já traz vendas em BRL, o que obriga a guardar moeda em cada venda.
- **Equipes:** a parte comercial fica na América do Norte (42 funcionários) e Europa (16). Fora disso, quase todo mundo é da escola (América do Sul 20 de 23, Europa Mágica 11 de 14, Ásia Mística 10 de 13). Cada país paga numa moeda (USD, GBP, EUR, BRL), então qualquer comparação de custo precisa de câmbio.
- **Educação:** a escola é o que está mais espalhado internacionalmente (Argentina, Peru, Brasil, França, Japão...), mas o único talento contratado foi pra TI em Gotham. Ainda não tem ponte da escola com os escritórios dos outros países.

```sql
-- escritórios e departamentos por região
SELECT r.regiao_nome, COUNT(DISTINCT e.escritorio_id) AS escritorios,
       SUM(d.educacional = 0) AS deps_comerciais, SUM(d.educacional = 1) AS deps_escola
FROM escritorios e
JOIN paises p ON p.pais_id = e.pais_id
JOIN regioes r ON r.regiao_id = p.regiao_id
LEFT JOIN departamentos d ON d.escritorio_id = e.escritorio_id
GROUP BY r.regiao_nome;

-- de onde saem as vendas
SELECT p.pais_nome, e.escritorio_nome, COUNT(DISTINCT v.venda_id) AS vendas, SUM(i.quantidade * i.preco_unitario) AS receita
FROM vendas v
JOIN itens_venda i ON i.venda_id = v.venda_id
JOIN funcionarios f ON f.funcionario_id = v.funcionario_id
JOIN departamentos d ON d.departamento_id = f.departamento_id
JOIN escritorios e ON e.escritorio_id = d.escritorio_id
JOIN paises p ON p.pais_id = e.pais_id
GROUP BY p.pais_nome, e.escritorio_nome;

-- funcionários por região
SELECT r.regiao_nome, COUNT(*) AS funcionarios, SUM(d.educacional) AS da_escola
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
JOIN escritorios e ON e.escritorio_id = d.escritorio_id
JOIN paises p ON p.pais_id = e.pais_id
JOIN regioes r ON r.regiao_id = p.regiao_id
GROUP BY r.regiao_nome
ORDER BY funcionarios DESC;
```

## Nível 9: Análise Avançada com Agregações

**9.1** Crie um relatório mostrando cada departamento com: nome do departamento, número de funcionários, salário total e média salarial.

R: Entre os comerciais, Dados e Inteligência tem a maior folha (85.328,25 com só 3 pessoas). Inovações aparece com os 2 que eu transferi. A view `folha_departamentos` já faz isso, mas não separa moeda.

```sql
SELECT d.departamento_nome, f.moeda_salario,
       COUNT(f.funcionario_id) AS funcionarios,
       SUM(f.salario) AS salario_total,
       ROUND(AVG(f.salario), 2) AS media_salarial
FROM departamentos d
LEFT JOIN funcionarios f ON f.departamento_id = d.departamento_id
GROUP BY d.departamento_id, d.departamento_nome, f.moeda_salario
ORDER BY d.departamento_nome;
```

**9.2** Liste os 3 cargos mais comuns na empresa e quantos funcionários ocupam cada cargo.

R: Cientista de Dados (8), Professor Assistente (8) e Desenvolvedor Web (7)

```sql
SELECT c.cargo_nome, COUNT(*) AS funcionarios
FROM funcionarios f
JOIN cargos c ON c.cargo_id = f.cargo_id
GROUP BY c.cargo_nome
ORDER BY funcionarios DESC
LIMIT 3;
```

**9.3** Encontre todos os funcionários que ganham acima da média salarial de seus respectivos departamentos.

R: 45 funcionários (comparando com a média do departamento na mesma moeda)

```sql
SELECT f.primeiro_nome, f.sobrenome, d.departamento_nome, f.salario, f.moeda_salario
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE f.salario > (SELECT AVG(f2.salario)
                   FROM funcionarios f2
                   WHERE f2.departamento_id = f.departamento_id
                     AND f2.moeda_salario = f.moeda_salario)
ORDER BY d.departamento_nome, f.salario DESC;
```

**9.4** Calcule a taxa de crescimento da empresa por ano (quantos funcionários foram contratados a cada ano).

R: De 1987 a 2010 eram 2 a 4 contratações por ano. A partir de 2011 começa a subir (4 a 5 por ano) e de 2015 a 2019 foi o pico, com 6 por ano (época da expansão da escola). De 2020 em diante caiu para 1 a 3 por ano.

```sql
SELECT YEAR(data_contratacao) AS ano,
       COUNT(*) AS contratados,
       SUM(COUNT(*)) OVER (ORDER BY YEAR(data_contratacao)) AS total_acumulado
FROM funcionarios
GROUP BY ano
ORDER BY ano;
```

**9.5** Crie um ranking dos vendedores, mostrando: nome do vendedor, número de vendas realizadas e receita total gerada.

R: (vendas concluídas)

| # | Vendedor | Vendas | Receita |
|---|---|---|---|
| 1 | Jack Livingston | 10 | 187.825,62 |
| 2 | Jonathon Taylor | 9 | 167.818,10 |
| 3 | John Russell | 10 | 162.840,00 |
| 4 | Kimberly Grant | 8 | 136.918,04 |
| 5 | Karen Partners | 9 | 124.660,18 |

```sql
SELECT RANK() OVER (ORDER BY SUM(i.quantidade * i.preco_unitario) DESC) AS posicao,
       CONCAT(f.primeiro_nome, ' ', f.sobrenome) AS vendedor,
       COUNT(DISTINCT v.venda_id) AS vendas,
       SUM(i.quantidade * i.preco_unitario) AS receita
FROM vendas v
JOIN itens_venda i ON i.venda_id = v.venda_id
JOIN funcionarios f ON f.funcionario_id = v.funcionario_id
JOIN status_venda sv ON sv.status_venda_id = v.status_venda_id
WHERE sv.nome = 'CONCLUIDA'
GROUP BY f.funcionario_id, f.primeiro_nome, f.sobrenome;
```

**9.6** Encontre os produtos que foram vendidos por apenas um vendedor.

R: 8 produtos: Blaster Imperial, Capa do Batman, Capacete Darth Vader, Capacete Iron Man Mark 5, Chapéu Seletor, Escudo do Capitão América, Pokébola clássica e Sabre de luz de Mace Windu

```sql
SELECT p.produto_nome, COUNT(DISTINCT v.funcionario_id) AS vendedores
FROM itens_venda i
JOIN vendas v ON v.venda_id = i.venda_id
JOIN produtos p ON p.produto_id = i.produto_id
GROUP BY p.produto_id, p.produto_nome
HAVING COUNT(DISTINCT v.funcionario_id) = 1;
```

---

## Nível 10:  Auditoria de Vendas

O departamento financeiro suspeita de irregularidades.

**10.1** Encontre vendas que não possuem vendedor associado.

R: Nenhuma. O `funcionario_id` em vendas é NOT NULL, então o próprio banco não deixa.

```sql
SELECT * FROM vendas WHERE funcionario_id IS NULL;
```

**10.2** Verifique se há vendedores registrados nas vendas que não existem na coleção de funcionários.

R: Nenhum, a chave estrangeira `fk_vendas_funcionario` garante isso. Todos os vendedores são do departamento de Vendas. (No CSV do nível 11 aparece um vendedor que não existe, o `nao.existe@momento.org`, e ele foi barrado no ETL.)

```sql
SELECT v.*
FROM vendas v
LEFT JOIN funcionarios f ON f.funcionario_id = v.funcionario_id
WHERE f.funcionario_id IS NULL;
```

**10.3** Identifique produtos que aparecem nas vendas mas com preços unitários muito diferentes entre transações (variação > 10%).

R: 15 produtos. Os maiores são Batarang de treino (25% de variação, 198,88 a 248,62), Anel do Poder (23,1%), Laço da Verdade (22,5%) e Lança-Teias (22,5%). Pode ser desconto ou promoção, mas vale auditar.

```sql
SELECT p.produto_nome,
       MIN(i.preco_unitario) AS menor_preco,
       MAX(i.preco_unitario) AS maior_preco,
       ROUND((MAX(i.preco_unitario) - MIN(i.preco_unitario)) / MIN(i.preco_unitario) * 100, 1) AS variacao_pct
FROM itens_venda i
JOIN produtos p ON p.produto_id = i.produto_id
GROUP BY p.produto_id, p.produto_nome
HAVING variacao_pct > 10
ORDER BY variacao_pct DESC;
```

**10.4** O CEO pediu um dashboard completo.

Crie UMA ÚNICA query de agregação que retorne:
   - Total de funcionários
   - Custo total com salários
   - Número de departamentos
   - Número de escritórios
   - Receita total de vendas
   - Produto mais vendido

R: 124 funcionários | 936.622,29 USD em salários (só a parte em dólar) | 31 departamentos | 20 escritórios | 780.061,94 USD de receita concluída | Reator Arc decorativo

```sql
SELECT
  (SELECT COUNT(*) FROM funcionarios) AS total_funcionarios,
  (SELECT SUM(salario) FROM funcionarios WHERE moeda_salario = 'USD') AS custo_salarios_usd,
  (SELECT COUNT(*) FROM departamentos) AS departamentos,
  (SELECT COUNT(*) FROM escritorios) AS escritorios,
  (SELECT SUM(i.quantidade * i.preco_unitario)
     FROM itens_venda i
     JOIN vendas v ON v.venda_id = i.venda_id
     JOIN status_venda sv ON sv.status_venda_id = v.status_venda_id
    WHERE sv.nome = 'CONCLUIDA') AS receita_total,
  (SELECT p.produto_nome
     FROM itens_venda i
     JOIN produtos p ON p.produto_id = i.produto_id
    GROUP BY p.produto_id, p.produto_nome
    ORDER BY SUM(i.quantidade) DESC
    LIMIT 1) AS produto_mais_vendido;
```

---

## Nível 11: ETL do CSV

O arquivo [vendas_campanha_bruto.csv](vendas_campanha_bruto.csv) contém dados de pedidos e itens em formatos variados. 
O que você deve fazer: carregá-lo na tabela `stg_vendas_csv`, sem converter nem corrigir os valores na importação. 

> stg é uma abreviação de staging (preparação, em portugês): uma área intermediária onde os dados brutos são carregados antes de serem tratados e enviados às tabelas finais.

Neste exercício, stg_vendas_csv recebe o conteúdo do CSV como chegou. Depois, os dados são validados e transformados, carregados os aceitos em vendas e itens_venda. Então, são documentados os casos problemáticos em etl_rejeicoes. Apesar do nome, essa tabela não é necessariamente temporária: ela pode ser mantida para rastrear a origem dos dados.

**Dica**: No MySQL Workbench, vocês podem usar o **Table Data Import Wizard** apontando para a tabela já criada, com delimitador `;` e a primeira linha como cabeçalho. Se o ambiente permitir `LOAD DATA LOCAL INFILE`, também é possível usá-lo.

Construam um fluxo com estas fases:

1. **Extract:** importar todas as linhas e conservar `source_row_id` e `lote_origem`.
2. **Transform:** normalizar espaços e capitalização; converter quantidades, datas e preços; padronizar canal e status; conferir SKU e e-mail do vendedor; identificar duplicatas e conflitos.
3. **Load:** inserir pedidos em `vendas` e linhas em `itens_venda`. Registrar pendências ou rejeições em `etl_rejeicoes`, preservando o valor original, o campo e o motivo.

Regras para orientar a análise:

- usem `locale_origem` ao interpretar datas e separadores decimais; se a localidade não estiver identificada, não escolham uma interpretação por palpite;
- `moeda_raw` precisa ser identificável; preservem a moeda original do registro;
- SKU desconhecido, vendedor sem correspondência, quantidade inválida, data impossível ou preço não interpretável precisam de tratamento documentado;
- linhas com a mesma combinação pedido/item podem ser duplicatas ou correções conflitantes. Compare os demais campos antes de decidir;
- se um pedido tiver uma linha pendente, decidam se carregam as linhas válidas ou mantêm o pedido inteiro em revisão. Registrem o critério usado;
- `source_row_id` em `itens_venda` liga uma linha carregada à linha original do CSV.

A tabela `etl_rejeicoes` foi criada para documentar decisões. Um registro rejeitado não deve desaparecer silenciosamente: indiquem se foi duplicata, rejeição definitiva ou revisão manual.

R: Fiz tudo em SQL. O script completo está no [resposta_dos_exercicios_8.sql](resposta_dos_exercicios_8.sql). Resumo:

**Extract:** `LOAD DATA LOCAL INFILE` na `stg_vendas_csv` com `;`, pulando o cabeçalho. 28 linhas, tudo como texto, sem mexer em nada.

**Transform:** criei uma tabela de trabalho `stg_vendas_tratada` (a stg original continua intacta) com:
- `TRIM` + `UPPER` no SKU (`'  mar-002  '` → `MAR-002`) e `TRIM` + `LOWER` no e-mail;
- data pelo locale: `ISO` = aaaa-mm-dd, `pt-BR` = dd/mm/aaaa, `en-US` = mm/dd/aaaa, conferindo se o dia existe no mês com `LAST_DAY`;
- preço: tira `US$`, `R$`, `$`; no pt-BR o ponto é milhar e a vírgula é decimal (`1.250,00` → 1250.00), no ISO/en-US a vírgula é milhar (`4,500.00` → 4500.00);
- canal: web/Online → WEB, loja/Loja/loja física → LOJA, app → APP, marketplace → MARKETPLACE;
- status: paid/pago/concluída/CONCLUIDA → CONCLUIDA, cancelado → CANCELADA, pending → PENDENTE;
- moeda: só aceita USD, BRL, EUR, GBP e mantém a original (as vendas do Brasil ficaram em BRL);
- corrigi o status 2 da `status_venda`, que estava com o nome `'1'`, para `PENDENTE`.

**Critério do pedido:** se uma linha do pedido está em revisão, **o pedido inteiro fica em revisão**. Prefiro não carregar pedido pela metade e depois ter que remendar.

**Resultado: 13 linhas carregadas + 15 documentadas = 28** (nenhuma sumiu).

| Linha | Pedido | Decisão | Motivo |
|---|---|---|---|
| 1 | EXT-9001 | REVISAR | Conflito: pedido/item 1 aparece com quantidade 2 e 3 |
| 2 | EXT-9001 | REVISAR | Linha válida, mas o pedido está em revisão. (O preço 80,50 também está bem abaixo do catálogo, 200) |
| 3 | EXT-9001 | DUPLICATA | Cópia idêntica da linha 1 depois de normalizar |
| 5 | EXT-9003 | REVISAR | Locale `?`: `05/06/25` e `239,29` são ambíguos, não chutei |
| 6 | EXT-9004 | REJEITAR | 31/02/2025 não existe |
| 7 | EXT-9005 | REJEITAR | SKU-404 não existe no catálogo |
| 8 | EXT-9006 | REVISAR | Vendedor nao.existe@momento.org não existe |
| 9 | EXT-9007 | REJEITAR | Quantidade 0 |
| 10 | EXT-9008 | REJEITAR | Quantidade -2 |
| 13 | EXT-9001 | REVISAR | Conflito com a linha 1 (quantidade 3) |
| 16 | EXT-9013 | REVISAR | Canal "TikTok Shop" não cadastrado |
| 18 | EXT-9015 | REVISAR | Moeda vazia, o `$` sozinho não diz qual moeda é |
| 19 | EXT-9016 | REJEITAR | Moeda XYZ não existe |
| 20 | EXT-9017 | REJEITAR | Preço "N/A" |
| 21 | EXT-9018 | REVISAR | Quantidade "dois" por extenso, precisa confirmar |

Carregadas (vendas 7055 a 7067): EXT-9002, 9009, 9010, 9011 (cancelada), 9012, 9014, 9019, 9020, 9021, 9022, 9023, 9024, 9025.

```sql
-- conferência final: toda linha do CSV está carregada OU documentada
SELECT (SELECT COUNT(*) FROM itens_venda WHERE source_row_id IS NOT NULL) AS carregadas,
       (SELECT COUNT(*) FROM etl_rejeicoes) AS documentadas,
       (SELECT COUNT(*) FROM stg_vendas_csv) AS total_csv;

-- nenhuma linha pode sobrar aqui
SELECT s.source_row_id
FROM stg_vendas_csv s
WHERE s.source_row_id NOT IN (SELECT source_row_id FROM itens_venda WHERE source_row_id IS NOT NULL)
  AND s.source_row_id NOT IN (SELECT source_row_id FROM etl_rejeicoes);

-- rastreabilidade: venda carregada -> linha original do CSV
SELECT i.venda_id, i.produto_id, i.quantidade, i.preco_unitario, i.moeda, s.*
FROM itens_venda i
JOIN stg_vendas_csv s ON s.source_row_id = i.source_row_id;

SELECT r.source_row_id, a.nome AS acao, r.campo, r.valor_original, r.motivo
FROM etl_rejeicoes r
JOIN acoes_etl a ON a.acao_etl_id = r.acao_etl_id
ORDER BY r.source_row_id;
```

## Nível 12: Alterações seguras

Façam alterações em transações e verifiquem o resultado antes de confirmar:

- criar um departamento novo em um escritório existente;
- cadastrar o cargo “Senior Web Developer” e promover Bruce Ernst, atualizando cargo e salário;
- transferir duas pessoas de Tecnologia para o novo departamento, justificando a escolha;
- reajustar salários de quem permanecer em Tecnologia;
- adicionar uma compra de headsets com quantidade, custo unitário, moeda, data e referência de compra;
- simular aposentadoria alterando o status do funcionário para `INATIVO`, sem apagar o funcionário nem seu histórico.

Exemplo de fluxo seguro:

```sql
START TRANSACTION;
-- faça a alteração planejada
-- confira com SELECT se o resultado corresponde ao esperado
ROLLBACK; -- use COMMIT somente quando estiver validado
```

R: Fiz tudo numa transação só, com um SELECT de conferência depois de cada passo e ROLLBACK no final (dá pra trocar por COMMIT quando tiver validado). Script completo no [resposta_dos_exercicios_8.sql](resposta_dos_exercicios_8.sql).

- **Departamento novo:** "Games e Realidade Virtual" na Stark Tower (escritório que já existe).
- **Cargo:** o "Senior Web Developer" **já existe** na base (cargo 26), então usei `INSERT ... WHERE NOT EXISTS` pra não duplicar. Promovi o Bruce para **7.500**, dentro da faixa (7.000 a 16.000), corrigindo o problema do 6.4.
- **Transferência:** Valli Stark e Diana Lorentz. São Desenvolvedores Web experientes (desde 1990), e TI continua com Alexander, David, Ariel e eu como devs, então o time não fica descoberto. Não escolhi o Bruce porque acabou de ser promovido em TI.
- **Reajuste:** 5% para quem ficou em TI (6 pessoas). Folha foi de 43.032,83 para 45.184,47.
- **Headsets:** 20 unidades a 149,90 USD, referência PO-1500-HS-2025, na Stark Tower.
- **Aposentadoria:** Neena Kochhar (contratada em 1987) foi para INATIVO. Os 2 dependentes e o registro do audit_log continuam lá.

```sql
START TRANSACTION;

INSERT INTO departamentos (departamento_id, departamento_nome, educacional, escritorio_id)
VALUES ((SELECT MAX(d.departamento_id) + 1 FROM departamentos d), 'Games e Realidade Virtual', 0,
        (SELECT escritorio_id FROM escritorios WHERE escritorio_nome = 'Stark Tower'));
SELECT * FROM departamentos WHERE departamento_nome = 'Games e Realidade Virtual';

INSERT INTO cargos (cargo_id, cargo_nome, min_salario, max_salario)
SELECT (SELECT MAX(c.cargo_id) + 1 FROM cargos c), 'Senior Web Developer', 7000.00, 16000.00
WHERE NOT EXISTS (SELECT 1 FROM cargos WHERE cargo_nome = 'Senior Web Developer');

UPDATE funcionarios
SET cargo_id = (SELECT cargo_id FROM cargos WHERE cargo_nome = 'Senior Web Developer'), salario = 7500.00
WHERE email = 'bruce.ernst@momento.org';
SELECT * FROM radar_salarial WHERE funcionario_nome = 'Bruce Ernst';

UPDATE funcionarios
SET departamento_id = (SELECT departamento_id FROM (SELECT departamento_id FROM departamentos WHERE departamento_nome = 'Games e Realidade Virtual') x)
WHERE email IN ('valli.stark@momento.org', 'diana.lorentz@momento.org');

UPDATE funcionarios
SET salario = ROUND(salario * 1.05, 2)
WHERE departamento_id = (SELECT departamento_id FROM (SELECT departamento_id FROM departamentos WHERE departamento_nome = 'Tecnologia da Informação') x);
SELECT * FROM dados_funcionarios WHERE departamento IN ('Tecnologia da Informação', 'Games e Realidade Virtual');

INSERT INTO suprimentos (suprimento_id, referencia_compra, suprimento_nome, quantidade_estoque, custo_unitario, moeda, data_compra, escritorio_id)
VALUES ((SELECT MAX(s.suprimento_id) + 1 FROM suprimentos s), 'PO-1500-HS-2025', 'Headsets', 20, 149.90, 'USD', CURDATE(),
        (SELECT escritorio_id FROM escritorios WHERE escritorio_nome = 'Stark Tower'));
SELECT * FROM suprimentos WHERE referencia_compra = 'PO-1500-HS-2025';

UPDATE funcionarios
SET status_funcionario_id = (SELECT status_funcionario_id FROM status_funcionario WHERE nome = 'INATIVO')
WHERE email = 'neena.kochhar@momento.org';
SELECT funcionario_nome, situacao FROM dados_funcionarios WHERE funcionario_nome = 'Neena Kochhar';
SELECT COUNT(*) AS dependentes_mantidos FROM dependentes WHERE funcionario_id = 101;

ROLLBACK; -- COMMIT só depois de conferir tudo
```
