import Redis from 'ioredis';
import { env } from '../config/env.js';

export const redis = new Redis(env.redisUrl, {
  maxRetriesPerRequest: 2,
  enableAutoPipelining: true,
  lazyConnect: true
});
