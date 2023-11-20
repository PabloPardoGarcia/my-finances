CREATE SCHEMA sources;
CREATE TABLE sources.transactions(
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

COPY sources.transactions
FROM PROGRAM 'tail -n +15 /docker-entrypoint-initdb.d/dataset.csv'
DELIMITER ';'
CSV;