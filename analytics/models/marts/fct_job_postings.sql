{{ config(
    materialized='incremental',
    unique_key='job_id',
    incremental_strategy='merge'
) }}

WITH job_postings as (
Select
 *
from {{ ref('stg_job_postings') }}
)

SELECT
    job_id,
    job_title,
    company_name,
    job_location,
    source_platform,
    job_posted_at,
    currency,
    salary_period,
    salary_min,
    salary_max,
    job_schedule_type,
    job_work_from_home,
    search_time,
    search_date,
    search_term
FROM job_postings

{% if is_incremental() %}
    WHERE search_date > (SELECT MAX(search_date) FROM {{ this }})
{% endif %}

Qualify
    row_number() over (partition by job_id order by search_time desc) = 1