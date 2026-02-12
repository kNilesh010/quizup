'use client';

import { useEffect, useState } from 'react';
import { io } from 'socket.io-client';

const WS_URL = process.env.NEXT_PUBLIC_WS_URL ?? 'http://localhost:4000';

export function LiveTicker({ initialMatches = [], token }) {
  const [matches, setMatches] = useState(initialMatches);

  useEffect(() => {
    const socket = io(WS_URL, { auth: { token } });
    socket.emit('subscribe:live', { sport: 'football' });
    socket.on('live:update', (incoming) => setMatches(incoming));

    return () => socket.close();
  }, [token]);

  return (
    <div className="grid">
      {matches.map((match) => (
        <article key={match.id} className="card">
          <span className="badge">{match.status}</span>
          <h3>{match.homeTeam} vs {match.awayTeam}</h3>
          <p>{match.league} • {match.country}</p>
          <p className="score">{match.homeScore} - {match.awayScore}</p>
        </article>
      ))}
    </div>
  );
}
