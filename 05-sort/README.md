## 05.Sort

### 1. 급여가 높은 직원 순서
> 현재 재직자의 현재 급여률:
> ```text
> TOTAL_SALARY = BASE_SALARY + BONUS
> ```
> 가 높은 순서대로 정렬한다.

동일한 경우:
* `BASE_SALARY` 가 높은 직원
* `EMPLOYEE_KEY` 가 작은 직원

순으로 정렬한다.

### 2. 입사일 순 직원 목록
> 특정 회사 (COMPANY_KEY = 20) 의 재직자를 다음 기준으로 정렬한다.

정렬 조건:
* 입사일이 빠른 순
* 입사일이 같으면 EMPLOYEE_KEY 순

### 3. 부서 규모 TOP 3
> 임의의 회사(COMPANY_KEY = 300)의 재직자 수가 가장 많은 부서 3개를 조회한다.
> 해당 회사에 부서가 3개가 되지 않을 수 있겠으나, 최대 3행까지만 출력되어야한다.

정렬 조건:
* DEPARTMENT_KEY
* DEPARTMENT_NAME
* EMPLOYEE_COUNT

### 4. 평균 급여 TOP 10 부서
> 전체 회사에서 현재 직원이 20명 이상인 부서만 대상으로 평균 기본급이 가장 높은 부서 10개를 조회한다.

조회 칼럼:
* COMPANY_NAME
* DEPARTMENT_NAME
* EMPLOYEE_COUNT
* AVG_BASE_SALARY
