import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import http from 'http';
import { env } from './config/env.js';
import { redis } from './db/redis.js';
import { apiLimiter } from './middleware/rateLimit.js';
import { createSocketServer } from './realtime/socketServer.js';
import { authRoutes } from './routes/authRoutes.js';
import { matchRoutes } from './routes/matchRoutes.js';

const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use('/api', apiLimiter);

app.get('/health', async (_req, res) => {
  const redisStatus = redis.status;
  res.status(200).json({ ok: true, redisStatus });
});

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/matches', matchRoutes);

const server = http.createServer(app);
createSocketServer(server);

redis.connect().catch(() => {
  process.stdout.write('Redis unavailable; running without warm cache.\n');
});

server.listen(env.port, () => {
  process.stdout.write(`sports backend listening on :${env.port}\n`);
});
