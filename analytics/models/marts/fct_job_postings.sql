WITH source as (
Select
 *
from {{ ref('stg_job_postings') }}
),
job_postings as (
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
    FROM source
Qualify
    row_number() over (partition by job_id order by search_time desc) = 1
)
Select * from job_postings