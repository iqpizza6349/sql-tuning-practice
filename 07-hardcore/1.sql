-- binding 버전
SELECT
    e.*
FROM employee e
WHERE e.company_key     = TO_NUMBER(:company_key)
  AND e.department_key  = TO_NUMBER(:department_key)
  AND e.position_code   = TO_CHAR(:position_code)
  AND e.status          = TO_CHAR(:status)
  AND e.hire_date BETWEEN TO_DATE(:startDate, 'YYYY-MM-DD')
                      AND TO_DATE(:endDate, 'YYYY-MM-DD')
ORDER BY e.employee_key DESC
OFFSET TO_NUMBER(:page_no) * TO_NUMBER(:page_size) ROWS
FETCH NEXT TO_NUMBER(:page_size) ROWS ONLY
;

/*******************************************************************************
Plan hash value: 4067802480

---------------------------------------------------------------------------------------------------------
| Id  | Operation                              | Name           | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                       |                |     1 |    99 |    71   (2)| 00:00:01 |
|*  1 |  VIEW                                  |                |     1 |    99 |    71   (2)| 00:00:01 |
|*  2 |   WINDOW SORT PUSHED RANK              |                |     1 |    77 |    71   (2)| 00:00:01 |
|*  3 |    FILTER                              |                |       |       |            |          |
|*  4 |     TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEE       |     1 |    77 |    70   (0)| 00:00:01 |
|*  5 |      INDEX RANGE SCAN                  | EMPLOYEE_IX_01 |    67 |       |     3   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=TO_NUMBER(GREATEST(TO_CHAR(FLOOR(TO_
              NUMBER(TO_CHAR(TO_NUMBER(:PAGE_NO)*TO_NUMBER(:PAGE_SIZE))))),'0'))+TO_NUMBER(:PAGE_SIZE) AND
              "from$_subquery$_002"."rowlimit_$$_rownumber">TO_NUMBER(:PAGE_NO)*TO_NUMBER(:PAGE_SIZE))
   2 - filter(ROW_NUMBER() OVER ( ORDER BY "E"."EMPLOYEE_KEY" DESC
              )<=TO_NUMBER(GREATEST(TO_CHAR(FLOOR(TO_NUMBER(TO_CHAR(TO_NUMBER(:PAGE_NO)*TO_NUMBER(:PAGE_SIZE)))
              )),'0'))+TO_NUMBER(:PAGE_SIZE))
   3 - filter(TO_DATE(:ENDDATE,'YYYY-MM-DD')>=TO_DATE(:STARTDATE,'YYYY-MM-DD') AND
              TO_NUMBER(:PAGE_NO)*TO_NUMBER(:PAGE_SIZE)<TO_NUMBER(GREATEST(TO_CHAR(FLOOR(TO_NUMBER(TO_CHAR(TO_N
              UMBER(:PAGE_NO)*TO_NUMBER(:PAGE_SIZE))))),'0'))+TO_NUMBER(:PAGE_SIZE))
   4 - filter("E"."POSITION_CODE"=:POSITION_CODE AND "E"."COMPANY_KEY"=TO_NUMBER(:COMPANY_KEY)
              AND "E"."HIRE_DATE">=TO_DATE(:STARTDATE,'YYYY-MM-DD') AND
              "E"."HIRE_DATE"<=TO_DATE(:ENDDATE,'YYYY-MM-DD'))
   5 - access("E"."DEPARTMENT_KEY"=TO_NUMBER(:DEPARTMENT_KEY) AND "E"."STATUS"=:STATUS)
*******************************************************************************/

SELECT
    e.*
FROM employee e
WHERE e.company_key     = 300
  AND e.department_key  = 29998
  AND e.position_code   = 'MANAGER'
  AND e.status          = 'ACTIVE'
  AND e.hire_date BETWEEN TO_DATE('2019-01-01', 'YYYY-MM-DD')
    AND TO_DATE('2020-01-01', 'YYYY-MM-DD')
ORDER BY e.employee_key DESC
OFFSET 0 * 50 ROWS FETCH NEXT 50 ROWS ONLY
;

/*******************************************************************************
Plan hash value: 1529792490

--------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name           | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                |     1 |    99 |    14  (15)| 00:00:01 |
|*  1 |  VIEW                                 |                |     1 |    99 |    14  (15)| 00:00:01 |
|*  2 |   WINDOW SORT PUSHED RANK             |                |     1 |    77 |    14  (15)| 00:00:01 |
|*  3 |    TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEE       |     1 |    77 |    13   (8)| 00:00:01 |
|   4 |     BITMAP CONVERSION TO ROWIDS       |                |       |       |            |          |
|   5 |      BITMAP AND                       |                |       |       |            |          |
|   6 |       BITMAP CONVERSION FROM ROWIDS   |                |       |       |            |          |
|*  7 |        INDEX RANGE SCAN               | EMPLOYEE_IX_01 |   245 |       |     3   (0)| 00:00:01 |
|   8 |       BITMAP CONVERSION FROM ROWIDS   |                |       |       |            |          |
|   9 |        SORT ORDER BY                  |                |       |       |            |          |
|* 10 |         INDEX RANGE SCAN              | EMPLOYEE_UK    |   245 |       |     9   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=50 AND
              "from$_subquery$_002"."rowlimit_$$_rownumber">0)
   2 - filter(ROW_NUMBER() OVER ( ORDER BY "E"."EMPLOYEE_KEY" DESC )<=50)
   3 - filter("E"."HIRE_DATE">=TO_DATE(' 2019-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
              "E"."POSITION_CODE"='MANAGER' AND "E"."HIRE_DATE"<=TO_DATE(' 2020-01-01 00:00:00', 'syyyy-mm-dd
              hh24:mi:ss'))
   7 - access("E"."DEPARTMENT_KEY"=29998 AND "E"."STATUS"='ACTIVE')
  10 - access("E"."COMPANY_KEY"=300)
       filter("E"."COMPANY_KEY"=300)
*******************************************************************************/
