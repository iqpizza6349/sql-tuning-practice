SELECT /*+ index_ffs(e) use_hash(s) index(s) */
    e.employee_key
FROM employee   e
    ,salary     s
WHERE (CASE WHEN s.end_date IS NULL THEN s.employee_key END) = e.employee_key
ORDER BY s.base_salary DESC, s.bonus DESC
OFFSET 2000 ROWS FETCH FIRST 20 ROWS ONLY
;

/*******************************************************************************
Plan hash value: 1558708919

--------------------------------------------------------------------------------------------------------------------
| Id  | Operation                              | Name              | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                       |                   |    21 |   567 |       | 90622   (1)| 00:00:04 |
|*  1 |  VIEW                                  |                   |    21 |   567 |       | 90622   (1)| 00:00:04 |
|*  2 |   WINDOW SORT PUSHED RANK              |                   |  5000K|    81M|   134M| 90622   (1)| 00:00:04 |
|*  3 |    HASH JOIN                           |                   |  5000K|    81M|    85M| 63120   (1)| 00:00:03 |
|   4 |     INDEX FAST FULL SCAN               | EMPLOYEE_PK       |  5000K|    28M|       |  3041   (1)| 00:00:01 |
|   5 |     TABLE ACCESS BY INDEX ROWID BATCHED| SALARY            |  5000K|    52M|       | 50347   (1)| 00:00:02 |
|*  6 |      INDEX FULL SCAN                   | SALARY_CURRENT_UK |  4906K|       |       | 10821   (1)| 00:00:01 |
--------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - filter("from$_subquery$_003"."rowlimit_$$_rownumber"<=21 AND
              "from$_subquery$_003"."rowlimit_$$_rownumber">1)
   2 - filter(ROW_NUMBER() OVER ( ORDER BY "S"."BASE_SALARY" DESC ,"S"."BONUS" DESC )<=21)
   3 - access("E"."EMPLOYEE_KEY"=CASE  WHEN ("END_DATE" IS NULL) THEN "EMPLOYEE_KEY" END )
   6 - filter(CASE  WHEN "END_DATE" IS NULL THEN "EMPLOYEE_KEY" END  IS NOT NULL)
*******************************************************************************/
