-- Widen every user-editable numeric subscription filter from INTEGER (int4,
-- max ~2.1 billion) to BIGINT (int8, max ~9.2*10^18), so filters like price
-- or score can hold values up to 10^18 without failing the insert. Only the
-- filter columns are widened here — flats_history keeps its INTEGER columns,
-- since real listing data is bounded and Postgres compares int4/int8 fine.
ALTER TABLE user_subscriptions
    ALTER COLUMN min_price TYPE BIGINT,
    ALTER COLUMN max_price TYPE BIGINT,
    ALTER COLUMN min_score TYPE BIGINT,
    ALTER COLUMN min_underground_place TYPE BIGINT,
    ALTER COLUMN min_floor TYPE BIGINT,
    ALTER COLUMN max_floor TYPE BIGINT,
    ALTER COLUMN rooms TYPE BIGINT[] USING rooms::BIGINT[];

ALTER TABLE report_user_subscriptions
    ALTER COLUMN min_price TYPE BIGINT,
    ALTER COLUMN max_price TYPE BIGINT,
    ALTER COLUMN min_score TYPE BIGINT,
    ALTER COLUMN min_underground_place TYPE BIGINT,
    ALTER COLUMN min_floor TYPE BIGINT,
    ALTER COLUMN max_floor TYPE BIGINT,
    ALTER COLUMN rooms TYPE BIGINT[] USING rooms::BIGINT[];
