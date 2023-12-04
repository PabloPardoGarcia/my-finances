WITH source AS (

    SELECT * FROM {{ source('sources', 'transactions') }}

)

SELECT
    transaction_id,
    to_date(booking, 'DD.MM.YYYY') AS booking_date,
    to_date(value_date, 'DD.MM.YYYY') AS value_date,
    client_recipient,
    booking_text,
    purpose,
    replace(replace(balance, '.', ''), ',', '.')::decimal AS balance,
    balance_currency,
    replace(replace(amount, '.', ''), ',', '.')::decimal AS amount,
    amount_currency,
    inserted_at
FROM source
