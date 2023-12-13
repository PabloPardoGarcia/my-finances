CREATE SCHEMA sources;
CREATE TABLE sources.transactions(
    id INTEGER PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
    booking TEXT,
    value_date TEXT,
    client_recipient TEXT,
    booking_text TEXT,
    purpose TEXT,
    balance TEXT,
    balance_currency TEXT,
    amount TEXT,
    amount_currency TEXT,
    inserted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE sources.categories(
    id INTEGER PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
    name TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

COPY sources.categories (name)
FROM '/docker-entrypoint-initdb.d/categories.csv'
DELIMITER ','
CSV
HEADER;

CREATE TABLE sources.transaction_categories(
    id INTEGER PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
    transaction_id INTEGER,
    category_id INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_transaction
        FOREIGN KEY (id)
            REFERENCES sources.transactions(id),
    CONSTRAINT fk_category
        FOREIGN KEY (id)
            REFERENCES sources.categories(id)
);