{% set extension_keywords = [
    "Health insurance",
    "Dental insurance",
    "Paid time off"
] %}
-- Begin code for the stg_job_postings model
WITH source AS (

    SELECT *
    FROM {{ source('jobs', 'raw_job_postings') }}
    WHERE error IS NOT TRUE
      AND job_id IS NOT NULL

),
-- cleaning and extracting salary information from the job_salary field
salary AS (

    SELECT
        *,

        CASE
            WHEN LOWER(job_salary) LIKE '%year%' THEN 'year'
            WHEN LOWER(job_salary) LIKE '%month%' THEN 'month'
            WHEN LOWER(job_salary) LIKE '%week%' THEN 'week'
            WHEN LOWER(job_salary) LIKE '%day%' THEN 'day'
            WHEN LOWER(job_salary) LIKE '%hour%' THEN 'hour'
        END AS salary_period,

        REGEXP_REPLACE(
            job_salary,
            '(?i)\\s+(a|an)\\s+(year|month|week|day|hour)',
            ''
        ) AS salary_without_period

    FROM source

),
-- cleaning the salary field to extract currency and salary range
salary_cleaned AS (

    SELECT
        *,
        CASE
            WHEN REGEXP_LIKE(salary_without_period, '^[^0-9]+')
                THEN TRIM(REGEXP_SUBSTR(salary_without_period, '^[^0-9]+'))
            ELSE 'USD'
        END AS currency,
        REGEXP_REPLACE(
            salary_without_period,
            '[^0-9Kk.,–-]',
            ''
        ) AS salary_range
    FROM salary
),
-- Parse the job_extensions_raw JSON string into an array of strings (Was used before in the jinja for loop in cleaned_jobs)
parsed as ( 
    SELECT
        *,
        FROM_JSON(job_extensions_raw, 'array<string>') AS job_extensions
    FROM salary_cleaned
),
-- final cleaning and formatting of the job postings data
cleaned AS (
    SELECT
        job_id,
        job_title,
        company_name,
        job_location,
        REGEXP_REPLACE(job_via, '^via ', '') AS source_platform,
        job_posted_at,
        currency,
        salary_period,
        salary_range,
        {{ parse_salary('min') }} AS salary_min,
        {{ parse_salary('max') }} AS salary_max,
        job_schedule_type,
        job_work_from_home,
        search_time,
        search_date,
        search_term,
        search_location,
        -- Check if degree is mentioned
        CASE
            WHEN ARRAY_CONTAINS(job_extensions,'No degree mentioned')
            THEN 'yes'
            ELSE 'no'
        END AS degree_mentioned,
        -- Jinja: Dynamically generate columns with for loop for each extension keyword
        {% for keyword in extension_keywords %}
        ARRAY_CONTAINS(job_extensions,'{{ keyword }}'
        ) AS has_{{ slugify(keyword) }}{% if not loop.last %},{% endif %}
        {% endfor %}
    FROM parsed
)
SELECT *
FROM cleaned