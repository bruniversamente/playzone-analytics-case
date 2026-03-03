# PlayZone — Product Blueprint & Product Analytics (GA4/BigQuery)

Este repositório é um case público que descreve como eu construí e instrumentei o PlayZone, um app de matchmaking para esportes de raquetes. O foco aqui não é “soltar o app inteiro”, e sim documentar arquitetura, governança de eventos e análises em SQL no schema oficial do GA4 exportado para o BigQuery.

Evidência de escopo (contagens auditáveis do repo): docs/repo-metrics.md

## O que tem aqui
- Arquitetura do produto (mobile + backend serverless + banco)
- Tracking plan (eventos core governados no TypeScript)
- Queries SQL no schema do GA4 BigQuery export (funis, coortes, retenção e liquidez de marketplace)
- Snippets sanitizados (pure functions) de motores matemáticos e tracking guardrails
- Checklist de segurança para publicar sem vazar segredos

## Stack (alto nível)
- Mobile: React Native (Expo), TypeScript
- Backend: Next.js API Routes (serverless), TypeScript
- Banco principal: MongoDB (NoSQL)
- Analytics: GA4/Firebase Analytics com export para BigQuery

## Por que isso é relevante para Dados
Em produtos digitais, o dado nasce no código. Aqui eu tratei instrumentação e métrica como parte do design do sistema: eventos com parâmetros governados, métricas derivadas por SQL, e análises que respondem perguntas de produto (ativação, funil, retenção e liquidez de marketplace).

## AI-assisted development (método)
Uso IA como acelerador (boilerplate, variações, refactors), mas mantenho responsabilidade técnica: arquitetura, revisão, refatoração, validação e testes. O objetivo é velocidade com consistência, sem delegar decisões críticas.

## Como navegar
- docs/repo-metrics.md: métricas do repositório e como foram medidas
- docs/product-architecture.md: visão de arquitetura e trade-offs
- docs/analytics-case.md: tracking plan, KPIs e leitura do negócio
- sql/01_core_analysis.sql: funil sequencial, coortes, liquidez e efeito-rede (GA4 BigQuery export)
- snippets/: trechos sanitizados (sem env, chaves, URLs privadas)

## Screenshots
Coloque prints em `dashboards/` e linke aqui (você pode adicionar depois).
- ![Funnel](dashboards/funnel.png)
- ![Cohorts](dashboards/cohorts.png)
- ![Liquidity](dashboards/liquidity.png)