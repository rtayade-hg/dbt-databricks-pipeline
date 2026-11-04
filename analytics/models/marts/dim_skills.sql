WITH skill_category AS (
    SELECT *
    FROM {{ ref('skill_categories') }}
),

observations AS (
    SELECT *
    FROM {{ ref('int_skill_observations') }}
)
Select 
    skill_id,
    sc.display_name,
    sc.category,
    sc.subcategory,
    COALESCE(ob.postings_with_skill,0)as postings_with_skill
from skill_category sc
left join observations ob using (skill_id)