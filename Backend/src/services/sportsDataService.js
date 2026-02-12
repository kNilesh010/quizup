import axios from 'axios';
import { env } from '../config/env.js';
import { redis } from '../db/redis.js';

const LIVE_SCORE_TTL_SECONDS = 15;

export async function getLiveScores({ sport = 'football', league }) {
  const cacheKey = `live:${sport}:${league ?? 'all'}`;
  const cached = await redis.get(cacheKey);
  if (cached) {
    return JSON.parse(cached);
  }

  const data = await withFallback(async (source) => {
    if (source === 'primary') {
      const response = await axios.get(`${env.sportsApiPrimary}/fixtures`, {
        params: { live: 'all', league },
        headers: env.sportsApiKey ? { 'x-rapidapi-key': env.sportsApiKey } : {}
      });
      return normalizePrimary(response.data);
    }

    const response = await axios.get(`${env.sportsApiSecondary}/livescore.php?s=${sport}`);
    return normalizeSecondary(response.data);
  });

  await redis.set(cacheKey, JSON.stringify(data), 'EX', LIVE_SCORE_TTL_SECONDS);
  return data;
}

async function withFallback(handler) {
  try {
    return await handler('primary');
  } catch {
    return handler('secondary');
  }
}

function normalizePrimary(payload) {
  const rows = payload?.response ?? [];
  return rows.map((match) => ({
    id: String(match.fixture.id),
    sport: 'football',
    league: match.league.name,
    country: match.league.country,
    homeTeam: match.teams.home.name,
    awayTeam: match.teams.away.name,
    homeScore: match.goals.home,
    awayScore: match.goals.away,
    status: match.fixture.status.short,
    startTime: match.fixture.date
  }));
}

function normalizeSecondary(payload) {
  const rows = payload?.events ?? [];
  return rows.map((match) => ({
    id: String(match.idEvent),
    sport: match.strSport,
    league: match.strLeague,
    country: match.strCountry,
    homeTeam: match.strHomeTeam,
    awayTeam: match.strAwayTeam,
    homeScore: Number(match.intHomeScore ?? 0),
    awayScore: Number(match.intAwayScore ?? 0),
    status: match.strStatus ?? 'LIVE',
    startTime: match.strTimestamp
  }));
}
