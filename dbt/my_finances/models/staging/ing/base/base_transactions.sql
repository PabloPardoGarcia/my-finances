WITH source AS (

    SELECT * FROM {{ source('ing', 'transactions') }}

)

SELECT
    to_date(booking, 'DD.MM.YYYY') AS booking_date,
    to_date(value_date, 'DD.MM.YYYY') AS value_date,
    client_recipient,
    booking_text,
    purpose,
    replace(replace(balance, '.', ''), ',', '.')::decimal AS balance,
    balance_currency,
    replace(replace(amount, '.', ''), ',', '.')::decimal AS amount,
    amount_currency
FROM source