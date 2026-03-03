# PlayZone — Repository Metrics & Evidence

Data da extração: 02/03/2026

## Observação sobre evidência pública
Preencha o hash abaixo após o primeiro push deste repositório público.

Public commit hash:
- <PUBLIC_COMMIT_HASH>

## Metodologia (PowerShell)

### 1) Telas na UI (React Native)
```powershell
(Get-ChildItem -Path src\screens -Recurse -File -Include *.tsx,*.ts).Count
2) Componentes reutilizáveis
(Get-ChildItem -Path src\components -Recurse -File -Include *.tsx,*.ts).Count
3) Rotas serverless (Next.js API Routes)
(Get-ChildItem -Path server\app\api -Recurse -File -Include route.ts).Count
4) Eventos do tracking plan

Fonte: src/services/analytics.ts (lista de eventos permitidos e chaves permitidas por evento).

Nota: o GA4 também registra eventos automáticos (ex.: session_start) que não precisam estar “mapeados” no serviço de tracking.


Salva (`Ctrl+S`).

---

## B) Preencher `docs/product-architecture.md` (cole TUDO no arquivo)

1) Abra: `docs/product-architecture.md`  
2) `Ctrl+A` e cole:

```md
# PlayZone — Arquitetura (alto nível)

## Objetivo
Descrever a arquitetura do PlayZone com foco em decisões técnicas e implicações para análise de dados.

## Visão geral
- App mobile (React Native/Expo) consumindo APIs REST
- Backend serverless (Next.js API Routes)
- Banco principal (MongoDB / Mongoose)
- Eventos de produto (GA4/Firebase Analytics) com export para BigQuery

## Fluxo (alto nível)
1. Usuário executa ações no app (onboarding, criação de match, aceite, etc.)
2. App chama APIs serverless para persistência/validação (MongoDB)
3. App registra eventos analíticos (GA4) com parâmetros governados
4. Eventos são exportados para BigQuery
5. SQL calcula funis, coortes, retenção e métricas de marketplace

## Decisões e trade-offs
- Serverless (Next.js API Routes): reduz custo e complexidade de infra no início e mantém tipagem alinhada ao stack TS.
- MongoDB (NoSQL): favorece leituras rápidas de perfis e documentos ricos com flexibilidade de schema.
- Analytics-first: tracking plan governado no código para evitar eventos inconsistentes e facilitar análise posterior.

## Onde olhar neste repositório
- `snippets/tracking-plan.ts`: dicionário de eventos e props permitidas (sanitizado)
- `sql/01_core_analysis.sql`: análises no schema do GA4 export