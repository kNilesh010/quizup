# SportsHub API Endpoints (Node.js + Redis + WebSockets)

## Authentication
- `POST /api/v1/auth/signup`
- `POST /api/v1/auth/signin`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`

## Matches and live feeds
- `GET /api/v1/matches/live?sport=football&league=<optionalId>`
  - Reads live match cards from Redis cache first.
  - Falls back to primary sports API, then backup API if the primary fails/rate-limits.
- `GET /api/v1/matches/:matchId`
- `GET /api/v1/matches/:matchId/events`

## Discovery
- `GET /api/v1/sports`
- `GET /api/v1/leagues?sport=<key>&country=<optional>`
- `GET /api/v1/search?q=<team_or_player>`

## Personalization
- `POST /api/v1/follows/team/:teamId`
- `POST /api/v1/follows/league/:leagueId`
- `GET /api/v1/follows`

## Realtime WebSocket channels
- `WS /` with JWT in `auth.token`
- Client emits `subscribe:live` with `{ sport, league }`
- Server emits `live:update` every ~10 seconds (configurable)

## Reliability and limits
- Global API limiter: `120 req/min/IP`
- Auth limiter: `20 req/15min/IP`
- Redis cache TTL for live score cards: `15 seconds`
- Fallback order:
  1. Redis cache
  2. Primary provider (e.g., API-Football)
  3. Secondary provider (e.g., TheSportsDB)
