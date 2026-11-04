{% set extension_keywords = [
    "Health insurance",
    "Dental insurance",
    "Paid time off"
] %}

WITH jobs AS (
    SELECT *
    FROM {{ ref('stg_job_postings') }}
),
-- Parse the job_extensions_raw JSON string into an array of strings (Was used before in the jinja for loop in cleaned_jobs)
parsed as ( 
    SELECT
        *,
        FROM_JSON(job_extensions_raw, 'array<string>') AS job_extensions
    FROM jobs
),
cleaned_jobs AS (
    SELECT
        job_id,
        job_title,
        company_name,
        job_location,
        job_work_from_home,
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
FROM cleaned_jobs