with source as (

    select * from {{ source('olist', 'products') }}

),

translation as (

    select * from {{ source('olist', 'product_category_translation') }}

),

renamed as (

    select
        source.product_id,
        source.product_category_name as category_name_pt,
        coalesce(
            translation.product_category_name_english,
            'unknown'
        ) as category_name,
        source.product_name_lenght as product_name_length,
        source.product_description_lenght as product_description_length,
        source.product_photos_qty as product_photo_count,
        source.product_weight_g,
        source.product_length_cm,
        source.product_height_cm,
        source.product_width_cm,
        source.product_length_cm
        * source.product_height_cm
        * source.product_width_cm as product_volume_cm3

    from source
    left join translation
        on source.product_category_name = translation.product_category_name

)

select * from renamed
