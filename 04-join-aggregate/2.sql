SELECT
    c.company_key
,   c.company_name
,   COUNT(e.employee_key) AS cnt_company_employee
FROM COMPANY    c
    ,EMPLOYEE   e
WHERE e.company_key (+)= c.company_key
  AND e.STATUS      (+)= 'ACTIVE'
GROUP BY c.company_key, c.company_name
;

/*******************************************************************************
Plan hash value: 2530787473

---------------------------------------------------------------------------------
| Id  | Operation            | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------
|   0 | SELECT STATEMENT     |          |  1000 | 34000 | 25595   (1)| 00:00:01 |
|*  1 |  HASH JOIN OUTER     |          |  1000 | 34000 | 25595   (1)| 00:00:01 |
|   2 |   TABLE ACCESS FULL  | COMPANY  |  1000 | 17000 |     8   (0)| 00:00:01 |
|   3 |   VIEW               | VW_GBC_5 |  1000 | 17000 | 25587   (1)| 00:00:01 |
|   4 |    HASH GROUP BY     |          |  1000 | 12000 | 25587   (1)| 00:00:01 |
|*  5 |     TABLE ACCESS FULL| EMPLOYEE |  4600K|    52M| 25476   (1)| 00:00:01 |

Predicate Information (identified by operation id):
---------------------------------------------------

   1 - access("ITEM_1"(+)="C"."COMPANY_KEY")
   5 - filter("E"."STATUS"(+)='ACTIVE')
*******************************************************************************/
