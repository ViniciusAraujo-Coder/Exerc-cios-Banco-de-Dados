# Hotel Nebula - Modelo Lógico


---

## Tabelas

### hospedes
| Coluna           | Tipo           | Restrições        |
|------------------|----------------|-------------------|
| id_hospede       | INT            | PK, AUTO_INCREMENT |
| nome             | VARCHAR(100)   | NOT NULL          |
| email            | VARCHAR(100)   | UNIQUE, NOT NULL  |
| cpf              | VARCHAR(14)    | UNIQUE            |
| documento      | VARCHAR(30)    | passaporte/RG para estrangeiros |
| telefone         | VARCHAR(20)    |                   |
| data_nascimento  | DATE           |                   |
| cidade         | VARCHAR(60)    |                   |
| pais           | VARCHAR(60)    | NOT NULL, DEFAULT 'Brasil' |
| data_cadastro  | DATE           | NOT NULL, DEFAULT CURRENT_DATE |
|                  |                | CHECK (cpf ou documento preenchido) |

---

### quartos
| Coluna       | Tipo           | Restrições         |
|--------------|----------------|--------------------|
| id_quarto    | INT            | PK, AUTO_INCREMENT |
| numero       | VARCHAR(10)    | UNIQUE, NOT NULL   |
| andar      | INT            | NOT NULL           |
| tipo         | VARCHAR(50)    | NOT NULL, CHECK IN ('STANDARD','LUXO','SUITE','FAMILIA') |
| capacidade   | INT            | NOT NULL, CHECK 1 a 6 |
| preco_diaria | DECIMAL(10,2)  | NOT NULL, CHECK > 0 |
| status       | VARCHAR(20)    | NOT NULL, DEFAULT 'DISPONIVEL', CHECK IN ('DISPONIVEL','MANUTENCAO','INATIVO') |
| descricao  | VARCHAR(255)   |                    |

> status aqui é só se o quarto pode ser usado ou não. Se ta ocupado num dia eu vejo pelas reservas.

---

### reservas
| Coluna                | Tipo          | Restrições         |
|-----------------------|---------------|--------------------|
| id_reserva            | INT           | PK, AUTO_INCREMENT |
| id_hospede            | INT           | FK → hospedes, NOT NULL |
| id_quarto             | INT           | FK → quartos, NOT NULL |
| id_funcionario      | INT           | FK → funcionarios (quem registrou; nulo = site) |
| data_reserva        | DATETIME      | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| data_checkin          | DATE          | NOT NULL           |
| data_checkout         | DATE          | NOT NULL, CHECK > data_checkin |
| qtd_hospedes        | INT           | NOT NULL, CHECK > 0 |
| valor_diaria        | DECIMAL(10,2) | NOT NULL (preço combinado na hora da reserva) |
| canal               | VARCHAR(20)   | CHECK IN ('SITE','TELEFONE','BALCAO','AGENCIA') |
| status                | VARCHAR(20)   | NOT NULL, CHECK IN ('PENDENTE','CONFIRMADA','CANCELADA','CONCLUIDA') |
| data_cancelamento   | DATETIME      | obrigatória se status = CANCELADA |
| motivo_cancelamento | VARCHAR(255)  |                    |

---

### hospedagens
| Coluna            | Tipo         | Restrições           |
|-------------------|--------------|----------------------|
| id_hospedagem     | INT          | PK, AUTO_INCREMENT   |
| id_reserva        | INT          | FK → reservas, NOT NULL, UNIQUE (garante o 1:1) |
| id_funcionario  | INT          | FK → funcionarios, NOT NULL (quem fez o check-in) |
| checkin_real      | DATETIME     | NOT NULL           |
| checkout_real     | DATETIME     | nulo = ainda hospedado, CHECK > checkin_real |
| observacoes     | VARCHAR(255) |                      |

---

### pagamentos
| Coluna           | Tipo          | Restrições           |
|------------------|---------------|----------------------|
| id_pagamento     | INT           | PK, AUTO_INCREMENT   |
| id_hospedagem    | INT           | FK → hospedagens, NOT NULL |
| data_pagamento | DATETIME      | NOT NULL             |
| valor            | DECIMAL(10,2) | NOT NULL, CHECK > 0 |
| metodo           | VARCHAR(30)   | NOT NULL, CHECK IN ('PIX','CREDITO','DEBITO','DINHEIRO') |
| parcelas       | INT           | NOT NULL, DEFAULT 1, CHECK 1 a 12, só crédito parcela |
| status         | VARCHAR(20)   | NOT NULL, CHECK IN ('PENDENTE','APROVADO','ESTORNADO') |

---

### funcionarios
| Coluna          | Tipo          | Restrições         |
|-----------------|---------------|--------------------|
| id_funcionario  | INT           | PK, AUTO_INCREMENT |
| nome            | VARCHAR(100)  | NOT NULL           |
| cargo           | VARCHAR(50)   | NOT NULL         |
| email         | VARCHAR(100)  | NOT NULL, UNIQUE   |
| telefone      | VARCHAR(20)   |                    |
| data_admissao | DATE          | NOT NULL           |
| salario       | DECIMAL(10,2) | NOT NULL, CHECK > 0 |
| ativo         | BOOLEAN       | NOT NULL, DEFAULT TRUE |

---

### servicos
> serviços extras do hotel

| Coluna     | Tipo          | Restrições |
|------------|---------------|------------|
| id_servico | INT           | PK, AUTO_INCREMENT |
| nome       | VARCHAR(80)   | NOT NULL, UNIQUE |
| categoria  | VARCHAR(30)   | NOT NULL, CHECK IN ('ALIMENTACAO','BEM-ESTAR','TRANSPORTE','LAVANDERIA','LAZER') |
| descricao  | VARCHAR(255)  |            |
| preco      | DECIMAL(10,2) | NOT NULL, CHECK >= 0 |
| ativo      | BOOLEAN       | NOT NULL, DEFAULT TRUE |

---

### hospedagem_servicos (associação N:N)
> tabela do N:N entre hospedagens e servicos, cada linha é um consumo

| Coluna         | Tipo          | Restrições |
|----------------|---------------|------------|
| id_consumo     | INT           | PK, AUTO_INCREMENT |
| id_hospedagem  | INT           | FK → hospedagens, NOT NULL |
| id_servico     | INT           | FK → servicos, NOT NULL |
| id_funcionario | INT           | FK → funcionarios (quem prestou o serviço) |
| data_consumo   | DATETIME      | NOT NULL |
| quantidade     | INT           | NOT NULL, DEFAULT 1, CHECK > 0 |
| preco_unitario | DECIMAL(10,2) | NOT NULL (preço do dia, o catálogo pode mudar) |

> usei id próprio e não PK composta porque o mesmo serviço pode ser usado mais de uma vez na estadia (ex: café em dias diferentes)

---

### feedbacks
> liguei o feedback na hospedagem, e pela reserva dá pra chegar no hóspede e no quarto. Assim só avalia quem ficou mesmo no hotel.

| Coluna           | Tipo     | Restrições |
|------------------|----------|------------|
| id_feedback      | INT      | PK, AUTO_INCREMENT |
| id_hospedagem    | INT      | FK → hospedagens, NOT NULL, UNIQUE (1 avaliação por estadia) |
| data_feedback    | DATETIME | NOT NULL |
| nota_geral       | TINYINT  | NOT NULL, CHECK 1 a 5 |
| nota_limpeza     | TINYINT  | CHECK 1 a 5 |
| nota_atendimento | TINYINT  | CHECK 1 a 5 |
| comentario       | TEXT     |            |

---

## Relacionamentos identificados

```
hospedes      ||--o{ reservas            : "faz"
quartos       ||--o{ reservas            : "recebe"
funcionarios  |o--o{ reservas            : "registra"
reservas      ||--o|  hospedagens        : "gera"
funcionarios  ||--o{ hospedagens         : "atende (check-in)"
hospedagens   ||--o{ pagamentos          : "gera"
hospedagens   ||--o{ hospedagem_servicos : "consome"
servicos      ||--o{ hospedagem_servicos : "é consumido em"
funcionarios  |o--o{ hospedagem_servicos : "presta"
hospedagens   ||--o|  feedbacks          : "recebe"
```

> mudei reservas ||--|| hospedagens para ||--o| porque reserva cancelada ou futura não vira hospedagem.

- serviços -> hospedagens: pela tabela hospedagem_servicos (N:N)
- funcionários -> hospedagens: id_funcionario em hospedagens (quem fez o check-in). Também tem em reservas (quem registrou) e hospedagem_servicos (quem fez o serviço)
- feedbacks: ligados na hospedagem (1 por estadia)

---

## O que ainda precisa ser feito

- [x] Completar as colunas faltantes nas tabelas existentes
- [x] Criar a tabela `servicos` com suas colunas e tipos
- [x] Criar a tabela `feedbacks` com suas colunas e tipos
- [x] Criar a tabela de associação entre `hospedagens` e `servicos`
- [x] Definir FK de `funcionarios` nas tabelas corretas
- [x] Revisar tipos de dados e restrições (`NOT NULL`, `DEFAULT`, `CHECK`, etc.)
- [x] Garantir que todos os relacionamentos estejam representados
