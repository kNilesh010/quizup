const API_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000';

export async function fetchLiveMatches(token, query = '') {
  const response = await fetch(`${API_URL}/api/v1/matches/live${query}`, {
    headers: {
      Authorization: `Bearer ${token}`
    },
    next: { revalidate: 10 }
  });

  if (!response.ok) {
    throw new Error('Failed to load matches');
  }

  const payload = await response.json();
  return payload.matches;
}
