WITH source AS (
    SELECT *
    FROM {{ source('jobs', 'raw_job_postings') }}
    where error is not TRUE
    and job_id is not null
),
cleaned AS (
SELECT
    job_id,
    job_title,
    company_name,
    job_location,
    REGEXP_REPLACE(job_via, '^via ', '') AS source_platform,
    job_posted_at,
    job_salary as salary,
    job_schedule_type,
    job_work_from_home,
    job_extensions_raw,
    search_time,
    search_date,
    search_term,
    search_location
FROM source
)
Select * from cleaned
