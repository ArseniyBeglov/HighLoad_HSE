CREATE TABLE users (
                       id BIGINT PRIMARY KEY,
                       phone_hash BYTEA,
                       email_hash BYTEA,
                       display_name VARCHAR(128) NOT NULL,
                       avatar_url VARCHAR(512),
                       rating NUMERIC(3,2) NOT NULL DEFAULT 0,
                       reviews_count INTEGER NOT NULL DEFAULT 0,
                       is_verified BOOLEAN NOT NULL DEFAULT FALSE,
                       status VARCHAR(32) NOT NULL,
                       created_at TIMESTAMP NOT NULL,
                       updated_at TIMESTAMP NOT NULL
);

CREATE TABLE categories (
                            id BIGINT PRIMARY KEY,
                            parent_id BIGINT,
                            name VARCHAR(128) NOT NULL,
                            slug VARCHAR(128) NOT NULL,
                            attributes_schema_json JSONB NOT NULL DEFAULT '{}'::jsonb,
                            sort_order INTEGER NOT NULL DEFAULT 0,
                            CONSTRAINT fk_categories_parent
                                FOREIGN KEY (parent_id) REFERENCES categories(id)
);

CREATE TABLE locations (
                           id BIGINT PRIMARY KEY,
                           parent_id BIGINT,
                           name VARCHAR(128) NOT NULL,
                           location_type VARCHAR(32) NOT NULL,
                           lat NUMERIC(9,6),
                           lon NUMERIC(9,6),
                           CONSTRAINT fk_locations_parent
                               FOREIGN KEY (parent_id) REFERENCES locations(id)
);

CREATE TABLE cards (
                       id BIGINT PRIMARY KEY,
                       seller_id BIGINT NOT NULL,
                       category_id BIGINT NOT NULL,
                       location_id BIGINT NOT NULL,
                       title VARCHAR(256) NOT NULL,
                       description TEXT NOT NULL,
                       price_minor BIGINT NOT NULL,
                       currency_code CHAR(3) NOT NULL,
                       condition_code VARCHAR(32) NOT NULL,
                       status VARCHAR(32) NOT NULL,
                       cover_image_url VARCHAR(512),
                       image_urls_json JSONB NOT NULL DEFAULT '[]'::jsonb,
                       attributes_json JSONB NOT NULL DEFAULT '{}'::jsonb,
                       published_at TIMESTAMP,
                       created_at TIMESTAMP NOT NULL,
                       updated_at TIMESTAMP NOT NULL,
                       CONSTRAINT fk_cards_seller
                           FOREIGN KEY (seller_id) REFERENCES users(id),
                       CONSTRAINT fk_cards_category
                           FOREIGN KEY (category_id) REFERENCES categories(id),
                       CONSTRAINT fk_cards_location
                           FOREIGN KEY (location_id) REFERENCES locations(id)
);

CREATE TABLE storage (
                         id BIGINT PRIMARY KEY,
                         owner_user_id BIGINT NOT NULL,
                         card_id BIGINT,
                         file_kind VARCHAR(32) NOT NULL,
                         storage_key VARCHAR(512) NOT NULL,
                         file_url VARCHAR(512) NOT NULL,
                         mime_type VARCHAR(128) NOT NULL,
                         size_bytes BIGINT NOT NULL,
                         thumbnail_url VARCHAR(512),
                         thumbnail_size_bytes BIGINT,
                         created_at TIMESTAMP NOT NULL,
                         CONSTRAINT fk_storage_owner
                             FOREIGN KEY (owner_user_id) REFERENCES users(id),
                         CONSTRAINT fk_storage_card
                             FOREIGN KEY (card_id) REFERENCES cards(id)
);

CREATE TABLE favorites (
                           user_id BIGINT NOT NULL,
                           card_id BIGINT NOT NULL,
                           created_at TIMESTAMP NOT NULL,
                           PRIMARY KEY (user_id, card_id),
                           CONSTRAINT fk_favorites_user
                               FOREIGN KEY (user_id) REFERENCES users(id),
                           CONSTRAINT fk_favorites_card
                               FOREIGN KEY (card_id) REFERENCES cards(id)
);

CREATE TABLE complaints (
                            id BIGINT PRIMARY KEY,
                            reporter_user_id BIGINT NOT NULL,
                            target_user_id BIGINT,
                            target_card_id BIGINT,
                            reason_code VARCHAR(64) NOT NULL,
                            status VARCHAR(32) NOT NULL,
                            priority SMALLINT NOT NULL DEFAULT 0,
                            moderator_user_id BIGINT,
                            description TEXT,
                            created_at TIMESTAMP NOT NULL,
                            resolved_at TIMESTAMP,
                            CONSTRAINT fk_complaints_reporter
                                FOREIGN KEY (reporter_user_id) REFERENCES users(id),
                            CONSTRAINT fk_complaints_target_user
                                FOREIGN KEY (target_user_id) REFERENCES users(id),
                            CONSTRAINT fk_complaints_target_card
                                FOREIGN KEY (target_card_id) REFERENCES cards(id),
                            CONSTRAINT fk_complaints_moderator
                                FOREIGN KEY (moderator_user_id) REFERENCES users(id)
);

CREATE TABLE event_log (
                           id BIGINT PRIMARY KEY,
                           user_id BIGINT NOT NULL,
                           card_id BIGINT,
                           category_id BIGINT,
                           location_id BIGINT,
                           action_type VARCHAR(64) NOT NULL,
                           payload_json JSONB NOT NULL DEFAULT '{}'::jsonb,
                           created_at TIMESTAMP NOT NULL,
                           CONSTRAINT fk_event_log_user
                               FOREIGN KEY (user_id) REFERENCES users(id),
                           CONSTRAINT fk_event_log_card
                               FOREIGN KEY (card_id) REFERENCES cards(id),
                           CONSTRAINT fk_event_log_category
                               FOREIGN KEY (category_id) REFERENCES categories(id),
                           CONSTRAINT fk_event_log_location
                               FOREIGN KEY (location_id) REFERENCES locations(id)
);

CREATE TABLE card_search (
                             card_id BIGINT PRIMARY KEY,
                             seller_id BIGINT NOT NULL,
                             category_id BIGINT NOT NULL,
                             location_id BIGINT NOT NULL,
                             title VARCHAR(256) NOT NULL,
                             price_minor BIGINT NOT NULL,
                             status VARCHAR(32) NOT NULL,
                             attributes_json JSONB NOT NULL DEFAULT '{}'::jsonb,
                             ranking_features_json JSONB NOT NULL DEFAULT '{}'::jsonb,
                             updated_at TIMESTAMP NOT NULL,
                             CONSTRAINT fk_card_search_card
                                 FOREIGN KEY (card_id) REFERENCES cards(id),
                             CONSTRAINT fk_card_search_seller
                                 FOREIGN KEY (seller_id) REFERENCES users(id),
                             CONSTRAINT fk_card_search_category
                                 FOREIGN KEY (category_id) REFERENCES categories(id),
                             CONSTRAINT fk_card_search_location
                                 FOREIGN KEY (location_id) REFERENCES locations(id)
);

CREATE TABLE search_result_cache (
                                     cache_key VARCHAR(256) PRIMARY KEY,
                                     user_id BIGINT,
                                     category_id BIGINT,
                                     location_id BIGINT,
                                     query_text VARCHAR(512) NOT NULL,
                                     filters_json JSONB NOT NULL DEFAULT '{}'::jsonb,
                                     result_card_ids_json JSONB NOT NULL DEFAULT '[]'::jsonb,
                                     ttl_expires_at TIMESTAMP NOT NULL,
                                     created_at TIMESTAMP NOT NULL,
                                     CONSTRAINT fk_search_result_cache_user
                                         FOREIGN KEY (user_id) REFERENCES users(id),
                                     CONSTRAINT fk_search_result_cache_category
                                         FOREIGN KEY (category_id) REFERENCES categories(id),
                                     CONSTRAINT fk_search_result_cache_location
                                         FOREIGN KEY (location_id) REFERENCES locations(id)
);

CREATE TABLE card_cache (
                            cache_key VARCHAR(256) PRIMARY KEY,
                            card_id BIGINT NOT NULL,
                            payload_json JSONB NOT NULL,
                            ttl_expires_at TIMESTAMP NOT NULL,
                            created_at TIMESTAMP NOT NULL,
                            CONSTRAINT fk_card_cache_card
                                FOREIGN KEY (card_id) REFERENCES cards(id)
);


