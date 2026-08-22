SELECT
    e.employee_no
,   e.employee_name
,   s.base_salary + s.bonus AS total_salary
FROM employee e
    ,salary s
WHERE e.status      = 'ACTIVE'
  AND (CASE WHEN s.end_date IS NULL THEN s.employee_key END) = e.employee_key
ORDER BY total_salary, s.base_salary, e.employee_key
;

/*******************************************************************************
PLAN_TABLE_OUTPUT
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Plan hash value: 3070179821

----------------------------------------------------------------------------------------
| Id  | Operation           | Name     | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |          |  4600K|   245M|       |   133K  (1)| 00:00:06 |
|   1 |  SORT ORDER BY      |          |  4600K|   245M|   299M|   133K  (1)| 00:00:06 |
|*  2 |   HASH JOIN         |          |  4600K|   245M|   250M| 71074   (1)| 00:00:03 |
|*  3 |    TABLE ACCESS FULL| EMPLOYEE |  4600K|   197M|       | 25472   (1)| 00:00:01 |
|*  4 |    TABLE ACCESS FULL| SALARY   |  5000K|    52M|       | 27732   (1)| 00:00:02 |
----------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access(CASE  WHEN "END_DATE" IS NULL THEN "EMPLOYEE_KEY" END
              ="E"."EMPLOYEE_KEY")
   3 - filter("E"."STATUS"='ACTIVE')
   4 - filter(CASE  WHEN "END_DATE" IS NULL THEN "EMPLOYEE_KEY" END  IS NOT
              NULL)
*******************************************************************************/

/*
 /*+ ordered full(e) index(s) */ 힌트 정도가 최선이다. 적어도 현재로서는 무슨 수를 쓰더라도
 SORT ORDER BY 연산을 제거할 수 있는 방법은 없다.
 base_salary 와 bonus 가 index 칼럼이라면 가능할 지도 모르겠다.

 다음은 앞선 04-join-aggregate 에서도 언급했던 B-Tree 는 전 칼럼이 NULL 인 경우에는 저장하지 않는다는 특성을 살려서
 현재 행만 담긴 정렬 인덱스를 만들어 볼 수 있다.
 */
CREATE INDEX SALARY_IX_SALARY
    ON SALARY(
        (CASE WHEN end_date IS NULL THEN base_salary + bonus END)
    ,   (CASE WHEN end_date IS NULL THEN base_salary END)
,   (CASE WHEN end_date IS NULL THEN employee_key END)
)
TABLESPACE TSD_SALARY_IDX
;

SELECT /*+ leading(s) index(s SALARY_IX_SALARY) */
    s.*
FROM (
     SELECT /*+ merge */
         CASE WHEN end_date IS NULL THEN base_salary + bonus END AS current_total
     ,   CASE WHEN end_date IS NULL THEN base_salary END AS current_base
     ,   CASE WHEN end_date IS NULL THEN employee_key END AS current_employee
     FROM salary
) s
WHERE s.current_employee IS NOT NULL
  AND EXISTS (SELECT /*+ unnest nl_sj */ 1 FROM employee e
              WHERE e.employee_key = s.current_employee
                AND e.status       = 'ACTIVE'
)
ORDER BY current_total, current_base, current_employee
;

/*******************************************************************************
Plan hash value: 2691398800

-------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                  |  4600K|   263M|    11M  (1)| 00:07:37 |
|   1 |  NESTED LOOPS SEMI           |                  |  4600K|   263M|    11M  (1)| 00:07:37 |
|*  2 |   INDEX FULL SCAN            | SALARY_IX_SALARY |  1666K|       | 17505   (1)| 00:00:01 |
|*  3 |   TABLE ACCESS BY INDEX ROWID| EMPLOYEE         |     1 |    14 |     2   (0)| 00:00:01 |
|*  4 |    INDEX UNIQUE SCAN         | EMPLOYEE_PK      |     1 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(CASE  WHEN "END_DATE" IS NULL THEN "EMPLOYEE_KEY" END  IS NOT NULL)
   3 - filter("E"."STATUS"='ACTIVE')
   4 - access("E"."EMPLOYEE_KEY"=CASE  WHEN ("END_DATE" IS NULL) THEN "EMPLOYEE_KEY" END
              )
*******************************************************************************/

DROP INDEX SALARY_IX_SALARY;

/*
 물론 이러한 인덱스를 생성하므로서 얻는 이점은 적은 수의 행을 빠르게 조회해야하는 OLTP 환경에서는 매우 유리하다.
 하지만, 위와 같이 전체 행 수를 조회해야하는 상황에서는 JOIN 방식이나 접근 방식에 따라 더 차이가 크다.
 */
