SELECT *
FROM (
    SELECT
    e.employee_key
    ,   e.employee_name
    ,   e.company_key
    ,   e.position_code
    ,   s.base_salary
    ,   s.bonus
    ,   (s.base_salary + s.bonus) AS total_salary
    FROM employee   e
        ,salary     s
    WHERE s.employee_key = e.employee_key
      AND s.end_date IS NULL
    ORDER BY total_salary desc, employee_key
)
WHERE ROWNUM <= 1
;

/*******************************************************************************
Plan hash value: 1315529296

--------------------------------------------------------------------------------------------
| Id  | Operation               | Name     | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT        |          |     1 |    55 |       |   137K  (1)| 00:00:06 |
|*  1 |  COUNT STOPKEY          |          |       |       |       |            |          |
|   2 |   VIEW                  |          |  5000K|   262M|       |   137K  (1)| 00:00:06 |
|*  3 |    SORT ORDER BY STOPKEY|          |  5000K|   257M|   325M|   137K  (1)| 00:00:06 |
|*  4 |     HASH JOIN           |          |  5000K|   257M|   152M| 71583   (1)| 00:00:03 |
|*  5 |      TABLE ACCESS FULL  | SALARY   |  5000K|    95M|       | 27636   (1)| 00:00:02 |
|   6 |      TABLE ACCESS FULL  | EMPLOYEE |  5000K|   162M|       | 25471   (1)| 00:00:01 |
--------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(ROWNUM<=1)
   3 - filter(ROWNUM<=1)
   4 - access("S"."EMPLOYEE_KEY"="E"."EMPLOYEE_KEY")
   5 - filter("S"."END_DATE" IS NULL)
*******************************************************************************/

/*
 위 실행계획으로 보고 생각이 맨처음 드는 생각은 최고인 행만 빠르게 조회하는 것이 목표일 테니 굳이
 Employee 정보를 저 Salary 와 조인한 서브쿼리(View) 안에서 찾을 필요가 없다는 점이다.
 */
SELECT
    e.employee_key
     ,   e.employee_name
     ,   e.company_key
     ,   e.position_code
     ,   x.base_salary
     ,   x.bonus
     ,   x.total_salary
FROM (
    SELECT *
    FROM (
        SELECT /*+ index_ffs(e) */
            e.employee_key
        ,   s.base_salary
        ,   s.bonus
        ,   (s.base_salary + s.bonus) AS total_salary
        FROM employee   e
            ,salary     s
        WHERE (CASE WHEN s.end_date IS NULL THEN s.employee_key END) = e.employee_key
        ORDER BY total_salary desc, e.employee_key
    )
    WHERE ROWNUM <= 1
) x
, employee e
WHERE e.employee_key = x.employee_key
;

/*******************************************************************************
Plan hash value: 2875049953

----------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name        | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |             |     1 |    61 |       | 68009   (1)| 00:00:03 |
|   1 |  NESTED LOOPS                |             |     1 |    61 |       | 68009   (1)| 00:00:03 |
|   2 |   NESTED LOOPS               |             |     1 |    61 |       | 68009   (1)| 00:00:03 |
|   3 |    VIEW                      |             |     1 |    27 |       | 68007   (1)| 00:00:03 |
|*  4 |     COUNT STOPKEY            |             |       |       |       |            |          |
|   5 |      VIEW                    |             |  5000K|   128M|       | 68007   (1)| 00:00:03 |
|*  6 |       SORT ORDER BY STOPKEY  |             |  5000K|    81M|   134M| 68007   (1)| 00:00:03 |
|*  7 |        HASH JOIN             |             |  5000K|    81M|    85M| 40505   (1)| 00:00:02 |
|   8 |         INDEX FAST FULL SCAN | EMPLOYEE_PK |  5000K|    28M|       |  3041   (1)| 00:00:01 |
|*  9 |         TABLE ACCESS FULL    | SALARY      |  5000K|    52M|       | 27732   (1)| 00:00:02 |
|* 10 |    INDEX UNIQUE SCAN         | EMPLOYEE_PK |     1 |       |       |     1   (0)| 00:00:01 |
|  11 |   TABLE ACCESS BY INDEX ROWID| EMPLOYEE    |     1 |    34 |       |     2   (0)| 00:00:01 |
----------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   4 - filter(ROWNUM<=1)
   6 - filter(ROWNUM<=1)
   7 - access("E"."EMPLOYEE_KEY"=CASE  WHEN ("END_DATE" IS NULL) THEN "EMPLOYEE_KEY" END )
   9 - filter(CASE  WHEN "END_DATE" IS NULL THEN "EMPLOYEE_KEY" END  IS NOT NULL)
  10 - access("E"."EMPLOYEE_KEY"="X"."EMPLOYEE_KEY")
*******************************************************************************/

/*
 적어도 이전보다 Cost 도 많이 줄였고 Random Access 도 줄였다.
 하지만 여전히 Max 되는 것을 구하기 위해 Employee 의 인덱스 leaf 들과 Salary 를 모두 읽어
 Hash Join 을 해야하므로 Temp 공간도 많이 사용하고 5000K 를 모두 처리해야함은 변하지 않았다.

 다음은 FBI 로 미리 base_salary + bonus 값을 계산한 뒤 이를 통해 최대 값을 미리 구하는 방식이다.
 */
CREATE INDEX SALARY_IX_CUR_TOTAL
    ON SALARY(
              CASE WHEN END_DATE IS NULL THEN BASE_SALARY + BONUS END
        )
    TABLESPACE TSD_SALARY_IDX
;

WITH mx AS (
    SELECT MAX(CASE WHEN end_date IS NULL THEN base_salary + bonus END) AS total_salary
    FROM salary
)
SELECT /*+ index(s) index(e) */
    e.employee_key
     ,   e.employee_name
     ,   e.position_code
     ,   s.base_salary
     ,   s.bonus
     ,   mx.total_salary
FROM mx
   ,salary s
   ,employee e
WHERE (CASE WHEN s.end_date IS NULL THEN s.base_salary + s.bonus END) = mx.total_salary
  AND e.employee_key = s.employee_key
  AND ROWNUM = 1
;

/*******************************************************************************
Plan hash value: 1951395777

---------------------------------------------------------------------------------------------------------------
| Id  | Operation                               | Name                | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                        |                     |     1 |    70 |    10   (0)| 00:00:01 |
|*  1 |  COUNT STOPKEY                          |                     |       |       |            |          |
|   2 |   NESTED LOOPS                          |                     |     2 |   140 |    10   (0)| 00:00:01 |
|   3 |    NESTED LOOPS                         |                     |     2 |   140 |    10   (0)| 00:00:01 |
|   4 |     NESTED LOOPS                        |                     |     2 |    80 |     6   (0)| 00:00:01 |
|   5 |      VIEW                               |                     |     1 |    13 |     3   (0)| 00:00:01 |
|   6 |       SORT AGGREGATE                    |                     |     1 |    13 |            |          |
|   7 |        INDEX FULL SCAN (MIN/MAX)        | SALARY_IX_CUR_TOTAL |     1 |    13 |     3   (0)| 00:00:01 |
|   8 |      TABLE ACCESS BY INDEX ROWID BATCHED| SALARY              |     2 |    54 |     3   (0)| 00:00:01 |
|*  9 |       INDEX RANGE SCAN                  | SALARY_IX_CUR_TOTAL |     1 |       |     2   (0)| 00:00:01 |
|* 10 |     INDEX UNIQUE SCAN                   | EMPLOYEE_PK         |     1 |       |     1   (0)| 00:00:01 |
|  11 |    TABLE ACCESS BY INDEX ROWID          | EMPLOYEE            |     1 |    30 |     2   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(ROWNUM=1)
   9 - access(CASE  WHEN "END_DATE" IS NULL THEN "BASE_SALARY"+"BONUS" END ="MX"."TOTAL_SALARY")
  10 - access("E"."EMPLOYEE_KEY"="S"."EMPLOYEE_KEY")
*******************************************************************************/

/*
 전체에서 1등을 고르는 문제이므로, 전수 접근이 불가피하다.
 그렇기에 별다른 조건 없이 집계 함수(MAX, MIN, SUM, AVG 등)을 사용하면 나타나는 SORT AGGREGATE
 (해당 Operator 는 PGA 에서 처리하므로 성능이 빠르다.) 를 유도하면서,
 INDEX FULL SCAN (MIN/MAX) 를 사용하면 필요한 Block 만 읽고 처리하기 때문에 매우 빠르다.

 그리고 메인 쿼리에서 실제 필요한 (수직적 탐색을 통한) 조인을 하여 최소 행을 조회하면서,
 가능한 Random Access 를 최소화하도록 하여 매우 빠르게 조회할 수 있다.

 다만, 이 방식은 Salary 와 같은 Append Only 특성이 있는 (완전한 Append Only 는 아니다. END_DATE 를 업데이트하므로)
 테이블에 적합할 수 있을 것이다. FBI 는 Insert/Update 할 때마다 새로 계산해서 갱신을 하기 때문에 부담이 꽤 있는 편인데,
 위 Index 는 Salary 의 특성을 잘 살려졌기에 관계없다.
 여기서 말하는 특성이란 END_DATE 는 NULLABLE 칼럼이라는 것이고, FBI 로 null 이 허용되어 있는 것으로 보인다.
 그리고 적어도 Oracle B-Tree 는 키가 모두 Null 이면 엔트리에 저장을 하지 않기 때문에 사실상 Insert 에 대한 비용이 공짜라 다름없다.
 (신규 행은 END_DATE 가 항상 NULL 이고, 기존 행에 대한 인덱스 업데이트 비용만 들기 때문)
 */
