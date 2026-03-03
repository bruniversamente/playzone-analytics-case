-- GA4 BigQuery export (schema oficial): events_*
-- Ajuste o dataset:
-- `your-project.analytics_123456789.events_*`

-- 1) Funil sequencial por usuário (Onboarding -> Match Proposed -> Match Accepted)
WITH user_steps AS (
  SELECT
    user_pseudo_id,
    MIN(IF(event_name = 'onboarding_completed', TIMESTAMP_MICROS(event_timestamp), NULL)) AS t_onboarding,
    MIN(IF(event_name = 'match_proposed',        TIMESTAMP_MICROS(event_timestamp), NULL)) AS t_proposed,
    MIN(IF(event_name = 'match_accepted',        TIMESTAMP_MICROS(event_timestamp), NULL)) AS t_accepted
  FROM `your-project.analytics_123456789.events_*`
  WHERE _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
                          AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
    AND event_name IN ('onboarding_completed', 'match_proposed', 'match_accepted')
  GROUP BY user_pseudo_id
)
SELECT
  COUNTIF(t_onboarding IS NOT NULL) AS users_onboarded,
  COUNTIF(t_onboarding IS NOT NULL AND t_proposed IS NOT NULL AND t_proposed > t_onboarding) AS users_proposed,
  COUNTIF(t_onboarding IS NOT NULL AND t_proposed IS NOT NULL AND t_accepted IS NOT NULL
          AND t_proposed > t_onboarding AND t_accepted > t_proposed) AS users_accepted,
  ROUND(SAFE_DIVIDE(
    COUNTIF(t_onboarding IS NOT NULL AND t_proposed IS NOT NULL AND t_proposed > t_onboarding),
    COUNTIF(t_onboarding IS NOT NULL)
  ) * 100, 2) AS conv_onboard_to_propose_pct,
  ROUND(SAFE_DIVIDE(
    COUNTIF(t_onboarding IS NOT NULL AND t_proposed IS NOT NULL AND t_accepted IS NOT NULL
            AND t_proposed > t_onboarding AND t_accepted > t_proposed),
    COUNTIF(t_onboarding IS NOT NULL AND t_proposed IS NOT NULL AND t_proposed > t_onboarding)
  ) * 100, 2) AS conv_propose_to_accept_pct
FROM user_steps;

-- 2) Coortes: 1 coorte por usuário (primeiro onboarding) + retenção por janelas
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
  GROUP BY 1, 2
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

-- 3) Market liquidity (tempo para aceite) com params numéricos robustos
SELECT
  (SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'sport') AS sport,
  COUNT(DISTINCT user_pseudo_id) AS unique_users_accepting,
  ROUND(AVG(
    COALESCE(
      (SELECT ep.value.double_value FROM UNNEST(event_params) ep WHERE ep.key = 'time_to_accept_hours'),
      CAST((SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'time_to_accept_hours') AS FLOAT64),
      SAFE_CAST((SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'time_to_accept_hours') AS FLOAT64)
    )
  ), 2) AS avg_time_hours,
  APPROX_QUANTILES(
    COALESCE(
      (SELECT ep.value.double_value FROM UNNEST(event_params) ep WHERE ep.key = 'time_to_accept_hours'),
      CAST((SELECT ep.value.int_value FROM UNNEST(event_params) ep WHERE ep.key = 'time_to_accept_hours') AS FLOAT64),
      SAFE_CAST((SELECT ep.value.string_value FROM UNNEST(event_params) ep WHERE ep.key = 'time_to_accept_hours') AS FLOAT64)
    ),
    100
  )[OFFSET(50)] AS median_time_hours
FROM `your-project.analytics_123456789.events_*`
WHERE event_name = 'match_accepted'
GROUP BY 1
ORDER BY unique_users_accepting DESC;

-- 4) Efeito rede (conversão por usuários únicos)
SELECT
  COUNT(DISTINCT IF(event_name = 'suggestion_clicked', user_pseudo_id, NULL)) AS unique_users_viewed,
  COUNT(DISTINCT IF(event_name = 'follow_suggestion_followed', user_pseudo_id, NULL)) AS unique_users_followed,
  ROUND(SAFE_DIVIDE(
    COUNT(DISTINCT IF(event_name = 'follow_suggestion_followed', user_pseudo_id, NULL)),
    COUNT(DISTINCT IF(event_name = 'suggestion_clicked', user_pseudo_id, NULL))
  ) * 100, 2) AS unique_conversion_rate_pct
FROM `your-project.analytics_123456789.events_*`
WHERE event_name IN ('suggestion_clicked', 'follow_suggestion_followed');