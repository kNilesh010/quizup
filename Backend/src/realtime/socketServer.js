import { Server } from 'socket.io';
import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';
import { getLiveScores } from '../services/sportsDataService.js';

export function createSocketServer(httpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin: '*'
    }
  });

  io.use((socket, next) => {
    try {
      const token = socket.handshake.auth?.token;
      if (!token) throw new Error('Missing token');
      socket.data.user = jwt.verify(token, env.jwtSecret);
      next();
    } catch (error) {
      next(error);
    }
  });

  io.on('connection', (socket) => {
    socket.on('subscribe:live', async (filters = {}) => {
      const room = `live:${filters.sport ?? 'football'}`;
      socket.join(room);
      const initialData = await getLiveScores(filters);
      socket.emit('live:update', initialData);
    });
  });

  setInterval(async () => {
    const live = await getLiveScores({ sport: 'football' });
    io.to('live:football').emit('live:update', live);
  }, 10000);

  return io;
}
