#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.yml"

SERVICE="oracle"

# container 내부 경로
BOOTSTRAP_SQL="/workspace/table-definition/bootstrap.sql"
DDL_SQL="/workspace/table-definition/ddl.sql"

# 실습 스키마 계정
TUNING_USER="${TUNING_USER:-TUNING}"
TUNING_PASSWORD="${TUNING_PASSWORD:-tuning}"

compose() {
  docker compose -f "${COMPOSE_FILE}" "$@"
}

usage() {
  cat <<'EOF'
Usage:
  ./oracle.sh start       Oracle 시작
  ./oracle.sh stop        Oracle 정지
  ./oracle.sh restart     Oracle 재시작
  ./oracle.sh status      컨테이너 상태 확인
  ./oracle.sh logs        Oracle 로그 보기
  ./oracle.sh pull        Oracle 이미지 받기/갱신

  ./oracle.sh sys         FREEPDB1에 SYSDBA로 SQL*Plus 접속
  ./oracle.sh sql         FREEPDB1에 TUNING으로 SQL*Plus 접속

  ./oracle.sh bootstrap   bootstrap.sql 실행
                          - SYSDBA
                          - TABLESPACE / USER / GRANT 생성

  ./oracle.sh ddl         ddl.sql 실행
                          - TUNING
                          - TABLE / INDEX / SEQUENCE 생성

  ./oracle.sh init        bootstrap + ddl 순서대로 실행

  ./oracle.sh down        컨테이너 제거 (DB volume 유지)
  ./oracle.sh reset       컨테이너 + DB volume 완전 삭제

Environment:
  TUNING_USER             기본값: TUNING
  TUNING_PASSWORD         기본값: tuning
EOF
}

wait_until_ready() {
  printf "Oracle 기동 확인 중"

  for _ in $(seq 1 120); do
    if compose exec -T "${SERVICE}" bash -lc \
      'printf "SELECT 1 FROM DUAL;\nEXIT;\n" |
       sqlplus -L -s "system/${ORACLE_PWD}@//localhost:1521/FREEPDB1"' \
      >/dev/null 2>&1; then
      echo
      echo "Oracle ready."
      return 0
    fi

    printf "."
    sleep 2
  done

  echo
  echo "Oracle이 정상 상태가 되지 않았습니다. './oracle.sh logs'로 로그를 확인하세요." >&2
  return 1
}

start() {
  compose up -d
  wait_until_ready
}

run_bootstrap() {
  start

  # bootstrap.sql의 TABLESPACE datafile 경로용
  compose exec -T "${SERVICE}" mkdir -p /opt/oracle/oradata/NEXORA

  compose exec -T "${SERVICE}" bash -lc \
    'printf "WHENEVER SQLERROR EXIT SQL.SQLCODE\n@'"${BOOTSTRAP_SQL}"'\nEXIT\n" |
     sqlplus -L -s "sys/${ORACLE_PWD}@//localhost:1521/FREEPDB1 as sysdba"'
}

run_ddl() {
  start

  compose exec -T \
    -e TUNING_USER="${TUNING_USER}" \
    -e TUNING_PASSWORD="${TUNING_PASSWORD}" \
    "${SERVICE}" bash -lc \
    'printf "WHENEVER SQLERROR EXIT SQL.SQLCODE\n@'"${DDL_SQL}"'\nEXIT\n" |
     sqlplus -L -s "${TUNING_USER}/${TUNING_PASSWORD}@//localhost:1521/FREEPDB1"'
}

case "${1:-}" in
  start)
    start
    ;;

  stop)
    compose stop
    ;;

  restart)
    compose restart
    wait_until_ready
    ;;

  status)
    compose ps
    ;;

  logs)
    compose logs -f "${SERVICE}"
    ;;

  pull)
    compose pull
    ;;

  sys)
    start
    compose exec "${SERVICE}" bash -lc \
      'sqlplus "sys/${ORACLE_PWD}@//localhost:1521/FREEPDB1 as sysdba"'
    ;;

  sql)
    start
    compose exec \
      -e TUNING_USER="${TUNING_USER}" \
      -e TUNING_PASSWORD="${TUNING_PASSWORD}" \
      "${SERVICE}" bash -lc \
      'sqlplus "${TUNING_USER}/${TUNING_PASSWORD}@//localhost:1521/FREEPDB1"'
    ;;

  bootstrap)
    run_bootstrap
    ;;

  ddl)
    run_ddl
    ;;

  init)
    run_bootstrap
    run_ddl
    ;;

  down)
    compose down
    ;;

  reset)
    echo "주의: Oracle 컨테이너와 oracle-data volume의 모든 DB 데이터를 삭제합니다."
    read -r -p "계속하려면 'yes'를 입력하세요: " answer

    if [[ "${answer}" != "yes" ]]; then
      echo "취소했습니다."
      exit 0
    fi

    compose down -v
    ;;

  *)
    usage
    exit 1
    ;;
esac
