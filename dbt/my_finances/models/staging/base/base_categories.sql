WITH source AS (

    SELECT * FROM {{ source('sources', 'categories') }}

)

SELECT
    category_id,
    name as category_name,
    created_at
FROM source