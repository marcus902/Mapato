# Mapato — Play Store Data Safety Declaration

Use these answers when filling out the **Data safety** section in Google Play Console.

---

## Data collected

| Data type | Collected? | Shared? | Purpose | Required? | Type |
|-----------|-----------|---------|---------|-----------|------|
| SMS / MMS | Yes | No | App functionality (detect transactions) | Optional (user enables in Settings) | Text messages |
| App notifications | Yes | No | App functionality (detect transactions) | Optional (user enables in Settings) | Notifications |
| Financial info (transaction amounts, categories) | Yes | No | App functionality (local storage, AI chat) | Yes | Transaction amounts & categories |

## Data types NOT collected

- Personal info (name, email, phone number, address)
- Location
- Photos / Media / Files
- Contacts
- Device IDs
- Crash logs / Diagnostics
- Analytics / Advertising data

## Data practices

| Practice | Answer |
|----------|--------|
| Is data encrypted in transit? | No (data does not leave the device, except optional AI chat over HTTPS) |
| Is data encrypted at rest? | Yes (SQLite database on device) |
| Can users request data deletion? | Yes (clear app data or uninstall) |
| Is data shared with third parties? | No |
| Is data collected in the background? | Yes (SMS and notification listeners run in background when enabled) |

## AI / ML disclosure

| Question | Answer |
|----------|--------|
| Does the app use AI/ML? | Yes |
| Is AI/ML used to make decisions about users? | No |
| What data is sent to the AI service? | Transaction summaries only (amounts and categories — no raw SMS, no personal data) |
| Which third-party AI service? | Groq (groq.com) |
| Is the AI service used for profiling? | No |

## Permissions declared in the app

| Permission | Purpose |
|------------|---------|
| `READ_SMS` | Read incoming SMS to detect mobile money transactions |
| `RECEIVE_SMS` | Receive SMS broadcasts to detect new transactions |
| `POST_NOTIFICATIONS` | Show transaction detection notifications |
| `FOREGROUND_SERVICE` | Keep SMS listener running in background |
| `FOREGROUND_SERVICE_DATA_SYNC` | Background data sync type for SMS service |
| `INTERNET` | AI chat feature (Groq API) |
| `BIND_NOTIFICATION_LISTENER_SERVICE` | Read notifications from M-Pesa / bank apps |
