## 06.Pagination

### 1. 직원 목록 첫 페이지
> 첫 페이지를 조회한다.

조회 칼럼:
* DEPARTMENT_NAME
* DESCRIPTION
* EMPLOYEE_NO
* EMPLOYEE_NAME
* POSITION_CODE
* HIRE_DATE

조건:
* COMPANY_KEY = 20
* EMPLOYEE.STATUS = 'ACTIVE'

정렬:
* EMPLOYEE_KEY ASC

페이지 크기:
* 50 건

### 2. 직원 목록 11번째 페이지
> 앞선 1번 쿼리에 대해서 11번째 페이지를 조회한다.
> 즉, 첫 500 건을 무시하고 다음 50건을 조회한다.

### 3. 급여 높은 순 페이지네이션
> 현재 급여 기준:
> ```sql
> BASE_SALARY DESC + BONUS DESC
> ```
> 으로 직원을 정렬하고 페이지당 20건씩 제공한다.
> 101번째 페이지를 조회한다.

조건:
* OFFSET 을 사용하여 구현한다.

### 4. 10만 번째 페이지
> 3번과 유사하되, 다양한 접근 방식을 통해 쿼리를 개선하여 10만 번째 페이지를 가능한 빠르고 효율적이게 조회한다.

확인 내용:
* Buffers
* A-Rows
* E-Rows
* 실행 계획
