# SqlTuningPractice

해당 프로젝트는 Oracle DBMS 에서 SQL 을 튜닝하는 방법에 대해 공부하고 실습하는 공간입니다.

# 파일들

- `./docker`
  - `docker-compose.yml`: docker 파일
  - `oracle.sh`: oracle 접속이나 docker 명령을 쉽게 사용하기 위한 shell
- `./table-definition`
  - `bootstrap.sql`: 최초 Oracle 접속 시 하는 것을 권장합니다. Tablespace 와 User 가 정의되어 있습니다.
  - `ddl.sql`: 테이블과 인덱스, 그리고 Sequence 를 처음부터 다시 만들 때 사용합니다.

# 환경 구축

> 환경은 Oracle Free 입니다. Free 는 최대 12GB 까지만 지원되며,
> 현재 기준으로 최대 11GB 정도 차지하도록 설정되어 있습니다. 

## 처음하는 경우
```shell
chmod +x docker/oracle.sh
```

## 그다음부터 사용하는 경우
### Oracle 시작
```shell
./docker/oracle.sh start
```

### 상태
```shell
./docker/oracle.sh status
```

### Tablespace + User + Grant
```shell
./docker/oracle.sh bootstrap
```

### Table/Index/Sequence 생성
```shell
./docker/oracle.sh ddl
```

### 모두 초기화
```shell
./docker/oracle.sh init
```

### SQL*Plus 일반 접속
```shell
./docker/oracle.sh sql
```

### SYSDBA 접속
```shell
./docker/oracle.sh sys
```

### 로그
```shell
./docker/oracle.sh logs
```

### Oracle 정지
```shell
./docker/oracle.sh stop
```

### 컨테이너를 완전히 없애는 방법
```shell
./docker/oracle.sh down
```

### 아예 처음부터 다시 실습하고 싶은 경우
```shell
./docker/oracle.sh reset
```
