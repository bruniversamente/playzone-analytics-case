# PlayZone — Analytics Case Study (GA4 → BigQuery)

## Premissa
O foco é responder perguntas de produto com eventos exportados para BigQuery (GA4), evitando depender de queries no banco de produção.

## KPIs e perguntas que este case responde
- Ativação: usuários que completam onboarding e propõem uma partida
- Conversão no core loop: onboarding → match_proposed → match_accepted
- Retenção: coortes W1, W2 e W4
- Liquidez (marketplace): tempo até aceite (time-to-accept) com média e mediana
- Efeito rede: conversão de sugestões sociais por usuário único

## Tracking plan (conceito)
- Eventos core com lista de propriedades permitidas (governados no TypeScript)
- Parâmetros padronizados para facilitar UNNEST no BigQuery
- Separação entre eventos automáticos do GA4 e eventos do produto

## Onde ver as queries
- `sql/01_core_analysis.sql`