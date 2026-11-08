USE oscar_database;
SET SQL_SAFE_UPDATES = 0;

DESCRIBE indicados_ao_oscar;
SELECT vencedor, COUNT(*) FROM indicados_ao_oscar GROUP BY vencedor;

-- 7.2 Três filmes nunca indicados que merecem (fictício)

INSERT INTO indicados_ao_oscar (ano_filmagem, ano_cerimonia, edicao_cerimonia, categoria, nome_indicado, nome_filme, vencedor) VALUES (2000, 2001, 73, 'BEST PICTURE', 'Guel Arraes (indicação fictícia)', 'O Auto da Compadecida', false);
INSERT INTO indicados_ao_oscar (ano_filmagem, ano_cerimonia, edicao_cerimonia, categoria, nome_indicado, nome_filme, vencedor) VALUES (2007, 2008, 80, 'BEST PICTURE', 'José Padilha (indicação fictícia)', 'Tropa de Elite', false);
INSERT INTO indicados_ao_oscar (ano_filmagem, ano_cerimonia, edicao_cerimonia, categoria, nome_indicado, nome_filme, vencedor) VALUES (2019, 2020, 92, 'BEST PICTURE', 'Kleber Mendonça Filho e Juliano Dornelles (indicação fictícia)', 'Bacurau', false);

SELECT * FROM indicados_ao_oscar WHERE nome_indicado LIKE '%fictícia%';


-- 7.3 Nova categoria BEST INTERNATIONAL FEATURE FILM (2020-2024)

INSERT INTO indicados_ao_oscar (ano_filmagem, ano_cerimonia, edicao_cerimonia, categoria, nome_indicado, nome_filme, vencedor) VALUES (2019, 2020, 92, 'BEST INTERNATIONAL FEATURE FILM', 'South Korea', 'Parasite', true);
INSERT INTO indicados_ao_oscar (ano_filmagem, ano_cerimonia, edicao_cerimonia, categoria, nome_indicado, nome_filme, vencedor) VALUES (2020, 2021, 93, 'BEST INTERNATIONAL FEATURE FILM', 'Denmark', 'Another Round', true);
INSERT INTO indicados_ao_oscar (ano_filmagem, ano_cerimonia, edicao_cerimonia, categoria, nome_indicado, nome_filme, vencedor) VALUES (2021, 2022, 94, 'BEST INTERNATIONAL FEATURE FILM', 'Japan', 'Drive My Car', true);
INSERT INTO indicados_ao_oscar (ano_filmagem, ano_cerimonia, edicao_cerimonia, categoria, nome_indicado, nome_filme, vencedor) VALUES (2022, 2023, 95, 'BEST INTERNATIONAL FEATURE FILM', 'Germany', 'All Quiet on the Western Front', true);
INSERT INTO indicados_ao_oscar (ano_filmagem, ano_cerimonia, edicao_cerimonia, categoria, nome_indicado, nome_filme, vencedor) VALUES (2023, 2024, 96, 'BEST INTERNATIONAL FEATURE FILM', 'United Kingdom', 'The Zone of Interest', true);

SELECT * FROM indicados_ao_oscar WHERE categoria = 'BEST INTERNATIONAL FEATURE FILM';


-- 7.4 Corrigir erros de digitação nos nomes dos filmes

-- achar (os colchetes mostram os espaços sobrando)
SELECT CONCAT('[', nome_filme, ']') AS nome
FROM indicados_ao_oscar
WHERE nome_filme <> TRIM(nome_filme) OR nome_filme LIKE '%  %';

-- corrigir
UPDATE indicados_ao_oscar SET nome_filme = TRIM(nome_filme) WHERE nome_filme <> TRIM(nome_filme);
UPDATE indicados_ao_oscar SET nome_filme = REPLACE(nome_filme, '  ', ' ') WHERE nome_filme LIKE '%  %';
UPDATE indicados_ao_oscar SET nome_filme = 'The Accountant' WHERE nome_filme = 'the accountant';
UPDATE indicados_ao_oscar SET nome_filme = 'The Dove' WHERE nome_filme = 'The Dove;';

-- conferir (deve dar 0)
SELECT COUNT(*) AS ainda_com_erro
FROM indicados_ao_oscar
WHERE nome_filme <> TRIM(nome_filme) OR nome_filme LIKE '%  %';


-- 7.5 Remover registros com NULL no nome do filme

SELECT COUNT(*) AS sem_filme_antes FROM indicados_ao_oscar WHERE nome_filme IS NULL;
DELETE FROM indicados_ao_oscar WHERE nome_filme IS NULL;
SELECT COUNT(*) AS sem_filme_depois FROM indicados_ao_oscar WHERE nome_filme IS NULL;