SELECT
    *
FROM (
     SELECT
        CEIL(ROWNUM / 50) AS page_no
     ,   CEIL((COUNT(*) OVER()) / 50) AS page_count
     ,   COUNT(*) OVER() AS row_count
     ,   MS.*
     FROM (
          SELECT /*+ ordered index(d) */
              d.department_name
          ,   d.description
          ,   e.employee_no
          ,   e.employee_name
          ,   e.position_code
          ,   e.hire_date
          FROM employee   e
              ,department d
          WHERE e.company_key = 20
            AND e.status      = 'ACTIVE'
            AND d.department_key = e.department_key
          ORDER BY e.employee_key ASC
     ) MS
 ) SQ
WHERE page_no = 1
   OR (page_count < 1 AND page_count = page_no)
;

/*******************************************************************************
Plan hash value: 3919920674

-------------------------------------------------------------------------------------------------------------------
| Id  | Operation                                 | Name          | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                          |               | 23585 |    13M|       | 12201   (1)| 00:00:01 |
|*  1 |  VIEW                                     |               | 23585 |    13M|       | 12201   (1)| 00:00:01 |
|   2 |   WINDOW BUFFER                           |               | 23585 |    13M|       | 12201   (1)| 00:00:01 |
|   3 |    COUNT                                  |               |       |       |       |            |          |
|   4 |     VIEW                                  |               | 23585 |    13M|       | 12201   (1)| 00:00:01 |
|   5 |      SORT ORDER BY                        |               | 23585 |  2994K|  3264K| 12201   (1)| 00:00:01 |
|*  6 |       HASH JOIN                           |               | 23585 |  2994K|  1872K| 11517   (1)| 00:00:01 |
|*  7 |        TABLE ACCESS BY INDEX ROWID BATCHED| EMPLOYEE      | 23585 |  1589K|       |  9910   (1)| 00:00:01 |
|*  8 |         INDEX RANGE SCAN                  | EMPLOYEE_UK   | 25636 |       |       |    99   (0)| 00:00:01 |
|   9 |        TABLE ACCESS BY INDEX ROWID BATCHED| DEPARTMENT    |   100K|  5957K|       |  1169   (1)| 00:00:01 |
|  10 |         INDEX FULL SCAN                   | DEPARTMENT_PK |   100K|       |       |   210   (1)| 00:00:01 |
-------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("PAGE_NO"=1 OR "PAGE_COUNT"<1 AND "PAGE_COUNT"="PAGE_NO")
   6 - access("D"."DEPARTMENT_KEY"="E"."DEPARTMENT_KEY")
   7 - filter("E"."STATUS"='ACTIVE')
   8 - access("E"."COMPANY_KEY"=20)
*******************************************************************************/
