WITH source AS (

    SELECT * FROM {{ source('sources', 'transaction_categories') }}

)

SELECT
    transaction_id,
    category_id,
    created_at,
    updated_at
FROM source
