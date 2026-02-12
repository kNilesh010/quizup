# SportsHub: Realtime Sports Scores Platform (Next.js + Node.js + Redis + WebSockets)

This repository now includes a production-style architecture for a sports website that aggregates multiple APIs, streams live updates, and supports authenticated users at scale.

## Product concept (layout mapping)

| Reference UX Pattern | SportsHub Equivalent |
|---|---|
| Thumbnail grid | Match cards |
| Duration badge | Match time / live status |
| Category tags | League / sport tags |
| Trending row | Live / hot matches |
| Search bar | Team / player search |
| Sidebar filters | Sport / country filters |

## Stack

### Backend
- Node.js + Express API
- PostgreSQL (core system of record)
- Redis (live-score cache and fast fan-out read path)
- Socket.IO for real-time updates
- JWT authentication
- Rate-limiting + fallback provider strategy

### Frontend
- Next.js App Router + React
- Server Components for SEO and initial render
- Client component hydration for live updates via WebSocket

---

## High-level architecture

1. **Client request** hits Next.js server component page.
2. Next.js fetches initial live matches from Node API for SEO-friendly HTML.
3. Browser hydrates a client component that opens WebSocket (`subscribe:live`).
4. Backend score service resolves from:
   - Redis cache (fast path)
   - Primary API provider
   - Secondary API provider fallback
5. Node pushes updates to subscribed sockets every polling interval.
6. Persisted entities (users, leagues, teams, matches, events) stored in PostgreSQL.

### Concurrency strategy (thousands of users)
- Stateless Node API pods behind L4/L7 load balancer.
- Redis for hot data + pub/sub fan-out between websocket nodes.
- Read-through caching (`15s TTL`) to reduce provider calls.
- Tight rate limits per IP to protect auth and provider quotas.
- DB indexes on live-query and event timelines.
- Horizontal scaling plan:
  - API pods: auto-scale on CPU + request latency.
  - Socket pods: sticky sessions + Redis adapter.
  - Managed PostgreSQL with read replicas.

## Repo structure

- `Backend/src` – Node API, auth, live score service, sockets, middleware.
- `Backend/schema/schema.sql` – PostgreSQL schema for auth + sports data.
- `Backend/api/endpoints.md` – Endpoint and real-time contract.
- `Frontend/src/app` – Next.js server-rendered shell.
- `Frontend/src/components/LiveTicker.jsx` – client-side live hydration.

## Quick start

### Backend
```bash
cd Backend
npm install
npm run dev
```

### Frontend
```bash
cd Frontend
npm install
npm run dev
```

Set environment variables as needed:
- Backend: `PORT`, `DATABASE_URL`, `REDIS_URL`, `JWT_SECRET`, `SPORTS_API_PRIMARY`, `SPORTS_API_SECONDARY`, `SPORTS_API_KEY`
- Frontend: `NEXT_PUBLIC_API_URL`, `NEXT_PUBLIC_WS_URL`, `DEMO_JWT`
