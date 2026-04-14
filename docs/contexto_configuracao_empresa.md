# Contexto Técnico: Implementação da Tela de Configuração da Empresa

Este documento serve como guia completo para a implementação da funcionalidade de Configuração da Empresa no ERP UnifyTechXenos. Use este arquivo como "prompt principal" para que outra IA ou uma nova janela continue o trabalho com consumo de tokens reduzido.

## 1. Objetivo
Permitir que o Administrador gerencie os dados institucionais, fiscais e de identidade visual da empresa.

## 2. Stack Tecnológica
- **Backend**: Go (Golang) com roteador Chi e driver pgx/v5 para PostgreSQL.
- **Frontend Admin**: Flutter (Desktop) usando Riverpod para gerência de estado.

## 3. Estado Atual e Descobertas
- A tabela `empresa` no PostgreSQL está completa (33 campos).
- O modelo Go (`internal/domain/models/empresa.go`) está desatualizado (faltando campos como `fuso_horario`, `logotipo_url`, `cor_primaria`, `cor_secundaria`).
- O Backend ainda não possui Service ou Handler específicos para a entidade Empresa.
- No Frontend Admin, a navegação de configurações já existe em `settings_screen.dart`, mas precisa do novo link.

## 4. Estrutura de Dados (Campos Essenciais)
Tabela: `empresa`
- **Fiscais**: `razao_social`, `nome_fantasia`, `cnpj`, `inscricao_estadual`, `inscricao_municipal`, `regime_tributario`.
- **Endereço**: `logradouro`, `numero`, `complemento`, `bairro`, `cidade`, `estado`, `cep`.
- **Contato**: `telefone`, `telefone2`, `email`, `site`.
- **Sistema**: `moeda`, `casas_decimais`, `fuso_horario`.
- **Visual**: `logotipo_url`, `cor_primaria`, `cor_secundaria`.

## 5. Roteiro de Implementação

### Fase 1: Backend (Go)
1. **Refatorar Model**: Alinhar `models.Empresa` com as colunas do DB.
2. **Criar Service**: `internal/service/empresa_service.go` com métodos `Buscar` e `Atualizar`.
3. **Criar Handler**: `internal/api/handlers/empresa_handler.go` com endpoints `GET /api/empresa` (puxa pelo ID da empresa do token) e `PUT /api/empresa`.
4. **Registrar Rotas**: Em `internal/api/router.go`, registrar sob proteção de `RequireProfile("admin")`.

### Fase 2: Frontend (Flutter)
1. **Repository**: `lib/data/repositories/empresa_repository.dart`.
2. **Provider**: `lib/presentation/providers/empresa_provider.dart` via `AsyncNotifier`.
3. **Screen**: `lib/presentation/views/settings/company_settings_screen.dart`.
   - Implementar formulário responsivo com seções.
   - Usar máscaras (package `mask_text_input_formatter`).
   - Botão de salvar com feedback de carregamento.

## 6. Padrões de Qualidade
- No Go: Retornar erros detalhados e usar a estrutura `utils.JSON` para respostas.
- No Flutter: Manter o design Material 3 e cores harmoniosas pré-definidas no tema.
