CREATE SCHEMA sources;
CREATE TABLE sources.transactions(
    transaction_id INTEGER PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
    booking TEXT,
    value_date TEXT,
    client_recipient TEXT,
    booking_text TEXT,
    purpose TEXT,
    balance TEXT,
    balance_currency TEXT,
    amount TEXT,
    amount_currency TEXT
);

COPY sources.transactions (
        booking, value_date, client_recipient, booking_text, purpose,
        balance, balance_currency, amount, amount_currency
    )
FROM PROGRAM 'tail -n +15 /docker-entrypoint-initdb.d/dataset.csv'
DELIMITER ';'
CSV;

CREATE TABLE sources.categories(
    category_id INTEGER PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
    name TEXT,
    created_at TIMESTAMP
);

CREATE TABLE sources.transaction_categories(
    transaction_id INTEGER,
    category_id INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_transaction
        FOREIGN KEY (transaction_id)
            REFERENCES sources.transactions(transaction_id),
    CONSTRAINT fk_category
        FOREIGN KEY (category_id)
            REFERENCES sources.categories(category_id)
);