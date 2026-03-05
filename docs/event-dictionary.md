# PlayZone — Event Dictionary

> **Auto-generated** by `scripts/generate-event-dictionary.js` on 2026-03-05.
> Source of truth: `src/services/analytics.ts`.

## Global Default Params

Every event automatically includes:

| Param | Type | Source |
|-------|------|--------|
| `platform` | string | `Platform.OS` (ios / android) |
| `app_version` | string | `expo.version` from app config |
| `environment` | string | development / staging / production |

---

## Events

### `pz_session_start`

App aberto ou retornado ao foreground após ≥30min inativo. Prefixo "pz_" evita colisão com o session_start automático do GA4.

_No custom params (defaults only)._

**Fired in:**

- `src/hooks/useSessionTracker.ts:26`
- `src/hooks/useSessionTracker.ts:42`

---

### `auth_completed`

Login ou cadastro finalizado com sucesso.

| Param | Type |
|-------|------|
| `method` | string |
| `flow` | string |

**Fired in:**

- `src/context/UserContext.tsx:459`
- `src/context/UserContext.tsx:474`
- `src/context/UserContext.tsx:489`

---

### `onboarding_completed`

Onboarding concluído (esporte, nível, foto).

| Param | Type |
|-------|------|
| `sport` | string |
| `level` | string |
| `has_photo` | boolean |
| `secondary_sports_count` | number |

**Fired in:**

- `src/screens/onboarding/OnboardingPreview.tsx:640`

---

### `match_proposed`

Proposta de partida criada e enviada ao adversário.

| Param | Type |
|-------|------|
| `match_id` | string |
| `match_type` | string |
| `format` | string |
| `sport` | string |
| `slots_count` | number |

**Fired in:**

- `src/screens/main/PlayProposeScreen.tsx:1739`

---

### `match_accepted`

Proposta de partida aceita pelo destinatário. time_to_accept_hours = (acceptedAt − match.createdAt) / 3600000, em horas decimais (2 casas). match.createdAt é o timestamp de criação do documento Match (Mongoose timestamps:true), que corresponde ao momento da proposta.

| Param | Type |
|-------|------|
| `match_id` | string |
| `match_type` | string |
| `format` | string |
| `sport` | string |
| `time_to_accept_hours` | number |

**Fired in:**

- `src/screens/main/NotificationsScreen.tsx:339`
- `src/screens/main/PropostaRecebidaExpandir.tsx:273`

---

### `match_confirmed`

Resultado da partida registrado e confirmado.

| Param | Type |
|-------|------|
| `match_id` | string |
| `match_type` | string |
| `format` | string |
| `sport` | string |

**Fired in:**

- `src/screens/main/RegisterMatchScreen.tsx:529`

---

### `home_overview_loaded`

Dados do overview da home carregados com sucesso.

| Param | Type |
|-------|------|
| `source` | string |
| `sport` | string |
| `stage` | number |
| `urgency` | string |
| `retentionPhase` | string |
| `feedStrength` | string |
| `hasMission` | boolean |

**Fired in:**

- `src/screens/main/HomeScreen.tsx:1033`

---

### `suggestion_clicked`

Usuário clicou em uma sugestão na home.

| Param | Type |
|-------|------|
| `id` | string |

**Fired in:**

- `src/screens/main/HomeScreen.tsx:2000`
- `src/screens/main/HomeScreen.tsx:2006`
- `src/screens/main/HomeScreen.tsx:2103`

---

### `follow_suggestion_followed`

Usuário seguiu um atleta sugerido.

| Param | Type |
|-------|------|
| `userId` | string |

**Fired in:**

- `src/screens/main/HomeScreen.tsx:1397`

---

### `retention_phase_exposed`

Perfil de retenção exposto ao usuário na home.

| Param | Type |
|-------|------|
| `phase` | string |
| `stage` | number |
| `feedStrength` | string |
| `urgency` | string |

**Fired in:**

- `src/screens/main/HomeScreen.tsx:1059`

---

### `highlights_card_viewed`

Card de destaques semanais exibido na home.

| Param | Type |
|-------|------|
| `scope` | string |
| `hasTop` | boolean |
| `topCount` | number |
| `isFallback` | boolean |

**Fired in:**

- `src/screens/main/HomeScreen.tsx:1074`

---

### `highlights_cta_clicked`

Usuário clicou em CTA do card de destaques.

| Param | Type |
|-------|------|
| `cta` | string |
| `contentId` | string |

**Fired in:**

- `src/screens/main/HomeScreen.tsx:1999`
- `src/screens/main/HomeScreen.tsx:2005`

---

## Notes

- **Analytics flag:** Controlled by `APP_VARIANT` (dev=off/log-only, staging/prod=on).
- **Type validation:** Each param is coerced to its declared type; invalid values are dropped (with dev-only warnings).
- **Filtering:** `filterParams()` ensures only declared params reach GA4 — extra params are silently discarded.
