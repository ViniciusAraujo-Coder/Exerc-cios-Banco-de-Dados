USE hotel_nebula;

/* 1. Quais quartos estão disponíveis em determinado período? */
SET @inicio = '2026-12-20';
SET @fim    = '2026-12-27';

SELECT q.numero, q.tipo, q.capacidade, q.preco_diaria
FROM quartos q
WHERE q.status = 'DISPONIVEL'
  AND NOT EXISTS (
      SELECT 1
      FROM reservas r
      WHERE r.id_quarto = q.id_quarto
        AND r.status <> 'CANCELADA'
        AND r.data_checkin < @fim
        AND r.data_checkout > @inicio
  )
ORDER BY q.numero;


/* 2. Quais hóspedes mais realizaram reservas? */
SELECT h.nome,
       COUNT(r.id_reserva) AS total_reservas,
       SUM(r.status = 'CONCLUIDA') AS concluidas,
       SUM(r.status = 'CANCELADA') AS canceladas
FROM hospedes h
JOIN reservas r ON r.id_hospede = h.id_hospede
GROUP BY h.id_hospede, h.nome
ORDER BY total_reservas DESC, concluidas DESC
LIMIT 5;


/* 3. Qual foi o faturamento por mês? */
SELECT DATE_FORMAT(data_pagamento, '%Y-%m') AS mes,
       COUNT(*) AS pagamentos,
       SUM(valor) AS faturamento
FROM pagamentos
WHERE status = 'APROVADO'
GROUP BY mes
ORDER BY mes;


/* 4. Quais serviços extras são mais consumidos? */
SELECT s.nome, s.categoria,
       SUM(hs.quantidade) AS quantidade_consumida,
       COUNT(DISTINCT hs.id_hospedagem) AS hospedagens_que_usaram,
       SUM(hs.quantidade * hs.preco_unitario) AS receita
FROM servicos s
LEFT JOIN hospedagem_servicos hs ON hs.id_servico = s.id_servico
GROUP BY s.id_servico, s.nome, s.categoria
ORDER BY quantidade_consumida DESC;


/* 5. Quais quartos receberam melhores avaliações? */
SELECT q.numero, q.tipo,
       COUNT(f.id_feedback) AS avaliacoes,
       ROUND(AVG(f.nota_geral), 2) AS media_geral,
       ROUND(AVG(f.nota_limpeza), 2) AS media_limpeza,
       ROUND(AVG(f.nota_atendimento), 2) AS media_atendimento
FROM feedbacks f
JOIN hospedagens h ON h.id_hospedagem = f.id_hospedagem
JOIN reservas r ON r.id_reserva = h.id_reserva
JOIN quartos q ON q.id_quarto = r.id_quarto
GROUP BY q.id_quarto, q.numero, q.tipo
ORDER BY media_geral DESC, avaliacoes DESC;


/* 6. Quais reservas foram canceladas? */
SELECT r.id_reserva, h.nome AS hospede, q.numero AS quarto,
       r.data_checkin, r.data_checkout,
       r.data_cancelamento, r.motivo_cancelamento,
       DATEDIFF(r.data_checkin, r.data_cancelamento) AS dias_de_antecedencia,
       DATEDIFF(r.data_checkout, r.data_checkin) * r.valor_diaria AS receita_perdida
FROM reservas r
JOIN hospedes h ON h.id_hospede = r.id_hospede
JOIN quartos q ON q.id_quarto = r.id_quarto
WHERE r.status = 'CANCELADA'
ORDER BY r.data_cancelamento;


/* 7. Quantas hospedagens cada profissional atendeu? */
SELECT f.nome, f.cargo, COUNT(h.id_hospedagem) AS hospedagens_atendidas
FROM funcionarios f
LEFT JOIN hospedagens h ON h.id_funcionario = f.id_funcionario
GROUP BY f.id_funcionario, f.nome, f.cargo
ORDER BY hospedagens_atendidas DESC;


/* 8. Taxa de ocupação por mês */
WITH RECURSIVE dias AS (
  SELECT DATE('2026-01-01') AS dia
  UNION ALL
  SELECT dia + INTERVAL 1 DAY FROM dias WHERE dia < '2026-11-30'
)
SELECT DATE_FORMAT(d.dia, '%Y-%m') AS mes,
       COUNT(r.id_reserva) AS noites_ocupadas,
       COUNT(DISTINCT d.dia) * (SELECT COUNT(*) FROM quartos WHERE status = 'DISPONIVEL') AS noites_possiveis,
       ROUND(COUNT(r.id_reserva) / (COUNT(DISTINCT d.dia) * (SELECT COUNT(*) FROM quartos WHERE status = 'DISPONIVEL')) * 100, 1) AS ocupacao_pct
FROM dias d
LEFT JOIN reservas r
       ON r.status IN ('CONCLUIDA', 'CONFIRMADA')
      AND d.dia >= r.data_checkin AND d.dia < r.data_checkout
GROUP BY mes
ORDER BY mes;


/* 9. Quem está hospedado agora? */
SELECT ho.nome, q.numero, h.checkin_real, r.data_checkout AS saida_prevista
FROM hospedagens h
JOIN reservas r ON r.id_reserva = h.id_reserva
JOIN hospedes ho ON ho.id_hospede = r.id_hospede
JOIN quartos q ON q.id_quarto = r.id_quarto
WHERE h.checkout_real IS NULL;


/* 10. Conta de cada estadia */
SELECT h.id_hospedagem, ho.nome, q.numero,
       DATEDIFF(r.data_checkout, r.data_checkin) * r.valor_diaria AS diarias,
       COALESCE((SELECT SUM(hs.quantidade * hs.preco_unitario) FROM hospedagem_servicos hs WHERE hs.id_hospedagem = h.id_hospedagem), 0) AS servicos,
       COALESCE((SELECT SUM(p.valor) FROM pagamentos p WHERE p.id_hospedagem = h.id_hospedagem AND p.status = 'APROVADO'), 0) AS pago
FROM hospedagens h
JOIN reservas r ON r.id_reserva = h.id_reserva
JOIN hospedes ho ON ho.id_hospede = r.id_hospede
JOIN quartos q ON q.id_quarto = r.id_quarto
ORDER BY h.id_hospedagem;
