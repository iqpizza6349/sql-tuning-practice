SELECT
    c.company_key
,   c.company_name
,   x.employee_key
,   x.employee_name
,   x.hire_date
FROM (
    SELECT
        e.company_key
    ,   e.employee_key
    ,   e.employee_name
    ,   e.hire_date
    ,   ROW_NUMBER() OVER(PARTITION BY e.company_key ORDER BY e.hire_date DESC, e.employee_key DESC) AS rn
    FROM employee e
) x
, company c
where x.rn <= 10
  AND c.company_key = x.company_key
ORDER BY c.company_key, x.hire_date DESC, x.employee_key DESC
;

/*******************************************************************************
Plan hash value: 3514474500

-----------------------------------------------------------------------------------------------
| Id  | Operation                  | Name     | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT           |          | 10000 |   634K|       | 71961   (1)| 00:00:03 |
|   1 |  SORT ORDER BY             |          | 10000 |   634K|   800K| 71961   (1)| 00:00:03 |
|*  2 |   HASH JOIN                |          | 10000 |   634K|       | 71803   (1)| 00:00:03 |
|   3 |    TABLE ACCESS FULL       | COMPANY  |  1000 | 17000 |       |     8   (0)| 00:00:01 |
|*  4 |    VIEW                    |          | 10000 |   468K|       | 71795   (1)| 00:00:03 |
|*  5 |     WINDOW SORT PUSHED RANK|          |  5000K|   166M|   229M| 71795   (1)| 00:00:03 |
|   6 |      TABLE ACCESS FULL     | EMPLOYEE |  5000K|   166M|       | 25454   (1)| 00:00:01 |
-----------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - access("C"."COMPANY_KEY"="X"."COMPANY_KEY")
   4 - filter("X"."RN"<=10)
   5 - filter(ROW_NUMBER() OVER ( PARTITION BY "E"."COMPANY_KEY" ORDER BY
              "E"."HIRE_DATE" DESC ,"E"."EMPLOYEE_KEY" DESC )<=10)
*******************************************************************************/

/*
 약간 당황스러웠던 점은 SORT ORDER BY 였지만, 이내 Hash Join 이라서 그렇다는 것을 눈치챘다.
 여기서 ordered use_nl(c) 를 주어 실행계획을 고정함과 동시에 Nested Loops 을 통해 SORT ORDER BY
 Operator 를 없앨 수는 있다.

 하지만 정렬 비용은 분명히 비싼 것은 맞지만, 어차피 집계형에 더 가까운 이 요구사항(쿼리)은
 Hash 방식이 더 적절하다고 생각된다.

 이유는 다음과 같다.
 1) 실행계획은 WINDOW SORT PUSHED RANK 방식을 사용하고 있다.
 2) 정렬을 하지만, 파티션당 상위 10건만 메모리(PGA 혹은 TempSpc)에 유지하는 bounded sort 이다.
 3) 즉, Nested Loops 와 유사할 수 있겠으나 장기적으로 보았을 때 Company 수 가 늘어날 수록 NL 보다 우세해진다.
 */

/*******************************************************************************
Plan hash value: 1164577330

---------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name       | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |            | 10000 |   634K|       | 81797   (1)| 00:00:04 |
|   1 |  NESTED LOOPS                |            | 10000 |   634K|       | 81797   (1)| 00:00:04 |
|   2 |   NESTED LOOPS               |            | 10000 |   634K|       | 81797   (1)| 00:00:04 |
|*  3 |    VIEW                      |            | 10000 |   468K|       | 71795   (1)| 00:00:03 |
|*  4 |     WINDOW SORT PUSHED RANK  |            |  5000K|   166M|   229M| 71795   (1)| 00:00:03 |
|   5 |      TABLE ACCESS FULL       | EMPLOYEE   |  5000K|   166M|       | 25454   (1)| 00:00:01 |
|*  6 |    INDEX UNIQUE SCAN         | COMPANY_PK |     1 |       |       |     0   (0)| 00:00:01 |
|   7 |   TABLE ACCESS BY INDEX ROWID| COMPANY    |     1 |    17 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - filter("X"."RN"<=10)
   4 - filter(ROW_NUMBER() OVER ( PARTITION BY "E"."COMPANY_KEY" ORDER BY "E"."HIRE_DATE"
              DESC ,"E"."EMPLOYEE_KEY" DESC )<=10)
   6 - access("C"."COMPANY_KEY"="X"."COMPANY_KEY")
*******************************************************************************/
