import { LiveTicker } from '../components/LiveTicker';
import { fetchLiveMatches } from '../lib/api';

export const metadata = {
  title: 'SportsHub Live',
  description: 'Realtime sports scores, trends, and league filters'
};

export default async function HomePage() {
  const demoToken = process.env.DEMO_JWT ?? '';
  const initialMatches = demoToken ? await fetchLiveMatches(demoToken) : [];

  return (
    <main>
      <header className="hero">
        <input placeholder="Search team or player" />
        <nav>
          <button>Football</button>
          <button>Basketball</button>
          <button>Tennis</button>
        </nav>
      </header>

      <section>
        <h1>Live / Hot Matches</h1>
        <LiveTicker initialMatches={initialMatches} token={demoToken} />
      </section>
    </main>
  );
}
