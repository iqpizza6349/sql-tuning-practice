SELECT
    d.department_key
,   d.department_name
,   COUNT(e.employee_key) AS department_employee_cnt
,   AVG(s.base_salary) AS AVG_BASE_SALARY
FROM department d
    ,employee   e
    ,salary     s
WHERE e.department_key  = d.department_key
  AND e.status          = 'ACTIVE'
  AND (CASE WHEN s.end_date IS NULL THEN s.employee_key END) = e.employee_key
GROUP BY d.department_key, d.department_name
;

/*******************************************************************************
Plan hash value: 1508644032

---------------------------------------------------------------------------------------------
| Id  | Operation              | Name       | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT       |            | 18768 |  1227K|       | 77697   (1)| 00:00:04 |
|   1 |  HASH GROUP BY         |            | 18768 |  1227K|  1416K| 77697   (1)| 00:00:04 |
|*  2 |   HASH JOIN            |            | 18768 |  1227K|       | 77396   (1)| 00:00:04 |
|   3 |    VIEW                | VW_GBC_10  | 18768 |   806K|       | 77125   (1)| 00:00:04 |
|   4 |     HASH GROUP BY      |            | 18768 |   494K|   159M| 77125   (1)| 00:00:04 |
|*  5 |      HASH JOIN         |            |  4600K|   118M|   136M| 64712   (1)| 00:00:03 |
|*  6 |       TABLE ACCESS FULL| EMPLOYEE   |  4600K|    83M|       | 25472   (1)| 00:00:01 |
|*  7 |       TABLE ACCESS FULL| SALARY     |  5000K|    38M|       | 27732   (1)| 00:00:02 |
|   8 |    TABLE ACCESS FULL   | DEPARTMENT |   100K|  2246K|       |   271   (1)| 00:00:01 |
---------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("ITEM_1"="D"."DEPARTMENT_KEY")
   5 - access(CASE  WHEN "END_DATE" IS NULL THEN "EMPLOYEE_KEY" END
              ="E"."EMPLOYEE_KEY")
   6 - filter("E"."STATUS"='ACTIVE')
   7 - filter(CASE  WHEN "END_DATE" IS NULL THEN "EMPLOYEE_KEY" END  IS NOT NULL)
*******************************************************************************/

/*
 다음과 같이 미리 Count 와 평균 임금을 계산하고 Join 을 하는 방법도 있다.
 */
SELECT
    d.department_key
,   d.department_name
,   x.department_employee_cnt
,   x.avg_base_salary
FROM department d
   ,(SELECT e.department_key
          ,      COUNT(*) AS department_employee_cnt
          ,      AVG(s.base_salary) AS avg_base_salary
     FROM employee e
         ,salary   s
     WHERE e.status = 'ACTIVE'
       AND s.employee_key (+)= e.employee_key
       AND s.end_date (+) IS NULL
     GROUP BY e.department_key
) x
WHERE d.department_key = x.department_key
;

/*******************************************************************************
Plan hash value: 1266269856

--------------------------------------------------------------------------------------------
| Id  | Operation             | Name       | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |            | 18768 |   989K|       | 87403   (1)| 00:00:04 |
|*  1 |  HASH JOIN            |            | 18768 |   989K|       | 87403   (1)| 00:00:04 |
|   2 |   VIEW                |            | 18768 |   568K|       | 87132   (1)| 00:00:04 |
|   3 |    HASH GROUP BY      |            | 18768 |   659K|   278M| 87132   (1)| 00:00:04 |
|*  4 |     HASH JOIN OUTER   |            |  6065K|   208M|   136M| 66745   (1)| 00:00:03 |
|*  5 |      TABLE ACCESS FULL| EMPLOYEE   |  4600K|    83M|       | 25472   (1)| 00:00:01 |
|*  6 |      TABLE ACCESS FULL| SALARY     |  5000K|    81M|       | 27636   (1)| 00:00:02 |
|   7 |   TABLE ACCESS FULL   | DEPARTMENT |   100K|  2246K|       |   271   (1)| 00:00:01 |
--------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("D"."DEPARTMENT_KEY"="X"."DEPARTMENT_KEY")
   4 - access("S"."EMPLOYEE_KEY"(+)="E"."EMPLOYEE_KEY")
   5 - filter("E"."STATUS"='ACTIVE')
   6 - filter("S"."END_DATE"(+) IS NULL)
*******************************************************************************/
