import express from 'express';
import { requireAuth } from '../middleware/auth.js';
import { getLiveScores } from '../services/sportsDataService.js';

export const matchRoutes = express.Router();

matchRoutes.get('/live', requireAuth, async (req, res) => {
  try {
    const { sport, league } = req.query;
    const data = await getLiveScores({ sport, league });
    res.status(200).json({ matches: data });
  } catch (error) {
    res.status(502).json({ error: 'Unable to fetch live scores', detail: error.message });
  }
});
