## 00.Simple

### 1. 사원 단건 조회
> `EMPLOYEE_KEY = 125000` 에 해당하는 직원의 다음 정보를 조회한다.

* EMPLOYEE_KEY
* EMPLOYEE_NO
* EMPLOYEE_NAME
* POSITION_CODE
* HIRE_DATE
* STATUS

조건:
* 결과는 최대 1건 이어야한다.
* 정렬은 하지 않는다.

### 2. 사번으로 직원 조회
> 회사 키(`COMPANY_KEY`) 가 10 이고, 사번이 E000000012345 인 직원 정보를 조회한다.

조건:
```sql
COMPANY_KEY = 10
EMPLOYEE_NO = 'E000000012345'
```
결과는 최대 1건 이어야한다. (seed 값에 따라 0건이 조회될 수도 있다.)

### 3. 사업자 번호로 회사 조회
> BUSINESS_NUMBER 를 입력 받아 회사 한 건을 조회하는 SQL 을 작성한다.

조회 칼럼:
* COMPANY_KEY
* COMPANY_NAME
* BUSINESS_NUMBER
* STATUS
* NATION_CODE

조건:
* 결과는 항상 0 또는 1 건 이어야한다.

### 4. 재직 중 직원 조회
> 다음 조건을 모두 만족하는 직원을 조회한다. 단, 정렬은 하지 않는다.

조건:
```sql
COMPANY_KEY = 100
STATUS = 'ACTIVE'
POSITION_CODE = 'MANAGER'
```

### 5. 특정 기간 입사자
> 2018년 1월 1일 이상, 2019년 1월 1일 미만에 입사한 직원을 조회한다.

> NOTICE: 가능한, HIRE_DATE 칼럼에 함수를 적용하지 않은 형태로 작성하는 노력을 한다.
