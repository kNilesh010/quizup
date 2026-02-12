import pg from 'pg';
import { env } from '../config/env.js';

const { Pool } = pg;

export const pool = new Pool({
  connectionString: env.pgUrl,
  max: 30,
  idleTimeoutMillis: 20000,
  connectionTimeoutMillis: 5000
});
