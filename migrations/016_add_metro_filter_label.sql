-- Human-readable description of the chosen metro location filter (e.g.
-- "Округа: Восточный, Южный" or "Ветки метро: 🔴 Сокольническая (1)"),
-- so subscription summaries and the /cancel selector can show what kind of
-- filter (okrugs/lines/districts/stations) the user picked, not just the
-- resulting station list. Empty when no metro filter is set.
ALTER TABLE user_subscriptions
    ADD COLUMN metro_filter_label TEXT NOT NULL DEFAULT '';

ALTER TABLE report_user_subscriptions
    ADD COLUMN metro_filter_label TEXT NOT NULL DEFAULT '';
