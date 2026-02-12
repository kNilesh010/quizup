-- PostgreSQL schema for SportsHub (high-concurrency live scores platform)

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(140) NOT NULL UNIQUE,
    username VARCHAR(60) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token_hash TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL
);

CREATE TABLE leagues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sport_id UUID NOT NULL REFERENCES sports(id) ON DELETE CASCADE,
    external_league_id VARCHAR(60),
    name VARCHAR(120) NOT NULL,
    country VARCHAR(80),
    UNIQUE (sport_id, name)
);

CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    league_id UUID REFERENCES leagues(id) ON DELETE SET NULL,
    external_team_id VARCHAR(60),
    name VARCHAR(120) NOT NULL,
    short_name VARCHAR(40),
    logo_url TEXT
);

CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    external_match_id VARCHAR(80) NOT NULL UNIQUE,
    sport_id UUID NOT NULL REFERENCES sports(id) ON DELETE CASCADE,
    league_id UUID REFERENCES leagues(id) ON DELETE SET NULL,
    home_team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    away_team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    status VARCHAR(30) NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    home_score SMALLINT,
    away_score SMALLINT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE match_events (
    id BIGSERIAL PRIMARY KEY,
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    minute SMALLINT,
    event_type VARCHAR(40) NOT NULL,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    player_name VARCHAR(100),
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_follows (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
    league_id UUID REFERENCES leagues(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK ((team_id IS NOT NULL) OR (league_id IS NOT NULL)),
    PRIMARY KEY (user_id, team_id, league_id)
);

CREATE INDEX idx_matches_live_lookup ON matches(status, sport_id, league_id, updated_at DESC);
CREATE INDEX idx_match_events_match ON match_events(match_id, created_at DESC);
CREATE INDEX idx_user_sessions_user ON user_sessions(user_id);
