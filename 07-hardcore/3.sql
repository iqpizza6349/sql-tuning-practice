SELECT
    x.employee_key
,   e.employee_name
,   x.base_salary_prev AS previous_aalary
,   x.base_salary AS current_salary
,   (x.base_salary - x.base_salary_prev) AS increase_amount
,   x.start_date
FROM (
    SELECT
        s.employee_key
    ,   s.base_salary
    ,   s.start_date
    ,   s.end_date
    ,   LAG(s.base_salary) OVER(PARTITION BY s.employee_key ORDER BY s.start_date) AS base_salary_prev
    FROM salary     s
--    WHERE s.employee_key = 82699
) x
, employee e
WHERE x.end_date IS NULL
  AND x.base_salary > x.base_salary_prev
  AND e.employee_key = x.employee_key
ORDER BY x.start_date DESC, x.employee_key DESC
;

/*******************************************************************************
Plan hash value: 1083197608

------------------------------------------------------------------------------------------
| Id  | Operation             | Name     | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |          |    14M|   864M|       |   414K  (1)| 00:00:17 |
|   1 |  SORT ORDER BY        |          |    14M|   864M|  1027M|   414K  (1)| 00:00:17 |
|   2 |   MERGE JOIN          |          |    14M|   864M|       |   195K  (1)| 00:00:08 |
|*  3 |    VIEW               |          |    15M|   543M|       |   135K  (1)| 00:00:06 |
|   4 |     WINDOW SORT       |          |    15M|   357M|   574M|   135K  (1)| 00:00:06 |
|   5 |      TABLE ACCESS FULL| SALARY   |    15M|   357M|       | 27595   (1)| 00:00:02 |
|*  6 |    SORT JOIN          |          |  5000K|   109M|   306M| 59512   (1)| 00:00:03 |
|   7 |     TABLE ACCESS FULL | EMPLOYEE |  5000K|   109M|       | 25444   (1)| 00:00:01 |
------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

    3 - filter("X"."END_DATE" IS NULL AND "X"."BASE_SALARY">"X"."BASE_SALARY_PREV")
    6 - access("E"."EMPLOYEE_KEY"="X"."EMPLOYEE_KEY")
        filter("E"."EMPLOYEE_KEY"="X"."EMPLOYEE_KEY")
*******************************************************************************/

/*
 LAG 방식은 윈도우 함수이긴 하지만, ORDER BY 가 강제되는 탓에 WINDOW SORT 가 강제된다.
 그렇다고 X 서브쿼리 안에서 END_DATE IS NOT NULL 로 이력만 꺼내왔다가는 정작 중요한
 현재 급여와의 차이를 알 수 없게되어 버그가 나온다.

 또한 카디널리티가 15M 으로 어마어마한 수의 카디널리티가 나와버리고 만다.
 그렇기에 VIEW PUSHED PREDICATE Operator 로 먼저 WHERE 절을 실행해야한다.

 일반적인 View Merge 는 다음과 같이 동작한다.
   1. 뷰 실행: 뷰가 정의된 SQL 을 실행한다. (가상 테이블 생성됨)
   2. 필터 적용: 그 결과에 쿼리의 WHERE 절 조건이 적용된다.
 VIEW PUSHED PREDICATE 는 다음과 같이 동작한다.
   1. 필터 푸시 다운: 쿼리의 WHERE 절 조건이 뷰의 SQL 내부로 PUSH 되어 먼저 실행한다.
   2. 뷰 실행: PUSH 된 조건에 따라 뷰의 기본 테이블에서 필요한 데이터만 필터링 처리된다.
 */
SELECT /*+ leading(x r e) use_nl(r e) push_pred(x) */
    x.employee_key
,   e.employee_name
,   r.base_salary AS previous_salary
,   x.base_salary AS current_salary
,   (x.base_salary - r.base_salary) AS increase_amount
,   x.start_date
FROM (
    SELECT /*+ no_merge */
        CASE WHEN s.end_date IS NULL THEN s.employee_key END AS employee_key
    ,   CASE WHEN s.end_date IS NULL THEN s.start_date END AS start_date
    ,   CASE WHEN s.end_date IS NULL THEN s.base_salary END AS base_salary
    FROM salary s
    WHERE (CASE WHEN s.end_date IS NULL THEN s.employee_key END) IS NOT NULL
) x
,LATERAL (
    SELECT /*+ index_desc(h SALARY_UK) */
        h.base_salary
    FROM salary h
    WHERE h.employee_key = x.employee_key
      AND h.end_date IS NOT NULL
    ORDER BY h.start_date DESC
    FETCH FIRST 1 ROWS ONLY
) r
, employee e
WHERE x.base_salary > r.base_salary
  AND e.employee_key= x.employee_key
ORDER BY x.start_date DESC, x.employee_key DESC
    FETCH FIRST 10 ROWS ONLY
;

/*******************************************************************************
Plan hash value: 5005667

------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                   | Name              | Rows  | Bytes |TempSpc| Cost (%CPU)| Time    |
------------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                            |                   |    10 |   600 |       |    23M  (8)| 00:15:13|
|*  1 |  COUNT STOPKEY                              |                   |       |       |       |            |         |
|   2 |   VIEW                                      |                   | 83333 |  4882K|       |    23M  (8)| 00:15:13|
|*  3 |    SORT ORDER BY STOPKEY                    |                   | 83333 |  4313K|  4912K|    23M  (8)| 00:15:13|
|   4 |     NESTED LOOPS                            |                   | 83333 |  4313K|       |    23M  (8)| 00:15:13|
|   5 |      NESTED LOOPS                           |                   |  1666K|    76M|       |    15M  (1)| 00:09:48|
|   6 |       TABLE ACCESS FULL                     | EMPLOYEE          |  5000K|   109M|       | 25444   (1)| 00:00:01|
|   7 |       VIEW PUSHED PREDICATE                 |                   |     1 |    25 |       |     3   (0)| 00:00:01|
|   8 |        TABLE ACCESS BY INDEX ROWID          | SALARY            |     1 |    22 |       |     3   (0)| 00:00:01|
|*  9 |         INDEX UNIQUE SCAN                   | SALARY_CURRENT_UK |     1 |       |       |     2   (0)| 00:00:01|
|* 10 |      VIEW                                   | VW_LAT_A18161FF   |     1 |     5 |       |     5  (20)| 00:00:01|
|* 11 |       COUNT STOPKEY                         |                   |       |       |       |            |         |
|  12 |        VIEW                                 |                   |     1 |     5 |       |     5  (20)| 00:00:01|
|* 13 |         SORT ORDER BY STOPKEY               |                   |     1 |    25 |       |     5  (20)| 00:00:01|
|* 14 |          TABLE ACCESS BY INDEX ROWID BATCHED| SALARY            |     1 |    25 |       |     4   (0)| 00:00:01|
|* 15 |           INDEX RANGE SCAN DESCENDING       | SALARY_UK         |     1 |       |       |     3   (0)| 00:00:01|
------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(ROWNUM<=10)
   3 - filter(ROWNUM<=10)
   9 - access(CASE  WHEN "END_DATE" IS NULL THEN "EMPLOYEE_KEY" END ="E"."EMPLOYEE_KEY")
       filter(CASE  WHEN "END_DATE" IS NULL THEN "EMPLOYEE_KEY" END  IS NOT NULL)
  10 - filter("X"."BASE_SALARY">"R"."BASE_SALARY")
  11 - filter(ROWNUM<=1)
  13 - filter(ROWNUM<=1)
  14 - filter("H"."END_DATE" IS NOT NULL)
  15 - access("H"."EMPLOYEE_KEY"="X"."EMPLOYEE_KEY")

Hint Report (identified by operation id / Query Block Name / Object Alias):
Total hints for statement: 3 (U - Unused (3))
---------------------------------------------------------------------------

   3 -  SEL$1
         U -  leading(x r e)

   6 -  SEL$1 / "E"@"SEL$1"
         U -  use_nl(r e)

  14 -  SEL$3 / "H"@"SEL$3"
         U -  index_desc(h SALARY_UK)
*******************************************************************************/

/*
 이번엔 실행계획 상 카디널리티는 줄었다. 그리고 이게 현재로선 최선이다.
 use_nl 과 leading 은 따로 힌트로 주지 않더라도 옵티마이저도 해당 플랜을 사용한다.

 다음은 번외다. Salary 테이블에 FBI 인덱스를 만들어서 Index Full Scan Descending 방식으로
 처리하는 방식이다.
 */
CREATE INDEX SALARY_IX_CURRENT_START
ON SALARY(
    (CASE WHEN END_DATE IS NULL THEN START_DATE END)
,   (CASE WHEN END_DATE IS NULL THEN EMPLOYEE_KEY END)
,   (CASE WHEN END_DATE IS NULL THEN BASE_SALARY END)
)
TABLESPACE TSD_SALARY_IDX
;

SELECT /*+ leading(x r e) use_nl(r e) */
    x.employee_key
,   e.employee_name
,   r.base_salary AS previous_salary
,   x.base_salary AS current_salary
,   (x.base_salary - r.base_salary) AS increase_amount
,   x.start_date
FROM (
    SELECT /*+ no_merge index_desc(s SALARY_IX_CURRENT_START) */
        CASE WHEN s.end_date IS NULL THEN s.employee_key END AS employee_key
    ,   CASE WHEN s.end_date IS NULL THEN s.start_date END AS start_date
    ,   CASE WHEN s.end_date IS NULL THEN s.base_salary END AS base_salary
    FROM salary s
    WHERE (CASE WHEN s.end_date IS NULL THEN s.start_date END) IS NOT NULL
    ORDER BY start_date DESC, employee_key DESC
) x
,LATERAL (
    SELECT /*+ index_desc(h SALARY_UK) */
        h.base_salary
    FROM salary h
    WHERE h.employee_key = x.employee_key
      AND h.end_date IS NOT NULL
    ORDER BY h.start_date DESC
    FETCH FIRST 1 ROWS ONLY
) r
, employee e
WHERE x.base_salary > r.base_salary
  AND e.employee_key= x.employee_key
ORDER BY x.start_date DESC, x.employee_key DESC
    FETCH FIRST 10 ROWS ONLY
;

/*******************************************************************************
Plan hash value: 1404088525

-----------------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name                    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                         |    10 |   500 |   912  (19)| 00:00:01 |
|*  1 |  COUNT STOPKEY                        |                         |       |       |            |          |
|   2 |   VIEW                                |                         |    10 |   500 |   912  (19)| 00:00:01 |
|   3 |    NESTED LOOPS                       |                         |    10 |   430 |   912  (19)| 00:00:01 |
|   4 |     NESTED LOOPS                      |                         |    31 |   430 |   912  (19)| 00:00:01 |
|   5 |      NESTED LOOPS                     |                         |    31 |   620 |   851  (20)| 00:00:01 |
|   6 |       VIEW                            |                         |   170 |  2550 |     1   (0)| 00:00:01 |
|*  7 |        INDEX FULL SCAN DESCENDING     | SALARY_IX_CURRENT_START |  5510K|    78M| 20186   (1)| 00:00:01 |
|*  8 |       VIEW                            | VW_LAT_A18161FF         |     1 |     5 |     5  (20)| 00:00:01 |
|*  9 |        COUNT STOPKEY                  |                         |       |       |            |          |
|  10 |         VIEW                          |                         |     1 |     5 |     5  (20)| 00:00:01 |
|* 11 |          SORT ORDER BY STOPKEY        |                         |     1 |    25 |     5  (20)| 00:00:01 |
|* 12 |           TABLE ACCESS BY INDEX ROWID | SALARY                  |     1 |    25 |     4   (0)| 00:00:01 |
|* 13 |            INDEX RANGE SCAN DESCENDING| SALARY_UK               |     1 |       |     3   (0)| 00:00:01 |
|* 14 |      INDEX UNIQUE SCAN                | EMPLOYEE_PK             |     1 |       |     1   (0)| 00:00:01 |
|  15 |     TABLE ACCESS BY INDEX ROWID       | EMPLOYEE                |     1 |    23 |     2   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter(ROWNUM<=10)
   7 - filter(CASE  WHEN "END_DATE" IS NULL THEN "START_DATE" END  IS NOT NULL)
   8 - filter("X"."BASE_SALARY">"R"."BASE_SALARY")
   9 - filter(ROWNUM<=1)
  11 - filter(ROWNUM<=1)
  12 - filter("H"."END_DATE" IS NOT NULL)
  13 - access("H"."EMPLOYEE_KEY"="X"."EMPLOYEE_KEY")
  14 - access("E"."EMPLOYEE_KEY"="X"."EMPLOYEE_KEY")

Hint Report (identified by operation id / Query Block Name / Object Alias):
Total hints for statement: 1 (U - Unused (1))
---------------------------------------------------------------------------

  12 -  SEL$3 / "H"@"SEL$3"
         U -  index_desc(h SALARY_UK)
*******************************************************************************/

/*
 카디널리티로 보나 Cost 로 보나 단위가 매우 내려갔다. 이러한 이유는 사실 데이터의 특성에 있다.
 현재 세팅된 데이터로는 무조건 3건의 이력(현재 포함)을 각 employee 마다 가지도록 했고,
 무조건 상승하도록만 만들었기 때문이다.

 하지만 만일 데이터 내역 중 현재 데이터만 가지고 있는 경우, 임금 삭감, 동결 등의 데이터가 있다면,
 성능은 점차 저하될 것이다. 그런 경우 차라리 MultiBlock I/O 를 사용하는 Index Fast Full Scan 이나
 Table Access Full 이 더 좋은 선택일 것이다.
 (Index Fast Scan 은 single block I/O 이므로)
 */




