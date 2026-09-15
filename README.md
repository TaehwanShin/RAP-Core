# RAP-Core

SAP RAP 및 클래식 ABAP 호출자가 재사용하는 T100 기반 파라미터 검증·예외 처리 구성요소입니다.

## 구현

| 객체 | 역할 |
|---|---|
| `ZCL_PARAM_VALIDATOR` | fluent 규칙, 위반 수집, 오류 판정, BAPIRET 반환 |
| `ZCX_APP_ERROR` | T100 예외, 표준 예외 래핑, RAP `%msg`, SYMSG/BAPIRET 변환 |
| `ZMC_APP` | 원본 의미를 유지한 메시지 001~011 |

검증기는 BO·Handler·EML·트랜잭션에 의존하지 않습니다. 심각도와 메시지 객체에는
`IF_ABAP_BEHV_MESSAGE`를 사용하므로 RAP 타입에 대한 의존성은 있습니다.
경고·정보·성공 메시지는 반환하면서 오류만 흐름을 차단합니다.

```abap
DATA(v) = zcl_param_validator=>create(
  )->required( field = 'CustomerId' value = customer_id
  )->in_range( field = 'Amount' value = amount low = 1 high = 10000
                include_initial = abap_true ).
DATA(messages) = v->get_bapiret( ).
v->raise_if_invalid( ). " Caller declares RAISING or catches ZCX_APP_ERROR
```

## 구조와 시작점

- [src/](src/README.md): 공통 객체와 로컬 ABAP Unit include, abapGit 메타데이터
- [examples/](examples/README.md): 실제 활성화·EML 검증을 마친 unmanaged static action 예제
- [공개 API](docs/public-api.md), [마이그레이션](docs/migration.md), [설계](docs/architecture.md)
- [설치·호환성](docs/compatibility.md), [테스트 결과](tests/test-results.md)

## 검증 상태

ABAP 7.58 서버 `ZRAP_CORE`에 업로드·활성화했으며, 2026-09-16(KST) 패키지
ABAP Unit **36/36 통과**: Validator 16, 예외 16, RAP EML 4.
Git 소스는 서버의 활성 버전을 다시 읽어 반영했습니다.
abapGit 재설치와 Fiori UI의 파라미터 팝업 필드 강조는 검증하지 않았습니다.

공개 가능한 코드와 합성 테스트 데이터만 관리합니다. 라이선스는 아직 미지정입니다.
