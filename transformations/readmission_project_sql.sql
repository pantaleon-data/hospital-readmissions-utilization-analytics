CREATE DATABASE readmission_db;

CREATE OR REPLACE VIEW vw_readmissions_base AS 
SELECT
	patient_id,
    age,
    -- Standardize sex values --
    CASE
		WHEN lower(sex) IN ('m', 'male')
			THEN 'Male'
        WHEN lower(sex) IN ('f', 'female')
			THEN 'Female'
		ELSE 'Unknown'
	END AS sex,
    insurance,
    diagnosis,

    -- Ensure visit_date is DATE
    DATE(visit_date) AS visit_date,
    
    -- LOS must be numeric 
    CAST(length_of_stay AS UNSIGNED) AS length_of_stay,
    discharge_type,
    
    -- Normalize readmission flag
    CASE
		WHEN readmission_date IS NULL
			THEN 0
		WHEN DATEDIFF(readmission_date, visit_date) BETWEEN 1 AND 30
			THEN 1
        ELSE 0
	END as readmitted_within_30d,
    
    -- Normalize readmission date
    DATE(readmission_date) AS readmission_date,
    
    -- Comorbidity score must be numeric
    CAST(comorbidity_score AS UNSIGNED) AS comorbidity_score
FROM readmissions_dataset;


SELECT
	COUNT(*) AS `rows`,
    COUNT(DISTINCT patient_id) AS distinct_patients,
    MIN(visit_date) AS first_visit,
    MAX(visit_date) AS last_visit
FROM vw_readmissions_base;


select *
from readmissions_dataset;

DESCRIBE vw_readmissions_base;

select readmitted_within_30d, count(*) as row_coun
from vw_readmissions_base
group by readmitted_within_30d;