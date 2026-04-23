# Plano de Implementação: Gestão de Lotes de Alta Precisão (FEFO + Rastreabilidade)

Este documento descreve a arquitetura para um sistema profissional de gestão de inventário por lotes, garantindo controle total sobre validades, localizações e rastreabilidade.

---

## 1. Estrutura de Dados (PostgreSQL)

### 1.1. Tabela: `estoque_lote`
Expandida para incluir localização e dados do fabricante.
```sql
CREATE TABLE estoque_lote (
    id_lote SERIAL PRIMARY KEY,
    empresa_id INT NOT NULL REFERENCES empresa(id_empresa),
    produto_id INT NOT NULL REFERENCES produto(id_produto),
    localizacao_id INT REFERENCES estoque_localizacao(id_localizacao), -- Onde o lote está?
    
    -- Identificação
    lote_interno VARCHAR(50) NOT NULL, -- Gerado pelo sistema (ex: L-2024-001)
    lote_fabricante VARCHAR(50),      -- Código na embalagem (para Recall)
    
    -- Quantidades
    quantidade_inicial FLOAT NOT NULL,
    quantidade_atual FLOAT NOT NULL DEFAULT 0,
    
    -- Datas Críticas
    data_fabricacao DATE,
    data_vencimento DATE NOT NULL,
    data_recebimento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Status
    status VARCHAR(20) DEFAULT 'ativo', -- 'ativo', 'bloqueado', 'vencido', 'esgotado'
    observacao TEXT,
    
    -- Auditoria
    usuario_id INT REFERENCES usuario(id_usuario)
);

CREATE INDEX idx_lote_vencimento ON estoque_lote(data_vencimento);
CREATE INDEX idx_lote_produto ON estoque_lote(produto_id);
```

---

## 2. Lógica de Negócio (Backend Go)

### 2.1. Estratégia de Consumo FEFO (Alta Precisão)
Ao realizar uma venda/saída:
1.  O sistema seleciona os lotes com `status = 'ativo'` ordenados por `data_vencimento` (ASC).
2.  **Reserva de Lote**: O sistema abate a quantidade do lote mais antigo.
3.  **Troca de Status**: Se `quantidade_atual` chegar a 0, altera status para `'esgotado'`.
4.  **Bloqueio de Segurança**: Se a data atual for maior que `data_vencimento`, o sistema altera o status para `'vencido'` automaticamente e impede a venda.

### 2.2. Rastreabilidade (Recall)
*   Implementar endpoint `/api/estoque/rastrear-lote/{id_lote}` que retorna todos os clientes que compraram itens daquele lote específico.

---

## 3. Experiência do Usuário (Frontend Flutter)

### 3.1. Painel de Lotes na StockScreen
*   **Visualização de "Casca de Cebola"**: O usuário vê o saldo total do produto. Ao expandir, vê a decomposição por lotes:
    *   *Lote A (Vence em 2 dias): 10 un - Local: Prateleira B1*
    *   *Lote B (Vence em 30 dias): 100 un - Local: Depósito Central*

### 3.2. Alertas de "Risco de Perda"
*   Dashboard com lista de lotes que vencem nos próximos 7, 15 ou 30 dias.
*   Ação rápida: "Gerar Promoção" para queimar o estoque de lotes próximos ao vencimento.

### 3.3. Recebimento de Mercadoria
*   Interface otimizada para entrada rápida de lotes:
    *   Campo para leitura de código de barras do lote (se houver).
    *   Seletor de data de validade com calendário visual.
    *   Definição da localização física no momento da entrada.

---

## 4. Segurança e Auditoria

*   **Log de Lote**: Cada alteração na `quantidade_atual` de um lote deve gerar um registro na tabela `estoque_movimentacao` com o `id_lote` vinculado.
*   **Inventário por Lote**: O processo de inventário agora deve permitir contar cada lote individualmente, não apenas o total do produto.

---

## 5. Benefícios da Alta Precisão
*   **Compliance**: Atende normas da ANVISA e outros órgãos reguladores.
*   **Redução de Prejuízo**: Identificação imediata de produtos vencendo para liquidação.
*   **Eficiência Logística**: O funcionário sabe exatamente em qual prateleira pegar o produto que vence primeiro.
*   **Rastreabilidade**: Segurança jurídica para o dono do negócio em caso de problemas com lotes de fabricantes.
