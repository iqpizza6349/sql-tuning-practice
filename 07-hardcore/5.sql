SELECT
    e.*
FROM employee e
WHERE e.company_key     = :company_key
  AND e.department_key  = :department_key
  AND (:position_code IS NULL OR e.position_code = :position_code)
  AND (:status IS NULL OR e.status = :status)
  AND (:start_date IS NULL OR e.hire_date >= TO_DATE(:start_date, 'YYYY-MM-DD'))
  AND (:end_date IS NULL OR e.hire_date <= TO_DATE(:end_date, 'YYYY-MM-DD'))
ORDER BY e.employee_key DESC
OFFSET 0 * 50 ROWS FETCH NEXT 50 ROWS ONLY
;

/*******************************************************************************
Plan hash value: 2779457677

--------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name           | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                |     1 |    99 |    27  (12)| 00:00:01 |
|*  1 |  VIEW                                 |                |     1 |    99 |    27  (12)| 00:00:01 |
|*  2 |   WINDOW SORT PUSHED RANK             |                |     1 |    77 |    27  (12)| 00:00:01 |
|*  3 |    TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEE       |     1 |    77 |    26   (8)| 00:00:01 |
|   4 |     BITMAP CONVERSION TO ROWIDS       |                |       |       |            |          |
|   5 |      BITMAP AND                       |                |       |       |            |          |
|   6 |       BITMAP CONVERSION FROM ROWIDS   |                |       |       |            |          |
|   7 |        SORT ORDER BY                  |                |       |       |            |          |
|*  8 |         INDEX RANGE SCAN              | EMPLOYEE_IX_01 |    77 |       |     3   (0)| 00:00:01 |
|   9 |       BITMAP CONVERSION FROM ROWIDS   |                |       |       |            |          |
|  10 |        SORT ORDER BY                  |                |       |       |            |          |
|* 11 |         INDEX RANGE SCAN              | EMPLOYEE_UK    |    77 |       |    21   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=50 AND
              "from$_subquery$_002"."rowlimit_$$_rownumber">0)
   2 - filter(ROW_NUMBER() OVER ( ORDER BY "E"."EMPLOYEE_KEY" DESC )<=50)
   3 - filter(("E"."POSITION_CODE"=:POSITION_CODE OR :POSITION_CODE IS NULL) AND (:START_DATE
              IS NULL OR "E"."HIRE_DATE">=TO_DATE(:START_DATE,'YYYY-MM-DD')) AND (:END_DATE IS NULL OR
              "E"."HIRE_DATE"<=TO_DATE(:END_DATE,'YYYY-MM-DD')))
   8 - access("E"."DEPARTMENT_KEY"=TO_NUMBER(:DEPARTMENT_KEY))
       filter(("E"."STATUS"=:STATUS OR :STATUS IS NULL) AND
              "E"."DEPARTMENT_KEY"=TO_NUMBER(:DEPARTMENT_KEY))
  11 - access("E"."COMPANY_KEY"=TO_NUMBER(:COMPANY_KEY))
       filter("E"."COMPANY_KEY"=TO_NUMBER(:COMPANY_KEY))
*******************************************************************************/

-- 5.sql: position_code is not null
SELECT
    e.*
FROM employee e
WHERE e.company_key     = 300
  AND e.department_key  = 29998
  AND ('MANAGER' IS NULL OR e.position_code = 'MANAGER')
  AND (NULL IS NULL OR e.status = NULL)
  AND (NULL IS NULL OR e.hire_date >= TO_DATE(NULL, 'YYYY-MM-DD'))
  AND (NULL IS NULL OR e.hire_date <= TO_DATE(NULL, 'YYYY-MM-DD'))
ORDER BY e.employee_key DESC
OFFSET 0 * 50 ROWS FETCH NEXT 50 ROWS ONLY
;

/*******************************************************************************
Plan hash value: 2779457677

--------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name           | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                |     1 |    99 |    15  (20)| 00:00:01 |
|*  1 |  VIEW                                 |                |     1 |    99 |    15  (20)| 00:00:01 |
|*  2 |   WINDOW SORT PUSHED RANK             |                |     1 |    77 |    15  (20)| 00:00:01 |
|*  3 |    TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEE       |     1 |    77 |    14  (15)| 00:00:01 |
|   4 |     BITMAP CONVERSION TO ROWIDS       |                |       |       |            |          |
|   5 |      BITMAP AND                       |                |       |       |            |          |
|   6 |       BITMAP CONVERSION FROM ROWIDS   |                |       |       |            |          |
|   7 |        SORT ORDER BY                  |                |       |       |            |          |
|*  8 |         INDEX RANGE SCAN              | EMPLOYEE_IX_01 |   266 |       |     3   (0)| 00:00:01 |
|   9 |       BITMAP CONVERSION FROM ROWIDS   |                |       |       |            |          |
|  10 |        SORT ORDER BY                  |                |       |       |            |          |
|* 11 |         INDEX RANGE SCAN              | EMPLOYEE_UK    |   266 |       |     9   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=50 AND
              "from$_subquery$_002"."rowlimit_$$_rownumber">0)
   2 - filter(ROW_NUMBER() OVER ( ORDER BY "E"."EMPLOYEE_KEY" DESC )<=50)
   3 - filter("E"."POSITION_CODE"='MANAGER')
   8 - access("E"."DEPARTMENT_KEY"=29998)
       filter("E"."DEPARTMENT_KEY"=29998)
  11 - access("E"."COMPANY_KEY"=300)
       filter("E"."COMPANY_KEY"=300)
*******************************************************************************/

-- 5.sql: status is not null
SELECT
    e.*
FROM employee e
WHERE e.company_key     = 300
  AND e.department_key  = 29998
  AND (NULL IS NULL OR e.position_code = NULL)
  AND ('ACTIVE' IS NULL OR e.status = 'ACTIVE')
  AND (NULL IS NULL OR e.hire_date >= TO_DATE(NULL, 'YYYY-MM-DD'))
  AND (NULL IS NULL OR e.hire_date <= TO_DATE(NULL, 'YYYY-MM-DD'))
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
|   3 |    TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEE       |     1 |    77 |    13   (8)| 00:00:01 |
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
   7 - access("E"."DEPARTMENT_KEY"=29998 AND "E"."STATUS"='ACTIVE')
  10 - access("E"."COMPANY_KEY"=300)
       filter("E"."COMPANY_KEY"=300)
*******************************************************************************/

-- 5.sql: hire_date filter is not null
SELECT
    e.*
FROM employee e
WHERE e.company_key     = 300
  AND e.department_key  = 29998
  AND (NULL IS NULL OR e.position_code = NULL)
  AND (NULL IS NULL OR e.status = NULL)
  AND ('2019-01-01' IS NULL OR e.hire_date >= TO_DATE('2019-01-01', 'YYYY-MM-DD'))
  AND ('2020-01-01' IS NULL OR e.hire_date <= TO_DATE('2020-01-01', 'YYYY-MM-DD'))
ORDER BY e.employee_key DESC
OFFSET 0 * 50 ROWS FETCH NEXT 50 ROWS ONLY
;

/*******************************************************************************
Plan hash value: 2779457677

--------------------------------------------------------------------------------------------------------
| Id  | Operation                             | Name           | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                      |                |     1 |    99 |    15  (20)| 00:00:01 |
|*  1 |  VIEW                                 |                |     1 |    99 |    15  (20)| 00:00:01 |
|*  2 |   WINDOW SORT PUSHED RANK             |                |     1 |    77 |    15  (20)| 00:00:01 |
|*  3 |    TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEE       |     1 |    77 |    14  (15)| 00:00:01 |
|   4 |     BITMAP CONVERSION TO ROWIDS       |                |       |       |            |          |
|   5 |      BITMAP AND                       |                |       |       |            |          |
|   6 |       BITMAP CONVERSION FROM ROWIDS   |                |       |       |            |          |
|   7 |        SORT ORDER BY                  |                |       |       |            |          |
|*  8 |         INDEX RANGE SCAN              | EMPLOYEE_IX_01 |   266 |       |     3   (0)| 00:00:01 |
|   9 |       BITMAP CONVERSION FROM ROWIDS   |                |       |       |            |          |
|  10 |        SORT ORDER BY                  |                |       |       |            |          |
|* 11 |         INDEX RANGE SCAN              | EMPLOYEE_UK    |   266 |       |     9   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------------------
Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=50 AND
              "from$_subquery$_002"."rowlimit_$$_rownumber">0)
   2 - filter(ROW_NUMBER() OVER ( ORDER BY "E"."EMPLOYEE_KEY" DESC )<=50)
   3 - filter("E"."HIRE_DATE">=TO_DATE(' 2019-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss') AND
              "E"."HIRE_DATE"<=TO_DATE(' 2020-01-01 00:00:00', 'syyyy-mm-dd hh24:mi:ss'))
   8 - access("E"."DEPARTMENT_KEY"=29998)
       filter("E"."DEPARTMENT_KEY"=29998)
  11 - access("E"."COMPANY_KEY"=300)
       filter("E"."COMPANY_KEY"=300)
*******************************************************************************/

-- 5.sql: all not null
SELECT /*+ index(e EMPLOYEE_IX_01) */
    e.*
FROM employee e
WHERE e.company_key     = 300
  AND e.department_key  = 29998
  AND ('MANAGER' IS NULL OR e.position_code = 'MANAGER')
  AND ('ACTIVE' IS NULL OR e.status = 'ACTIVE')
  AND ('2019-01-01' IS NULL OR e.hire_date >= TO_DATE('2019-01-01', 'YYYY-MM-DD'))
  AND ('2020-01-01' IS NULL OR e.hire_date <= TO_DATE('2020-01-01', 'YYYY-MM-DD'))
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

/*
 해당 문항은 Operation 과 Bytes 가 일정하게 나오는 지에 대해 확인하는 것이 목표다.

 현대에 와서는 많은 Filter 정보들의 대해서 애플리케이션과 다양한 프레임워크를 활용해
 쿼리 문자열을 조합해 만드는 것을 선호하고 그리 만들어진 프레임워크, 혹은 그것을 팀 내 가이드로
 사용하는 경우가 더러 존재해 만든 문항이다.

 문제는 필터는 사용자 요구사항에 의해 얼마든지 추가될 수 있다는 것이다.
 필수값이 Optional 으로 빠지는 것보다는 Optional 이 필수가 되거나 아님,
 Optional 이 추가되거나 신규 필수가 추가되는 등이 대표적일 텐데,
 그럴 때마다 페이지네이션 쿼리의 실행계획을 모든 케이스마다 확인하여
 튜닝을 하는 것은 꽤 끔찍하다고 생각된다.

 물론 필수값들만 넣고 실행하는 것과 옵션을 넣어놓고 실행하는 것에는 분명 차이가 존재하겠으나,
 적어도 한 가지 방향뿐만이 아닌 이러한 방향도 존재한다는 것을 인지하고 개발하기를 바라는 마음에
 만들게 되었다.
 */
