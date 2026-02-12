import dotenv from 'dotenv';

dotenv.config();

export const env = {
  nodeEnv: process.env.NODE_ENV ?? 'development',
  port: Number(process.env.PORT ?? 4000),
  jwtSecret: process.env.JWT_SECRET ?? 'local-dev-secret',
  pgUrl: process.env.DATABASE_URL ?? 'postgres://postgres:postgres@localhost:5432/quizup',
  redisUrl: process.env.REDIS_URL ?? 'redis://localhost:6379',
  sportsApiPrimary: process.env.SPORTS_API_PRIMARY ?? 'https://api-football-v1.p.rapidapi.com/v3',
  sportsApiSecondary: process.env.SPORTS_API_SECONDARY ?? 'https://www.thesportsdb.com/api/v1/json/3',
  sportsApiKey: process.env.SPORTS_API_KEY ?? ''
};
