-- Stores the priority station names a subscriber named when choosing the
-- "Уточнить приоритетные станции" scoring option (Moscow subscriptions
-- only), plus the full priority-boosted station ranking computed once at
-- subscription-creation time: priority_station_names is ordered best-first
-- (index 0 = place 1), priority_station_scores is the parallel array of
-- scores, each already normalized by dividing by the station count (433).
-- Storing the ranking lets flats-analyzer look a flat's station place up
-- directly instead of recomputing the Floyd-Warshall ranking per flat.
ALTER TABLE user_subscriptions
    ADD COLUMN priority_stations TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN priority_station_names TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN priority_station_scores DOUBLE PRECISION[] NOT NULL DEFAULT '{}';
