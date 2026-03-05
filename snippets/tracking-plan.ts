export type EventName =
  | 'pz_session_start'
  | 'auth_completed'
  | 'onboarding_completed'
  | 'match_proposed'
  | 'match_accepted'
  | 'match_confirmed'
  | 'home_overview_loaded'
  | 'suggestion_clicked'
  | 'follow_suggestion_followed'
  | 'retention_phase_exposed'
  | 'highlights_card_viewed'
  | 'highlights_cta_clicked';

export const EVENT_ALLOWED_KEYS: Record<EventName, readonly string[]> = {
  pz_session_start: [],
  auth_completed: ['method', 'flow'],
  onboarding_completed: ['sport', 'level', 'has_photo', 'secondary_sports_count'],
  match_proposed: ['match_id', 'match_type', 'format', 'sport', 'slots_count'],
  match_accepted: ['match_id', 'match_type', 'format', 'sport', 'time_to_accept_hours'],
  match_confirmed: ['match_id', 'match_type', 'format', 'sport'],
  home_overview_loaded: ['source', 'sport', 'stage', 'urgency', 'retentionPhase', 'feedStrength', 'hasMission'],
  suggestion_clicked: ['id'],
  follow_suggestion_followed: ['userId'],
  retention_phase_exposed: ['phase', 'stage', 'feedStrength', 'urgency'],
  highlights_card_viewed: ['scope', 'hasTop', 'topCount', 'isFallback'],
  highlights_cta_clicked: ['cta', 'contentId'],
};

export function sanitizeEventParams<E extends EventName>(
  event: E,
  params: Record<string, unknown>
) {
  const allowed = new Set(EVENT_ALLOWED_KEYS[event]);
  const safe: Record<string, unknown> = {};

  for (const [k, v] of Object.entries(params)) {
    if (allowed.has(k)) safe[k] = v;
  }

  return safe;
}
