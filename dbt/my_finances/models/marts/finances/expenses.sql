WITH base AS (

    SELECT * FROM {{ ref('transactions') }}

)

SELECT
    transaction_id,
    booking_date,
    value_date,
    client_recipient,
    booking_text,
    purpose,
    abs(amount) as amount,
    amount_currency
FROM base
WHERE amount < 0
