SELECT
    e.*
FROM company c
    ,employee e
WHERE c.company_key = 20
  AND e.company_key = c.company_key
  AND e.status      = 'ACTIVE'
ORDER BY e.hire_date, e.employee_key
;

/*******************************************************************************
Plan hash value: 1152480864

-------------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name        | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |             | 32500 |  2570K|       | 14797   (1)| 00:00:01 |
|   1 |  SORT ORDER BY                        |             | 32500 |  2570K|  3344K| 14797   (1)| 00:00:01 |
|   2 |   NESTED LOOPS                        |             | 32500 |  2570K|       | 14180   (1)| 00:00:01 |
|*  3 |    INDEX UNIQUE SCAN                  | COMPANY_PK  |     1 |     4 |       |     1   (0)| 00:00:01 |
|*  4 |    TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEE    | 32500 |  2443K|       | 14179   (1)| 00:00:01 |
|*  5 |     INDEX RANGE SCAN                  | EMPLOYEE_UK | 35326 |       |       |   139   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("C"."COMPANY_KEY"=20)
   4 - filter("E"."STATUS"='ACTIVE')
   5 - access("E"."COMPANY_KEY"=20)
*******************************************************************************/

/*
 Employee 에게 company_key 가 있기 때문에 다음과 같은 쿼리로 Company 자체를 스킵할 수도 있다.
 */
SELECT
    e.*
FROM employee e
WHERE e.company_key = 20
  AND e.status      = 'ACTIVE'
ORDER BY e.hire_date, e.employee_key

/*******************************************************************************
Plan hash value: 324371031

------------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name        | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |             | 32500 |  2443K|       | 14765   (1)| 00:00:01 |
|   1 |  SORT ORDER BY                       |             | 32500 |  2443K|  3224K| 14765   (1)| 00:00:01 |
|*  2 |   TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEE    | 32500 |  2443K|       | 14180   (1)| 00:00:01 |
|*  3 |    INDEX RANGE SCAN                  | EMPLOYEE_UK | 35326 |       |       |   140   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

    2 - filter("E"."STATUS"='ACTIVE')
    3 - access("E"."COMPANY_KEY"=20)
*******************************************************************************/

/*
 전체 조회하는 데 1초도 채 걸리지 않았다. 하지만 SORT ORDER BY Operator 가 병목이라면 병목일 텐데,
 이를 인덱스로 만들어 우회하는 것도 가능은 할 것이다.
 EMPLOYEE_IX_02(company_key, status, hire_date, employee_key) 정도로 구성하면 될 것이다.

 하지만 앞서 설명했듯 Docker 환경 + SQL 툴로 확인해보았을 때 fetch 시간이 1초도 채 걸리지 않았기 때문에
 굳이 추가하지는 않았다.
 */
