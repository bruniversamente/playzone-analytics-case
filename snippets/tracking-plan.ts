export type EventName =
  | 'onboarding_completed'
  | 'match_proposed'
  | 'match_accepted'
  | 'home_overview_loaded'
  | 'suggestion_clicked'
  | 'follow_suggestion_followed';

export const EVENT_ALLOWED_KEYS: Record<EventName, readonly string[]> = {
  onboarding_completed: ['sport', 'level', 'has_photo'],
  match_proposed: ['match_id', 'sport', 'format', 'match_type'],
  match_accepted: ['match_id', 'sport', 'format', 'time_to_accept_hours'],
  home_overview_loaded: ['entrypoint'],
  suggestion_clicked: ['surface'],
  follow_suggestion_followed: ['surface'],
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