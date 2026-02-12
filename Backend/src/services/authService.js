import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { pool } from '../db/postgres.js';
import { env } from '../config/env.js';

export async function signUp({ email, password, username }) {
  const passwordHash = await bcrypt.hash(password, 12);
  const query = `
    INSERT INTO users (email, username, password_hash)
    VALUES ($1, $2, $3)
    RETURNING id, email, username, role
  `;

  const result = await pool.query(query, [email, username, passwordHash]);
  const user = result.rows[0];
  return issueToken(user);
}

export async function signIn({ email, password }) {
  const query = `SELECT id, email, username, role, password_hash FROM users WHERE email = $1`;
  const result = await pool.query(query, [email]);
  const user = result.rows[0];

  if (!user) {
    throw new Error('Invalid credentials');
  }

  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) {
    throw new Error('Invalid credentials');
  }

  return issueToken(user);
}

function issueToken(user) {
  const payload = {
    sub: user.id,
    email: user.email,
    username: user.username,
    role: user.role
  };

  return {
    accessToken: jwt.sign(payload, env.jwtSecret, { expiresIn: '7d' }),
    user: payload
  };
}
