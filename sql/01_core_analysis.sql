-- GA4 BigQuery export (schema oficial): events_*
-- Substitua o placeholder abaixo pelo seu dataset real no BigQuery:
-- `PROJECT_ID.analytics_XXXXXXXXX.events_*`
--
-- Exemplo de formato (não use este literal):
-- `my-project.analytics_123456789.events_*`

-- Helpers:
-- Param string:
--   (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'key')
-- Param number:
--   COALESCE(
--     (SELECT ep.value.double_value FROM UNNEST(event_params) ep WHERE ep.key = 'key'),
--     CAST((SELECT ep.value.int_value    FROM UNNEST(event_params) ep WHERE ep.key = 'key') AS FLOAT64),
--     SAFE_CAST((SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'key') AS FLOAT64)
--   )

/* 1) Funil sequencial por usuário: Sessão -> Auth -> Onboarding -> Home */
WITH user_steps AS (
  SELECT
    user_pseudo_id,
    MIN(IF(event_name = 'pz_session_start', TIMESTAMP_MICROS(event_timestamp), NULL)) AS t_session,
    MIN(IF(event_name = 'auth_completed', TIMESTAMP_MICROS(event_timestamp), NULL)) AS t_auth,
    MIN(IF(event_name = 'onboarding_completed', TIMESTAMP_MICROS(event_timestamp), NULL)) AS t_onboarding,
    MIN(IF(event_name = 'home_overview_loaded', TIMESTAMP_MICROS(event_timestamp), NULL)) AS t_home
  FROM `your-project.analytics_123456789.events_*`
  WHERE _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
                          AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
    AND event_name IN ('pz_session_start','auth_completed','onboarding_completed','home_overview_loaded')
  GROUP BY user_pseudo_id
)
SELECT
  COUNTIF(t_session IS NOT NULL) AS users_opened,
  COUNTIF(t_session IS NOT NULL AND t_auth IS NOT NULL AND t_auth > t_session) AS users_authed,
  COUNTIF(t_auth IS NOT NULL AND t_onboarding IS NOT NULL AND t_onboarding > t_auth) AS users_onboarded,
  COUNTIF(t_onboarding IS NOT NULL AND t_home IS NOT NULL AND t_home > t_onboarding) AS users_reached_home,
  ROUND(SAFE_DIVIDE(
    COUNTIF(t_session IS NOT NULL AND t_auth IS NOT NULL AND t_auth > t_session),
    COUNTIF(t_session IS NOT NULL)
  ) * 100, 2) AS conv_open_to_auth_pct,
  ROUND(SAFE_DIVIDE(
    COUNTIF(t_auth IS NOT NULL AND t_onboarding IS NOT NULL AND t_onboarding > t_auth),
    COUNTIF(t_session IS NOT NULL AND t_auth IS NOT NULL AND t_auth > t_session)
  ) * 100, 2) AS conv_auth_to_onboarding_pct
FROM user_steps;

/* 2) Split de Auth (method x flow) */
SELECT
  (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'method') AS method,
  (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'flow') AS flow,
  COUNT(DISTINCT user_pseudo_id) AS unique_users
FROM `your-project.analytics_123456789.events_*`
WHERE event_name = 'auth_completed'
GROUP BY 1,2
ORDER BY unique_users DESC;

/* 3) Coortes: 1 coorte por usuário (primeiro onboarding) e retenção via home_overview_loaded */
WITH cohort_users AS (
  SELECT
    user_pseudo_id,
    MIN(TIMESTAMP_MICROS(event_timestamp)) AS cohort_time
  FROM `your-project.analytics_123456789.events_*`
  WHERE event_name = 'onboarding_completed'
  GROUP BY user_pseudo_id
),
activity AS (
  SELECT
    user_pseudo_id,
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS active_date
  FROM `your-project.analytics_123456789.events_*`
  WHERE event_name = 'home_overview_loaded'
  GROUP BY 1,2
)
SELECT
  DATE_TRUNC(DATE(c.cohort_time), WEEK) AS cohort_week,
  COUNT(DISTINCT c.user_pseudo_id) AS cohort_size,
  COUNT(DISTINCT IF(DATE_DIFF(a.active_date, DATE(c.cohort_time), DAY) BETWEEN 1 AND 7,  c.user_pseudo_id, NULL)) AS users_w1,
  COUNT(DISTINCT IF(DATE_DIFF(a.active_date, DATE(c.cohort_time), DAY) BETWEEN 8 AND 14, c.user_pseudo_id, NULL)) AS users_w2,
  COUNT(DISTINCT IF(DATE_DIFF(a.active_date, DATE(c.cohort_time), DAY) BETWEEN 22 AND 28,c.user_pseudo_id, NULL)) AS users_w4
FROM cohort_users c
LEFT JOIN activity a
  ON a.user_pseudo_id = c.user_pseudo_id
 AND a.active_date >= DATE(c.cohort_time)
GROUP BY 1
ORDER BY 1 DESC;

/* 4) Core loop de partidas: Proposed -> Accepted -> Confirmed (por match_id) */
WITH match_events AS (
  SELECT
    event_name,
    TIMESTAMP_MICROS(event_timestamp) AS event_time,
    (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'match_id') AS match_id,
    (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'sport') AS sport,
    (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'format') AS format
  FROM `your-project.analytics_123456789.events_*`
  WHERE event_name IN ('match_proposed','match_accepted','match_confirmed')
)
SELECT
  sport,
  format,
  COUNT(DISTINCT IF(event_name='match_proposed', match_id, NULL)) AS proposed,
  COUNT(DISTINCT IF(event_name='match_accepted', match_id, NULL)) AS accepted,
  COUNT(DISTINCT IF(event_name='match_confirmed', match_id, NULL)) AS confirmed,
  ROUND(SAFE_DIVIDE(
    COUNT(DISTINCT IF(event_name='match_accepted', match_id, NULL)),
    COUNT(DISTINCT IF(event_name='match_proposed', match_id, NULL))
  ) * 100, 2) AS conv_proposed_to_accepted_pct,
  ROUND(SAFE_DIVIDE(
    COUNT(DISTINCT IF(event_name='match_confirmed', match_id, NULL)),
    COUNT(DISTINCT IF(event_name='match_accepted', match_id, NULL))
  ) * 100, 2) AS conv_accepted_to_confirmed_pct
FROM match_events
GROUP BY 1,2
ORDER BY proposed DESC;

/* 5) Liquidez: time_to_accept_hours (média e mediana) */
SELECT
  (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'sport') AS sport,
  (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'format') AS format,
  COUNT(1) AS total_accepts,
  ROUND(AVG(
    COALESCE(
      (SELECT ep.value.double_value FROM UNNEST(event_params) ep WHERE ep.key = 'time_to_accept_hours'),
      CAST((SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'time_to_accept_hours') AS FLOAT64),
      SAFE_CAST((SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'time_to_accept_hours') AS FLOAT64)
    )
  ), 2) AS avg_time_to_accept_hours,
  APPROX_QUANTILES(
    COALESCE(
      (SELECT ep.value.double_value FROM UNNEST(event_params) ep WHERE ep.key = 'time_to_accept_hours'),
      CAST((SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'time_to_accept_hours') AS FLOAT64),
      SAFE_CAST((SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'time_to_accept_hours') AS FLOAT64)
    ),
    100
  )[OFFSET(50)] AS median_time_to_accept_hours
FROM `your-project.analytics_123456789.events_*`
WHERE event_name = 'match_accepted'
GROUP BY 1,2
ORDER BY total_accepts DESC;

/* 6) Engajamento: highlights viewed -> CTA clicked + CTR de sugestões */
SELECT
  COUNT(1) AS highlights_views
FROM `your-project.analytics_123456789.events_*`
WHERE event_name = 'highlights_card_viewed';

SELECT
  (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'cta') AS cta,
  COUNT(1) AS total_clicks,
  COUNT(DISTINCT user_pseudo_id) AS unique_users
FROM `your-project.analytics_123456789.events_*`
WHERE event_name = 'highlights_cta_clicked'
GROUP BY 1
ORDER BY total_clicks DESC;

SELECT
  (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'id') AS suggestion_id,
  COUNT(1) AS total_clicks,
  COUNT(DISTINCT user_pseudo_id) AS unique_users
FROM `your-project.analytics_123456789.events_*`
WHERE event_name = 'suggestion_clicked'
GROUP BY 1
ORDER BY total_clicks DESC;
