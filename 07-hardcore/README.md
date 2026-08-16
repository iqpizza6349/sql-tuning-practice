## 07.HardCore

### 1. 직원 검색
> 다음 검색 조건이 있는 데, 모든 조건이 존재한다고 가정하고 조회한다.

검색 조건:
* COMPANY_KEY
* DEPARTMENT_KEY
* POSITION_CODE
* STATUS
* HIRE_DATE

정렬:
* EMPLOYEE_KEY DESC

페이지 크기:
* 50건

### 2. 직원 급여 상세 조회
> EMPLOYEE_KEY 를 하나 받아 다음을 조회한다.

조회 칼럼:
* COMPANY_NAME
* DEPARTMENT_NAME
* EMPLOYEE_NO
* EMPLOYEE_NAME
* HIRE_DATE
* BASE_SALARY
* BONUS
* TOTAL_SALARY (BASE_SALARY + BONUS)

급여 이력:
* START_DATE
* END_DATE
* BASE_SALARY
* BONUS

급여 이력은 최신순으로 정렬한다.

현재 정보 조회 SQL + 급여 이력 목록 SQL 로 두 개로 나누어 작성한다.

### 3. 최근 연봉 인상자 10명 조회
> 급여 이력이 2건 이상 있는 직원 중에서
> 직접 급여보다 현재 BASE_SALARY 가 오른 직원
> 을 찾는다.

정렬:
* 현재 급여의 시작일이 가장 최근순

조회 칼럼:
* EMPLOYEE_KEY
* EMPLOYEE_NAME
* PREVIOUS_SALARY
* CURRENT_SALARY
* INCREASE_AMOUNT
* START_DATE

### 4. 회사별 최근 입사자 10명
> 각 회사마다 최근 입사한 직원 10명씩 조회한다.
> 
> 예를 들어 회사가 1,000 개라면 최대 10,000 건이 될 수 있다.

조회 칼럼:
* COMPANY_KEY
* COMPANY_NAME
* EMPLOYEE_KEY
* EMPLOYEE_NAME
* HIRE_DATE

> NOTICE: 전체 직원 중 최신 10명이 아닌 회사마다 각각 10명이다.

### 5. NULL/NOT NULL 필터
> 1번 쿼리에서 `COMPANY_KEY` 와 `DEPARTMENT_KEY` 조건만 필수요소고,
> 그 외에는 전부 사용자가 입력하지 않아도 되는 옵션이다.
> 즉, binding 변수에는 NULL 이 입력된다.\
> 이때, 조회 성능이 가장 튀지 않고 실행 계획에 영향을 최소화하여 작성한다.

