## 03.Join

### 1. 직원 + 부서
> 다음 정보를 보여준다.

조회 칼럼:
* EMPLOYEE_NO
* EMPLOYEE_NAME
* EMPLOYEE_CODE
* DEPARTMENT_ID
* DEPARTMENT_NAME

조건:
* `DEPARTMENT` 와 `EMPLOYEE` 를 조인한다.
* `EMPLOYEE_KEY = 100000` 조건 사용 

### 2. 직원 + 회사 + 부서
> 다음 정보를 보여준다.

조회 칼럼:
* COMPANY_NAME
* DEPARTMENT_NAME
* EMPLOYEE_NO
* EMPLOYEE_NAME
* POSITION_CODE

### 3. 직원 + 현재 급여
> 현재 재직 직원에게 다음 정보를 보여주는 직원 목록을 조회한다.

조회 칼럼:
* EMPLOYEE_NO
* EMPLOYEE_NAME
* POSITION_CODE
* BASE_SALARY
* BONUS
* TOTAL_SALARY (BASE_SALARY + BONUS)

조건:
* EMPLOYEE 와 SALARY 를 조인하되, 현재 급여만 조회한다.

### 4. 특정 부서의 직원과 급여
> `DEPARTMENT_KEY = 500` 인 부서에서 일하는 모든 재직자의 현재 급여를 조회한다.

조회 칼럼:
* EMPLOYEE_KEY
* EMPLOYEE_NAME
* POSITION_CODE
* BASE_SALARY
* BONUS
