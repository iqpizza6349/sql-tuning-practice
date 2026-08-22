-- 현재 정보 조회
SELECT
    c.company_name
,   d.department_name
,   e.employee_no
,   e.employee_name
,   e.hire_date
,   s.base_salary
,   s.bonus
,   (s.base_salary + s.bonus) AS total_salary
FROM employee   e
    ,department d
    ,company    c
    ,salary     s
WHERE e.employee_key    = :employee_key /* 82699 */
  AND d.department_key  = e.department_key
  AND c.company_key     = d.company_key
  AND (CASE WHEN s.end_date IS NULL THEN s.employee_key END) = e.employee_key
;

/*******************************************************************************
Plan hash value: 1561040892

----------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                   |     1 |   105 |     7   (0)| 00:00:01 |
|   1 |  NESTED LOOPS                  |                   |     1 |   105 |     7   (0)| 00:00:01 |
|   2 |   NESTED LOOPS                 |                   |     1 |    88 |     6   (0)| 00:00:01 |
|   3 |    NESTED LOOPS                |                   |     1 |    61 |     5   (0)| 00:00:01 |
|   4 |     TABLE ACCESS BY INDEX ROWID| SALARY            |     1 |    11 |     3   (0)| 00:00:01 |
|*  5 |      INDEX UNIQUE SCAN         | SALARY_CURRENT_UK |     1 |       |     2   (0)| 00:00:01 |
|   6 |     TABLE ACCESS BY INDEX ROWID| EMPLOYEE          |     1 |    50 |     2   (0)| 00:00:01 |
|*  7 |      INDEX UNIQUE SCAN         | EMPLOYEE_PK       |     1 |       |     1   (0)| 00:00:01 |
|   8 |    TABLE ACCESS BY INDEX ROWID | DEPARTMENT        |     1 |    27 |     1   (0)| 00:00:01 |
|*  9 |     INDEX UNIQUE SCAN          | DEPARTMENT_PK     |     1 |       |     0   (0)| 00:00:01 |
|  10 |   TABLE ACCESS BY INDEX ROWID  | COMPANY           |     1 |    17 |     1   (0)| 00:00:01 |
|* 11 |    INDEX UNIQUE SCAN           | COMPANY_PK        |     1 |       |     0   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - access(CASE  WHEN "END_DATE" IS NULL THEN "EMPLOYEE_KEY" END
              =TO_NUMBER(:EMPLOYEE_KEY))
   7 - access("E"."EMPLOYEE_KEY"=TO_NUMBER(:EMPLOYEE_KEY))
   9 - access("D"."DEPARTMENT_KEY"="E"."DEPARTMENT_KEY")
  11 - access("C"."COMPANY_KEY"="D"."COMPANY_KEY")
*******************************************************************************/

-- 급여 이력 목록
SELECT
    s.start_date
,   s.end_date
,   s.base_salary
,   s.bonus
FROM salary s
WHERE s.employee_key    = :employee_key /* 82699 */
ORDER BY s.start_date DESC
;

/*******************************************************************************
Plan hash value: 974003791

------------------------------------------------------------------------------------------
| Id  | Operation                    | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |     3 |    84 |     6   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID | SALARY    |     3 |    84 |     6   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN DESCENDING| SALARY_UK |     3 |       |     3   (0)| 00:00:01 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("S"."EMPLOYEE_KEY"=TO_NUMBER(:EMPLOYEE_KEY))
*******************************************************************************/
