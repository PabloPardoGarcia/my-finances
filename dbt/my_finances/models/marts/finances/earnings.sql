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
    amount,
    amount_currency
FROM base
WHERE amount > 0
