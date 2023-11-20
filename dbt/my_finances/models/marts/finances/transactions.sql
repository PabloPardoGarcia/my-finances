WITH base AS (

    SELECT * FROM {{ ref('base_transactions') }}

)

SELECT
    transaction_id,
    booking_date,
    value_date,
    client_recipient,
    booking_text,
    purpose,
    balance,
    balance_currency,
    amount,
    amount_currency,
FROM base
