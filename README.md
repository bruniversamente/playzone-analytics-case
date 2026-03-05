# PlayZone — Product Blueprint & Product Analytics (GA4/BigQuery)

Este repositório é um case público que descreve como eu construí e instrumentei o PlayZone, um app de matchmaking para esportes de raquetes. O foco aqui não é “soltar o app inteiro”, e sim documentar arquitetura, governança de eventos e análises em SQL no schema oficial do GA4 exportado para o BigQuery.

Evidência de escopo (contagens auditáveis do repo): docs/repo-metrics.md

## O que tem aqui
- Arquitetura do produto (mobile + backend serverless + banco)
- Tracking plan governado no TypeScript + dicionário de eventos auto-gerado
- Queries SQL no schema do GA4 BigQuery export (funis, coortes, retenção e core loop de partidas)
- Snippets sanitizados (pure functions) de motores matemáticos e tracking guardrails
- Checklist de segurança para publicar sem vazar segredos
- Trilhas por cargo (Product Analyst, BI Analyst, Growth Analyst): docs/track-*.md

## Stack (alto nível)
- Mobile: React Native (Expo), TypeScript
- Backend: Next.js API Routes (serverless), TypeScript
- Banco principal: MongoDB (NoSQL)
- Analytics: GA4/Firebase Analytics com export para BigQuery

## Por que isso é relevante para Dados
Em produtos digitais, o dado nasce no código. Aqui eu tratei instrumentação e métrica como parte do design do sistema: eventos com parâmetros governados, métricas derivadas por SQL, e análises que respondem perguntas de produto (ativação, funil, retenção e liquidez de marketplace).

## AI-assisted development (método)
Uso IA como acelerador (boilerplate, variações, refactors), mas mantenho responsabilidade técnica: arquitetura, revisão, refatoração, validação e testes. O objetivo é velocidade com consistência, sem delegar decisões críticas.

## Estado do tracking
O tracking está implementado no código com governança (allowlist + coerção de tipos + dicionário auto-gerado).  
A ativação é controlada por variante de ambiente (dev = log-only; staging/prod = envio habilitado), conforme documentado no `docs/event-dictionary.md`.

## Como navegar
- docs/repo-metrics.md: métricas do repositório e como foram medidas
- docs/product-architecture.md: visão de arquitetura e trade-offs
- docs/analytics-case.md: tracking plan, KPIs e leitura do negócio
- docs/event-dictionary.md: eventos, parâmetros, tipos e call-sites (auto-gerado do código)
- sql/01_core_analysis.sql: funil sequencial, coortes, liquidez e efeito-rede (GA4 BigQuery export)
- snippets/: trechos sanitizados (sem env, chaves, URLs privadas)
- docs/track-product-analyst.md: leitura do case para Product Analyst
- docs/track-bi-analyst.md: leitura do case para BI Analyst
- docs/track-growth-analyst.md: leitura do case para Growth Analyst

## Como rodar as queries (BigQuery)
As queries em `sql/01_core_analysis.sql` usam um placeholder de dataset:

`your-project.analytics_123456789.events_*`

Para executar no seu BigQuery, substitua pelo seu endereço real no formato:

`PROJECT_ID.analytics_XXXXXXXXX.events_*`
