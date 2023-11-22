WITH transactions AS (
    SELECT * FROM {{ ref('base_transactions') }}
),

categories AS (
    SELECT * FROM {{ ref('base_categories') }}
),

transaction_categories AS (
    SELECT * FROM {{ ref('base_transaction_categories') }}
),

joined AS (

    SELECT
        t.transaction_id,
        t.booking_date,
        t.value_date,
        t.client_recipient,
        t.booking_text,
        t.purpose,
        t.balance,
        t.balance_currency,
        t.amount,
        t.amount_currency,
        c.category_name,
        tc.created_at AS category_created_at,
        tc.updated_at AS category_updated_at,
        t.inserted_at
    FROM transactions AS t
    LEFT JOIN transaction_categories AS tc
        ON t.transaction_id = tc.transaction_id
    LEFT JOIN categories AS c
        ON tc.category_id = c.category_id

)

SELECT * FROM joined
