-- Stores a flat's coordinates (if CIAN reports them), for future use (e.g.
-- distance-based filters/sorting). 0 means "not present in the source page".
ALTER TABLE flats_history
    ADD COLUMN latitude DOUBLE PRECISION NOT NULL DEFAULT 0,
    ADD COLUMN longitude DOUBLE PRECISION NOT NULL DEFAULT 0;
