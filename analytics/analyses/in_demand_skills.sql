WITH job_postings AS (
    SELECT
        job_id
    FROM {{ ref('fct_job_postings') }}
    {% if var('job_title', none) %}
    where search_term = '{{ var("job_title") }}'
    {% endif %}
),

bridge as (
    SELECT *
    FROM {{ ref('bridge_job_skills') }}
),

skills as (
    SELECT *
    FROM {{ ref('dim_skills') }}
)

SELECT
    --b.job_id,
    --s.skill_id,
    s.display_name,
    s.category,
    --s.subcategory,
    count(DISTINCT b.job_id) as demand_count,
    ROUND(count(DISTINCT b.job_id) / (SELECT COUNT(DISTINCT job_id) FROM job_postings) * 100,1) as demand_ratio
from bridge b
inner join skills s using (skill_id)   
inner join job_postings j using (job_id)
group by display_name, s.category
order by demand_count desc
