use oscar_databe;

/* 1.1 Quantos registros existem na tabela de indicados ao Oscar? */
SELECT count(*) from indicados_ao_oscar;

/* 1.2.1 Quais são as diferentes categorias de premiação que existem no banco de dados? Liste todas as categorias únicas. */
SELECT DISTINCT categoria FROM indicados_ao_oscar;

/* 1.2.2 **Quantas** categorias únicas existem? */
SELECT COUNT(DISTINCT categoria) FROM indicados_ao_oscar;

/* 1.3 Qual foi o primeiro ano de cerimônia do Oscar registrado na base? */
SELECT MIN(ano_cerimonia) FROM indicados_ao_oscar;

/* 1.4 Qual foi o último ano de cerimônia registrado na base? */
SELECT MAX(ano_cerimonia) FROM indicados_ao_oscar;

/* 1.5 Quantas cerimônias do Oscar estão registradas no total? */
SELECT COUNT(distinct ano_cerimonia) FROM indicados_ao_oscar;

/* 1.6 Atualize os registros da tabela com os dados do Oscar 2025 e 2026 (pesquise os vencedores e adicione-os). */
SELECT ano_cerimonia, edicao_cerimonia, COUNT(*) AS total_vencedores
FROM indicados_ao_oscar
WHERE ano_cerimonia IN (2025, 2026)
GROUP BY ano_cerimonia, edicao_cerimonia;

/* 2.1 Quantas indicações existem para cada categoria? Agrupe por categoria e ordene da mais frequente para a menos frequente. */
SELECT categoria, COUNT(*) FROM indicados_ao_oscar GROUP BY categoria ORDER BY count(*)desc;

/* 2.2 Qual categoria teve mais indicações ao longo da história do Oscar? */
SELECT categoria, COUNT(*) FROM indicados_ao_oscar GROUP BY categoria ORDER BY COUNT(*) DESC LIMIT 1;

/* 2.3 Qual categoria teve menos indicações ao longo da história? */
SELECT categoria, COUNT(*) FROM indicados_ao_oscar GROUP BY categoria ORDER BY COUNT(*) ASC LIMIT 1;

/* 2.4 A partir de que ano a categoria "ACTRESS" deixou de existir? (Dica: procure a última cerimônia com essa categoria)
 */
SELECT MAX(ano_cerimonia)
FROM indicados_ao_oscar
WHERE categoria = 'ACTRESS';

/* 2.5 Quais categorias existiam na primeira cerimônia (1928) e não existem mais hoje? */