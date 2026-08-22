/*
 03-join 에서 사용했던 Index 를 그대로 사용할 수 있다.
 EMPLOYEE_IX_01 인덱스는 (DEPARTMENT_KEY, STATUS) 로 이루어져 있다.
 */
SELECT
    d.department_key
,   d.department_name
,   count(e.employee_key) AS CNT_CURRENT_EMPLOYEE
FROM department d
    ,employee   e
WHERE e.department_key (+)= d.department_key
  AND e.status     (+)= 'ACTIVE'
GROUP BY d.department_key, d.department_name
;

/*******************************************************************************
Plan hash value: 2850685110

------------------------------------------------------------------------------------------
| Id  | Operation               | Name           | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |                |   100K|  4003K|  4679   (3)| 00:00:01 |
|*  1 |  HASH JOIN RIGHT OUTER  |                |   100K|  4003K|  4679   (3)| 00:00:01 |
|   2 |   VIEW                  | VW_GBC_5       | 18768 |   329K|  4408   (4)| 00:00:01 |
|   3 |    HASH GROUP BY        |                | 18768 |   238K|  4408   (4)| 00:00:01 |
|*  4 |     INDEX FAST FULL SCAN| EMPLOYEE_IX_01 |  4600K|    57M|  4298   (1)| 00:00:01 |
|   5 |   TABLE ACCESS FULL     | DEPARTMENT     |   100K|  2246K|   271   (1)| 00:00:01 |

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("ITEM_1"(+)="D"."DEPARTMENT_KEY")
   4 - filter("E"."STATUS"(+)='ACTIVE')
*******************************************************************************/

/*
 위 방식은 VIEW + HASH GROUP BY 방식인 탓에 전체를 조회하는 데 있어서는
 매우 효과적이다. HASH GROUP BY 는 Blocking 연산으로 모든 엔트리를 전부 집계하기 때문에
 속도는 느리지만, fetch 를 50개를 하든, 200개를 하든, 아님 전부(100K)를 하든
 속도는 일정하다.

 반면 다음과 같이 Nested Loops 방식 혹은 스칼라 쿼리로 조회하는 경우에는 Pipelined 방식이기에
 fetch 건수에 정비례해서 조회 속도가 증가한다.
 */

-- 스칼라 쿼리 방식
SELECT
    d.department_key
     ,   d.department_name
     ,   (SELECT COUNT(*)
          FROM employee e
          WHERE e.department_key = d.department_key
            AND e.status         = 'ACTIVE'
) AS CNT_CURRENT_EMPLOYEE
FROM department d
;

SELECT /*+ NO_PLACE_GROUP_BY LEADING(d) USE_NL(e) INDEX(e) */
    d.department_key, d.department_name
,   NVL(e.cnt, 0) AS CNT_CURRENT_EMPLOYEE
FROM department d
    ,(SELECT department_key, COUNT(*) cnt
      FROM employee
      WHERE status = 'ACTIVE'
      GROUP BY department_key) e
WHERE e.department_key (+)= d.department_key
;

/*******************************************************************************
Plan hash value: 4115416954

------------------------------------------------------------------------------------------
| Id  | Operation               | Name           | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |                |   100K|  4003K|   300K  (1)| 00:00:12 |
|   1 |  NESTED LOOPS OUTER     |                |   100K|  4003K|   300K  (1)| 00:00:12 |
|   2 |   TABLE ACCESS FULL     | DEPARTMENT     |   100K|  2246K|   271   (1)| 00:00:01 |
|   3 |   VIEW PUSHED PREDICATE |                |     1 |    18 |     3   (0)| 00:00:01 |
|   4 |    SORT GROUP BY        |                |     1 |    13 |     3   (0)| 00:00:01 |
|*  5 |     INDEX RANGE SCAN    | EMPLOYEE_IX_01 |   245 |  3185 |     3   (0)| 00:00:01 |

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - access("DEPARTMENT_KEY"="D"."DEPARTMENT_KEY" AND "STATUS"='ACTIVE')
*******************************************************************************/

/*
 실행 계획의 Cost 를 보면 확실히 와 닿는다.
 물론 Cost 를 100% 신뢰해서는 안되지만, 적어도 옵티마이저는 실행게획 만들고 나서
 대략적인 Cost 를 300K 만큼 사용할 것이라고 예상한 것이다.
 */
