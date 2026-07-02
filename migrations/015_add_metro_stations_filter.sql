-- Location filter by metro station: flats_history records which underground
-- stations a listing is near, and subscriptions store the set of stations a
-- user narrowed their search to (currently populated via the "Округа"
-- location filter in subscription-handler; empty means no filter).
ALTER TABLE flats_history
    ADD COLUMN underground_stations TEXT[] NOT NULL DEFAULT '{}';

ALTER TABLE user_subscriptions
    ADD COLUMN metro_stations TEXT[] NOT NULL DEFAULT '{}';

ALTER TABLE report_user_subscriptions
    ADD COLUMN metro_stations TEXT[] NOT NULL DEFAULT '{}';
