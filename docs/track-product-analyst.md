# Track — Product Analyst (PlayZone)

Este track usa o PlayZone como case de Product Analytics e Product Discovery: instrumentação governada no código, leitura do core loop e diagnóstico de fricção na jornada.

## O que este case demonstra
- Definição de eventos e parâmetros no código (allowlist + coerção de tipos + dicionário auto-gerado).
- Tradução de jornadas do produto em métricas (funil, retenção, engajamento e core loop de partidas).
- Diagnóstico de gargalos e oportunidades a partir de dados comportamentais.

## North Star (sugestão)
Partidas confirmadas por usuário ativo (proxy inicial: `match_confirmed` por usuário), com suporte por retenção (coortes via `home_overview_loaded`).

## Funis principais (eventos reais)
### 1) Ativação inicial
- `pz_session_start` → `auth_completed` → `onboarding_completed` → `home_overview_loaded`

### 2) Core loop (partidas)
- `match_proposed` → `match_accepted` → `match_confirmed`

### 3) Engajamento na Home
- `highlights_card_viewed` → `highlights_cta_clicked`
- `home_overview_loaded` → `suggestion_clicked` → `follow_suggestion_followed`

## Perguntas de produto que dá para responder
- Onde está o maior drop-off no funil de ativação (sessão → auth → onboarding → home)?
- Qual método/fluxo de autenticação converte melhor (`auth_completed.method`, `auth_completed.flow`)?
- Quais características do onboarding correlacionam com engajamento e retorno (`sport`, `level`, `has_photo`, `secondary_sports_count`)?
- O core loop de partidas está saudável (propose→accept→confirm)? Onde cai?
- Qual é o tempo até aceite (liquidez) por esporte/formato (`match_accepted.time_to_accept_hours`)?
- Quais CTAs e sugestões geram mais ações (`highlights_cta_clicked.cta`, `suggestion_clicked.id`)?

## Onde está a evidência
- Dicionário auto-gerado (eventos + params + call-sites): `docs/event-dictionary.md`
- Queries principais: `sql/01_core_analysis.sql`
- Tracking snippet (sanitizado): `snippets/tracking-plan.ts`

## Nota sobre ambiente
Em dev, o tracking pode operar em modo log-only; em staging/prod, envio habilitado. Fonte: `docs/event-dictionary.md`.
