import express from 'express';
import { authLimiter } from '../middleware/rateLimit.js';
import { signIn, signUp } from '../services/authService.js';

export const authRoutes = express.Router();

authRoutes.post('/signup', authLimiter, async (req, res) => {
  try {
    const payload = await signUp(req.body);
    res.status(201).json(payload);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

authRoutes.post('/signin', authLimiter, async (req, res) => {
  try {
    const payload = await signIn(req.body);
    res.status(200).json(payload);
  } catch (error) {
    res.status(401).json({ error: error.message });
  }
});
