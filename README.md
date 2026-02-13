# QuizUp iOS Clone (SwiftUI + PostgreSQL backend design)

This repository contains a production-style blueprint for an iOS trivia platform inspired by QuizUp. It includes:

- SwiftUI app structure for authentication, topic browsing, game rounds, profile, and leaderboard.
- Domain/service architecture for clean separation (Auth, Question generation, Progress, Leaderboard).
- Database schema and API design for a scalable backend.
- Non-repeating random question logic per user/topic/level.

## Feature Checklist

### 1) Authentication
- Email + password sign up/sign in.
- Sign in with Apple flow abstraction.
- User session token model.

### 2) Trivia gameplay
- Topic picker (Science, Movies seeds).
- Four levels: Beginner, Intermediate, Advanced, Expert.
- 10-question rounds with score tracking.
- Explanation support on each question model.

### 3) Question levels and progression
- Unlock logic based on best historical score:
  - Beginner score >= 50 unlocks Intermediate.
  - Intermediate score >= 60 unlocks Advanced.
  - Advanced score >= 70 unlocks Expert.

### 4) Random question generation without repetition
- `QuestionService.nextQuestion(...)` loads all available questions for `(topic, level)`.
- Fetches `UserQuestionHistory` for the same `(user, topic, level)`.
- Filters out already answered IDs.
- Returns a random unseen question.
- On answer submit, question ID is stored in history so it cannot reappear.

### 5) Leaderboards
- Global leaderboard service.
- Topic leaderboard service.
- Sorted by rating.

### 6) Backend & database
- PostgreSQL schema in `Backend/schema/schema.sql`.
- Core tables: users, topics, questions, user_question_history, rounds.
- API endpoint reference in `Backend/api/endpoints.md`.

## Suggested Production Stack
- iOS App: SwiftUI + async/await + Combine.
- API: Vapor (Swift) or Node/NestJS.
- DB: PostgreSQL.
- Auth: JWT + Sign in with Apple.
- Caching/queues: Redis.
- Realtime matches: WebSockets.

## Non-Repeating Query Pattern (Backend)

```sql
SELECT q.*
FROM questions q
LEFT JOIN user_question_history h
  ON h.question_id = q.id
 AND h.user_id = $1
WHERE q.topic_id = $2
  AND q.level = $3
  AND q.is_active = TRUE
  AND h.question_id IS NULL
ORDER BY RANDOM()
LIMIT 1;
```

If this query returns 0 rows, the user has exhausted the pool for that topic+level.

## Next Steps
1. Create an Xcode project and add files from `QuizUpApp`.
2. Wire `GameRepository` to real API calls.
3. Replace in-memory data with backend responses.
4. Add push notifications, friend system, and chat.
5. Add anti-cheat and telemetry.

## CrashLab dashboard (quant risk monitoring)

A standalone quant dashboard is included at `dashboard/index.html`. It pulls live market data, detects historical crash regimes, and estimates a forward crash probability signal using multi-factor stress features.

### Features
- Real-time Yahoo Finance feed (S&P 500 + VIX), auto-refreshing every 45s.
- Historical crash regime detection with configurable drawdown threshold.
- Forward crash probability signal from:
  - realized volatility
  - drawdown depth
  - trend regime (50d vs 200d average)
  - volatility stress proxy (VIX)
- Parameterized alert thresholds and interactive charting.

### Run locally
```bash
python -m http.server 8000
```

Open: `http://localhost:8000/dashboard/index.html`
