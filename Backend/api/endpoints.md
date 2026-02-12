# API Endpoints

## Authentication
- `POST /v1/auth/signup`
- `POST /v1/auth/signin`
- `POST /v1/auth/apple`

## Gameplay
- `GET /v1/topics`
- `GET /v1/questions/next?topicId=<id>&level=<1-4>`
  - Server query excludes IDs in `user_question_history` to guarantee non-repeating questions per user.
- `POST /v1/rounds/answer`
- `POST /v1/rounds/complete`

## Leaderboard
- `GET /v1/leaderboard/global`
- `GET /v1/leaderboard/topic/<topicId>`

## Matchmaking (optional realtime)
- `POST /v1/matchmaking/enqueue`
- `GET /v1/matchmaking/status/<ticketId>`
- `WS /v1/match/<matchId>/events`
