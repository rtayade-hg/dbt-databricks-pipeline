WITH source As (
    SELECT *
    FROM {{ source('jobs', 'raw_job_skills') }}
    where job_id is not null
),
cleaned AS (
    SELECT
        job_id,
        skill_id,
        trim(skill_keyword) as skill_keyword
    FROM source
)
Select * from cleaned