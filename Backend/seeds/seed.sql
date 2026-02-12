INSERT INTO sports (key, name)
VALUES
('football', 'Football'),
('basketball', 'Basketball'),
('tennis', 'Tennis');

INSERT INTO leagues (sport_id, external_league_id, name, country)
SELECT s.id, '39', 'Premier League', 'England'
FROM sports s
WHERE s.key = 'football';

-- Add production-grade data through provider sync jobs.
