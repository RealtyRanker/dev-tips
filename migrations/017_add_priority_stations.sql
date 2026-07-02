-- Stores the priority station names a subscriber named when choosing the
-- "Уточнить приоритетные станции" scoring option (Moscow subscriptions
-- only). Not used for flat matching directly; recorded for reference and to
-- reproduce the one-off top-10 preview shown at subscription creation.
ALTER TABLE user_subscriptions
    ADD COLUMN priority_stations TEXT[] NOT NULL DEFAULT '{}';
