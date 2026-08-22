SELECT
    c.company_name
,   d.department_name
,   e.employee_no
,   e.employee_name
,   e.position_code
FROM COMPANY    c
    ,DEPARTMENT d
    ,EMPLOYEE   e
WHERE d.company_key     = c.company_key
  and e.department_key  = d.department_key
;
