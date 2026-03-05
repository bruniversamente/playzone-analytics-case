# Track — Growth Analyst (PlayZone)

Este track foca no loop de crescimento: ativação, retenção e loops sociais, com sinais de liquidez (time-to-accept) como saúde do marketplace.

## AARRR (com o que existe hoje)
- Acquisition: `pz_session_start`
- Activation: `auth_completed` + `onboarding_completed` + primeira `home_overview_loaded`
- Retention: recorrência de `home_overview_loaded` (coortes W1/W2/W4)
- Referral (proxy social): `follow_suggestion_followed` (rede inicial)
- Revenue: não instrumentado neste case

## Alavancas e diagnósticos
- Reduzir fricção de login: analisar `auth_completed.method` x `flow`
- Aumentar completude do onboarding: `has_photo` e `secondary_sports_count`
- Aumentar “first value”: reduzir drop onboarding → home (`home_overview_loaded`)
- Melhorar conteúdo e CTR: `highlights_cta_clicked.cta` e `suggestion_clicked.id`
- Melhorar liquidez: reduzir `match_accepted.time_to_accept_hours` por esporte/formato
- Fortalecer loop social: suggestion → follow (`suggestion_clicked` → `follow_suggestion_followed`)

## Métricas-chave (sem inventar)
- Activation rate: usuários que chegam a `onboarding_completed` / `pz_session_start`
- Home entry rate: `home_overview_loaded` / `onboarding_completed`
- Suggestion CTR: `suggestion_clicked` / `home_overview_loaded`
- Highlights CTR: `highlights_cta_clicked` / `highlights_card_viewed`
- Follow conversion: `follow_suggestion_followed` / `home_overview_loaded`
- Core loop conversion: `match_accepted` / `match_proposed`, `match_confirmed` / `match_accepted`
- Liquidez: mediana de `time_to_accept_hours` em `match_accepted`

## Segmentações disponíveis (do tracking)
- `platform`, `app_version`, `environment` (defaults)
- Onboarding: `sport`, `level`, `has_photo`, `secondary_sports_count`
- Home: `source`, `stage`, `urgency`, `retentionPhase`, `feedStrength`, `hasMission`
- Match: `sport`, `format`, `match_type`, `slots_count`
- Highlights/Suggestions: `cta`, `contentId`, `id`
- Retenção: `phase`, `stage`, `feedStrength`, `urgency`

## Onde está a evidência
- Dicionário de eventos/params/call-sites: `docs/event-dictionary.md`
- Queries: `sql/01_core_analysis.sql`
