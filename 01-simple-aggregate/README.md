## 01.Simple-Aggregate

### 1. 최고 기본급
> 전체 급여 이력 중 가장 높은 `BASE_SALARY` 를 구한다.

### 2. 최저·최고·평균 급여
> 현재 급여만 대상으로 다음을 한 행으로 조회한다.

조회 칼럼:
* MIN_BASE_SALARY
* MAX_BASE_SALARY
* AVG_BASE_SALARY

현재 급여의 정의:
```sql
END_DATE IS NULL
```

### 3. 실질 지급 예정액
> 현재 급여에 대해 `BASE_SALARY + BONUS` 를 `TOTAL_SALARY` 라는 이름으로 조회한다.

조회 칼럼:
* EMPLOYEE_KEY
* BASE_SALARY
* BOUNS
* TOTAL_SALARY

### 4. 가장 높은 총 급여액
> 현재 급여 중 `BASE_SALARY + BONUS` 가 가장 높은 금액 하나만 구한다.

### 5. 현재 지급해야하는 전체 금여
> 현재 급여 데이터 전체에 대해서 `BASE_SALARY + BONUS` 의 합계를 구한다.\
> 즉, 지금 모든 직원에게 연봉을 지급한다고 가정하였을 총 지급액은 얼마인가를 구한다.

### 6. 보너스 지급 대상 총액
> 현재 급여 중 `BONUS > 0` 인 행만 대상으로 다음 조회 칼럼들을 모두 조회한다.

조회 칼럼:
* 직원 수
* BASE_SALARY 합계
* BONUS 합계
* BASE_SALARY + BONUS 합계
