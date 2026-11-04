WITH job_postings AS (
    SELECT *
    FROM {{ ref('fct_job_postings') }}
)
SELECT
    company_name,
    count(*) as total_job_postings,
    AVG(CASE 
        WHEN currency = 'USD' AND salary_period = 'year' 
        THEN salary_min 
        END) AS avg_salary_min_usd_per_year,
    AVG(CASE 
        WHEN currency = 'USD' AND salary_period = 'year' 
        THEN salary_max 
        END) AS avg_salary_max_usd_per_year
FROM job_postings
GROUP BY company_name