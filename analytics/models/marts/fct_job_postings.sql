Select
    job_id,
    job_title,
    company_name,
    search_term,
    job_location,
    source_platform,
    job_posted_at,
    currency,
    salary_period,
    salary_min,
    salary_max,
    job_schedule_type,
    job_work_from_home
from {{ ref('stg_job_postings') }}