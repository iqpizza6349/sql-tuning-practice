## 04.Join Aggregate

### 1. 부서 인원수
> 각 부서별 재직자 수를 조회한다.

조회 칼럼:
* DEPARTMENT_KEY
* DEPARTMENT_NAME
* EMPLOYEE_COUNT

조건:
* 직원이 한 명도 없는 부서라 할 지라도 결과에 표시되어야한다.

### 2. 회사별 재직자 수
> 각 회사별 재직자 수를 조회한다.

조회 칼럼:
* COMPANY_KEY
* COMPANY_NAME
* EMPLOYEE_COUNT

### 3. 부서별 평균 급여
> 각 부서의 재직 중인 직원들의 현재 기본급 평균을 구한다.

조회 칼럼:
* DEPARTMENT_KEY
* DEPARTMENT_NAME
* EMPLOYEE_COUNT
* AVG_BASE_SALARY

### 4. 회사별 급여 비용
> 각 회사가 현재 부담하고 있는 연간 급여 비용을 구한다.\
> 급여 비용 = TOTAL_SALARY = BASE_SALARY + BONUS

조회 칼럼:
* COMPANY_KEY
* COMPANY_NAME
* EMPLOYEE_COUNT
* TOTAL_BASE_SALARY
* TOTAL_BONUS
* TOTAL_SALARY

### 5. 최고 연봉 직원 찾기
> 현재 급여 기준으로 `BASE_SALARY + BONUS`(=TOTAL_SALARY) 가 가장 높은 직원의 정보를 조회한다.

조회 칼럼:
* EMPLOYEE_KEY
* EMPLOYEE_NAME
* COMPANY_KEY
* POSITION_CODE
* BASE_SALARY
* BONUS
* TOTAL_SALARY

조건:
* 동률이 있을 수 있다고 가정한다.
  * EMPLOYEE_KEY 가 다르지만, TOTAL_SALARY 는 동일한 경우
