SELECT
    c.COMPANY_KEY, c.COMPANY_NAME, c.BUSINESS_NUMBER, c.STATUS, c.NATION_CODE
FROM COMPANY c
WHERE c.BUSINESS_NUMBER = TO_CHAR(:bNo)
;

/******************************************************************************************
  COMPANY.BUSINESS_NUMBER 는 CHAR(10), 즉 Char 타입임을 잊지 말자.
  일반 숫자가 들어오게 되면 적어도 Oracle 에서는 숫자형이 이기게 된다.

  물론 자동으로 TO_CHAR(:binding) 이 되는 경우도 존재하겠으나, 그렇지 않다면 TABLE ACCESS FULL 이 된다.
  불행 중 다행으로 COMPANY 는 데이터가 그리 많은 편이 아닌 탓에 TABLE ACCESS FULL 을 하더라도 빠르게 조회될 것이다.
******************************************************************************************/
