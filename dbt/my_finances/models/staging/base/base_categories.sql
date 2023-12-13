WITH source AS (

    SELECT * FROM {{ source('sources', 'categories') }}

)

SELECT
    id AS category_id,
    name AS category_name,
    created_at
FROM source
