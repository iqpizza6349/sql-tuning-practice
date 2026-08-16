/******************************************************************************************
 MODIFIED_AT 인덱스가 없다는 점이 다소 부족하다고 판단되면 Index 를 추가한다.
 2.sql 은 `SORT ORDER BY STOPKEY` 로 5M 건을 모두 읽고선 Top-1 만 유지한다.

 실행계획 (이전)
PLAN_TABLE_OUTPUT                                                                               |
--------------------------------------------------------------------------------------------+
Plan hash value: 2093826826                                                                 |
                                                                                            |
--------------------------------------------------------------------------------------------|
| Id  | Operation               | Name     | Rows  | Bytes |TempSpc| Cost (%CPU)| Time     ||
--------------------------------------------------------------------------------------------|
|   0 | SELECT STATEMENT        |          |     1 |    48 |       | 85009   (1)| 00:00:04 ||
|*  1 |  COUNT STOPKEY          |          |       |       |       |            |          ||
|   2 |   VIEW                  |          |  5000K|   228M|       | 85009   (1)| 00:00:04 ||
|*  3 |    SORT ORDER BY STOPKEY|          |  5000K|   228M|   287M| 85009   (1)| 00:00:04 ||
|   4 |     TABLE ACCESS FULL   | EMPLOYEE |  5000K|   228M|       | 25453   (1)| 00:00:01 ||
--------------------------------------------------------------------------------------------|
                                                                                            |
Query Block Name / Object Alias (identified by operation id):                               |
-------------------------------------------------------------                               |
                                                                                            |
   1 - SEL$1                                                                                |
   2 - SEL$2 / "from$_subquery$_001"@"SEL$1"                                                |
   3 - SEL$2                                                                                |
   4 - SEL$2 / "E"@"SEL$2"                                                                  |
                                                                                            |
Predicate Information (identified by operation id):                                         |
---------------------------------------------------                                         |
                                                                                            |
   1 - filter(ROWNUM<=1)                                                                    |
   3 - filter(ROWNUM<=1)                                                                    |
                                                                                            |
Column Projection Information (identified by operation id):                                 |
-----------------------------------------------------------                                 |
                                                                                            |
   1 - "EMPLOYEE_KEY"[NUMBER,22], "EMPLOYEE_NO"[VARCHAR2,20],                               |
       "EMPLOYEE_NAME"[VARCHAR2,100], "MODIFIED_AT"[TIMESTAMP,11]                           |
   2 - "EMPLOYEE_KEY"[NUMBER,22], "EMPLOYEE_NO"[VARCHAR2,20],                               |
       "EMPLOYEE_NAME"[VARCHAR2,100], "MODIFIED_AT"[TIMESTAMP,11]                           |
   3 - (#keys=1) INTERNAL_FUNCTION("E"."MODIFIED_AT")[11],                                  |
       "E"."EMPLOYEE_KEY"[NUMBER,22], "E"."EMPLOYEE_NO"[VARCHAR2,20],                       |
       "E"."EMPLOYEE_NAME"[VARCHAR2,100]                                                    |
   4 - (rowset=256) "E"."EMPLOYEE_KEY"[NUMBER,22], "E"."EMPLOYEE_NO"[VARCHAR2,20],          |
       "E"."EMPLOYEE_NAME"[VARCHAR2,100], "E"."MODIFIED_AT"[TIMESTAMP,11]                   |


 Index 추가한 이후
PLAN_TABLE_OUTPUT                                                                               |
------------------------------------------------------------------------------------------------+
Plan hash value: 2853735442                                                                     |
                                                                                                |
------------------------------------------------------------------------------------------------|
| Id  | Operation                     | Name           | Rows  | Bytes | Cost (%CPU)| Time     ||
------------------------------------------------------------------------------------------------|
|   0 | SELECT STATEMENT              |                |     1 |    48 |     4   (0)| 00:00:01 ||
|*  1 |  COUNT STOPKEY                |                |       |       |            |          ||
|   2 |   VIEW                        |                |     1 |    48 |     4   (0)| 00:00:01 ||
|   3 |    TABLE ACCESS BY INDEX ROWID| EMPLOYEE       |  5000K|   228M|     4   (0)| 00:00:01 ||
|   4 |     INDEX FULL SCAN DESCENDING| EMPLOYEE_IX_01 |     1 |       |     3   (0)| 00:00:01 ||
------------------------------------------------------------------------------------------------|
                                                                                                |
Query Block Name / Object Alias (identified by operation id):                                   |
-------------------------------------------------------------                                   |
                                                                                                |
   1 - SEL$1                                                                                    |
   2 - SEL$2 / "from$_subquery$_001"@"SEL$1"                                                    |
   3 - SEL$2 / "E"@"SEL$2"                                                                      |
   4 - SEL$2 / "E"@"SEL$2"                                                                      |
                                                                                                |
Predicate Information (identified by operation id):                                             |
---------------------------------------------------                                             |
                                                                                                |
   1 - filter(ROWNUM<=1)                                                                        |
                                                                                                |
Column Projection Information (identified by operation id):                                     |
-----------------------------------------------------------                                     |
                                                                                                |
   1 - "EMPLOYEE_KEY"[NUMBER,22], "EMPLOYEE_NO"[VARCHAR2,20],                                   |
       "EMPLOYEE_NAME"[VARCHAR2,100], "MODIFIED_AT"[TIMESTAMP,11]                               |
   2 - "EMPLOYEE_KEY"[NUMBER,22], "EMPLOYEE_NO"[VARCHAR2,20],                                   |
       "EMPLOYEE_NAME"[VARCHAR2,100], "MODIFIED_AT"[TIMESTAMP,11]                               |
   3 - "E"."EMPLOYEE_KEY"[NUMBER,22], "E"."EMPLOYEE_NO"[VARCHAR2,20],                           |
       "E"."EMPLOYEE_NAME"[VARCHAR2,100], "E"."MODIFIED_AT"[TIMESTAMP,11]                       |
   4 - "E".ROWID[ROWID,10], "E"."MODIFIED_AT"[TIMESTAMP,11]                                     |

******************************************************************************************/
CREATE INDEX EMPLOYEE_IX_01
ON EMPLOYEE(MODIFIED_AT)
TABLESPACE TSD_COMPANY_IDX
;

SELECT EMPLOYEE_KEY, EMPLOYEE_NO, EMPLOYEE_NAME, MODIFIED_AT
FROM (
         SELECT e.EMPLOYEE_KEY, e.EMPLOYEE_NO, e.EMPLOYEE_NAME, e.MODIFIED_AT
         FROM EMPLOYEE e
         ORDER BY e.MODIFIED_AT DESC
     )
WHERE ROWNUM <= 1
;


