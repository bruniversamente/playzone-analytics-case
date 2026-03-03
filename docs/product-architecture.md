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