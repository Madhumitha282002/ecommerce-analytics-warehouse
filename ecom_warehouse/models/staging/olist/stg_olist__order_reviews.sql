with source as (

    select * from {{ source('olist', 'order_reviews') }}

),

ranked as (

    select
        *,
        row_number() over (
            partition by review_id
            order by review_answer_timestamp desc
        ) as row_num

    from source

),

renamed as (

    select
        review_id,
        order_id,
        review_score,
        nullif(trim(review_comment_title), '') as comment_title,
        nullif(trim(review_comment_message), '') as comment_message,
        review_creation_date as review_created_at,
        review_answer_timestamp as review_answered_at,
        length(coalesce(review_comment_message, '')) > 0 as has_written_review,
        _loaded_at

    from ranked
    where row_num = 1

)

select * from renamed
