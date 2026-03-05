# Track — BI Analyst (PlayZone)

Este track organiza o case como um dashboard executivo: aquisição/ativação, retenção e saúde do core loop (partidas), com cortes por esporte, formato e contexto da home.

## Páginas sugeridas de dashboard

### Página 1 — Aquisição & Ativação
Cards/gráficos:
- Funil: `pz_session_start` → `auth_completed` → `onboarding_completed` → `home_overview_loaded`
- Split de auth: `auth_completed.method` x `auth_completed.flow`
- Perfil do onboarding: `onboarding_completed.sport`, `onboarding_completed.level`
- Qualidade do onboarding: `onboarding_completed.has_photo` e distribuição `secondary_sports_count`

### Página 2 — Core Loop (Partidas)
Cards/gráficos:
- Funil do core loop: `match_proposed` → `match_accepted` → `match_confirmed` (por `match_id`)
- Liquidez: média/mediana `match_accepted.time_to_accept_hours` por `sport` e `format`
- Distribuição de formatos: `match_proposed.format` (singles/doubles)
- Mix de tipo de partida: `match_* .match_type` (ex.: friendly/ranked/group)

### Página 3 — Engajamento & Retenção
Cards/gráficos:
- Coortes W1/W2/W4: coorte por `onboarding_completed` e retorno via `home_overview_loaded`
- Engajamento de destaque: `highlights_card_viewed` → `highlights_cta_clicked` (CTR por `cta`)
- Sugestões: cliques por `suggestion_clicked.id` e conversão em follow (`follow_suggestion_followed`)
- Sinal de ciclo de vida: `retention_phase_exposed.phase` (distribuição e tendência)

## Checklist de qualidade (BI)
- Preferir usuários únicos para conversão (COUNT DISTINCT user_pseudo_id) quando fizer sentido.
- Para tempo (liquidez), preferir mediana (APPROX_QUANTILES) além da média.
- Filtrar `environment` (excluir development em análises oficiais).
- Padronizar/normalizar texto de `sport`, `level`, `match_type` caso haja variação de casing.

## Onde está a evidência
- Queries de referência: `sql/01_core_analysis.sql`
- Dicionário de eventos/params/call-sites: `docs/event-dictionary.md`
