{{ config(severity='WARN') }}
-- test for salaries that are too high, which may indicate a data quality issue. (> 1 million USD per year)
Select 
    job_id, 
    search_term, 
    job_title,
    salary_range, 
    salary_max, 
    salary_min, 
    salary_period,
    currency
from dev.staging.stg_job_postings
where salary_period = 'year'
and currency = 'USD'
and coalesce(salary_max, salary_min) >= 1000000