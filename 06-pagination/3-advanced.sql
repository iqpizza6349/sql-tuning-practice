CREATE INDEX SALARY_IX_SALARY
ON SALARY(
    (CASE WHEN end_date IS NULL THEN base_salary END)
,   (CASE WHEN end_date IS NULL THEN bonus END)
,   (CASE WHEN end_date IS NULL THEN employee_key END)
)
TABLESPACE TSD_SALARY_IDX
;

SELECT
    CASE WHEN end_date IS NULL THEN base_salary END AS base_salary
,   CASE WHEN end_date IS NULL THEN bonus END AS bonus
,   CASE WHEN end_date IS NULL THEN employee_key END AS employee_key
FROM salary
WHERE (CASE WHEN end_date IS NULL THEN employee_key END) IS NOT NULL
ORDER BY (CASE WHEN end_date IS NULL THEN base_salary END) DESC
        ,(CASE WHEN end_date IS NULL THEN bonus END) DESC
        ,(CASE WHEN end_date IS NULL THEN employee_key END) DESC
OFFSET 2000 ROWS FETCH NEXT 20 ROWS ONLY
;
