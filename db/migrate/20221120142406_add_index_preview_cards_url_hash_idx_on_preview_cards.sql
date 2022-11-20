CREATE INDEX CONCURRENTLY preview_cards_url_hash_idx ON preview_cards USING hash (url);
