/*
 3-advanced.sql 의 인덱스를 그대로 사용한다.
 */
CREATE INDEX SALARY_IX_SALARY
ON SALARY(
    (CASE WHEN end_date IS NULL THEN base_salary END)
,   (CASE WHEN end_date IS NULL THEN bonus END)
,   (CASE WHEN end_date IS NULL THEN employee_key END)
)
TABLESPACE TSD_SALARY_IDX
;

WITH page AS (
    SELECT /*+ index_desc(s SALARY_IX_SALARY) no_merge */
        CASE WHEN s.end_date IS NULL THEN s.employee_key END AS employee_key
    ,   CASE WHEN s.end_date IS NULL THEN s.base_salary  END AS base_salary
    ,   CASE WHEN s.end_date IS NULL THEN s.bonus        END AS bonus
    FROM salary s
    WHERE (CASE WHEN end_date IS NULL THEN employee_key END) IS NOT NULL
    ORDER BY 2 DESC, 3 DESC, 1 DESC
    OFFSET 1999980 ROWS FETCH NEXT 20 ROWS ONLY
)
SELECT /*+ leading(p) use_nl(e) */
    e.employee_no, e.employee_name, e.position_code, p.base_salary, p.bonus
FROM page       p
    ,employee   e
WHERE e.employee_key = p.employee_key
ORDER BY p.base_salary DESC, p.bonus DESC, p.employee_key DESC
;

/*******************************************************************************
Plan hash value: 3176339326

---------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT               |                  |   666K|    41M|  4016K  (1)| 00:02:37 |
|   1 |  NESTED LOOPS                  |                  |   666K|    41M|  4016K  (1)| 00:02:37 |
|   2 |   NESTED LOOPS                 |                  |  2000K|    41M|  4016K  (1)| 00:02:37 |
|*  3 |    VIEW                        |                  |  2000K|    40M| 15513   (1)| 00:00:01 |
|*  4 |     WINDOW NOSORT STOPKEY      |                  |  5000K|    38M| 15513   (1)| 00:00:01 |
|*  5 |      INDEX FULL SCAN DESCENDING| SALARY_IX_SALARY |  5000K|    38M| 15513   (1)| 00:00:01 |
|*  6 |    INDEX UNIQUE SCAN           | EMPLOYEE_PK      |     1 |       |     1   (0)| 00:00:01 |
|   7 |   TABLE ACCESS BY INDEX ROWID  | EMPLOYEE         |     1 |    44 |     2   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("from$_subquery$_002"."rowlimit_$$_rownumber"<=2000000 AND
              "from$_subquery$_002"."rowlimit_$$_rownumber">1999980)
   4 - filter(ROW_NUMBER() OVER ( ORDER BY CASE  WHEN "END_DATE" IS NULL THEN
              "BASE_SALARY" END  DESC ,CASE  WHEN "END_DATE" IS NULL THEN "BONUS" END  DESC ,CASE  WHEN
              "END_DATE" IS NULL THEN "EMPLOYEE_KEY" END  DESC )<=2000000)
   5 - filter(CASE  WHEN "END_DATE" IS NULL THEN "EMPLOYEE_KEY" END  IS NOT NULL)
   6 - access("E"."EMPLOYEE_KEY"="from$_subquery$_002"."EMPLOYEE_KEY")
*******************************************************************************/

/*
 COUNT(*) OVER() 버전은 윈도우 함수가 전체 건수를 알아야하니,
 500만 건 전량을 조회해야하기 떄문에 STOP KEY 가 원천적으로 봉쇄된다.

 WHERE page_no = N OR (page_count < N AND page_count = page_no) 역시 같은 이유로
 전량 스캔을 강제한다.
 */
