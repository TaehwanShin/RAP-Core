# 공개 API 계약

## ZCL_PARAM_VALIDATOR

`create()`는 매번 독립 인스턴스를 생성합니다. 규칙 메서드와 `add_error`, `merge`는
같은 인스턴스를 반환하며 호출 순서대로 위반을 누적합니다. 자동 초기화·중복 제거는 없습니다.

| 메서드 | 계약 |
|---|---|
| `required` | ABAP `IS INITIAL`이면 001. 숫자 0, 초기 날짜도 누락으로 처리 |
| `required_if` | `cond = abap_true`일 때 `required` 수행 |
| `ensure` | `that <> abap_true`이면 지정한 T100 메시지. undefined도 실패 |
| `one_of` | 비교 가능한 elementary 행에서 일치값 검색. 없거나 빈 집합이면 008 |
| `in_range` | low/high 포함 범위. 초기값은 기본 생략. `include_initial = abap_true`로 0도 검사 |
| `max_length` | `strlen(value) > max`이면 010. CHAR 끝 공백과 STRING 끝 공백의 의미는 ABAP에 따름 |
| `add_error` | bound 예외를 동일 참조로 추가. unbound는 무시 |
| `merge` | 상대 위반 행의 snapshot을 순서대로 추가. unbound 무시. 자기 병합은 행을 한 번 복제 |
| `get_violations` | `field`(대문자 string), `error`(ZCX_APP_ERROR 참조) 테이블 복사 |
| `get_texts` / `get_bapiret` | 모든 심각도를 원래 순서대로 반환 |
| `has_messages` | 위반 행이 하나라도 있으면 참 |
| `has_errors` / `is_valid` | severity-error 존재 여부 / 그 반대 |
| `raise_if_invalid` | 첫 오류 객체를 그대로 raise. 앞선 경고는 건너뜀 |

`label`이 비면 기술 필드명을 메시지 변수로 사용합니다. 기본 T100 키와 심각도는
호출부에서 재정의할 수 있습니다. `ensure`는 textid를 필수로 받습니다.
필드명은 소비자에 전달할 식별자이며 그 필드의 존재를 Validator가 검사하지 않습니다.

호출자는 `low <= high`, `max >= 0`, 비교 가능한 elementary 값과 허용 심각도를 제공해야 합니다.
구조·테이블 값의 문자열화와 타입 불일치는 지원 계약 밖이며 실행 오류를 업무 위반으로 숨기지 않습니다.
`one_of`는 ABAP 비교/형변환 규칙을 따릅니다. 도메인 엄격 일치가 필요하면 같은 타입으로 전달하세요.
`in_range`는 날짜의 달력 유효성 검사기가 아닙니다.
반환 테이블은 복사되지만 예외 객체는 공유됩니다. 외부에서 인터페이스의 심각도를 변경하면 판정도 달라집니다.

## ZCX_APP_ERROR

- `CX_STATIC_CHECK` 상속. T100 및 RAP 메시지 인터페이스 구현.
- `constructor`의 textid 기본값은 `unexpected`(007). v1~v4, previous, severity를 보유합니다.
- `raise`는 항상, `raise_if`는 cond가 참일 때 예외를 발생시킵니다.
- `wrap`은 발생시키지 않고 메시지 객체를 반환합니다. 원래 예외는 previous로 보존합니다.
- 이미 ZCX_APP_ERROR이고 심각도 변경이 없으면 동일 객체를 반환합니다. 명시적인 심각도 변경은
  기존 객체를 수정하지 않고 새 객체를 만들어 원본을 previous로 연결합니다.
- T100 예외의 메시지 ID/번호(000 포함)를 보존하고 공개 속성값을 MV_V1~4로 다시 연결합니다.
  찾을 수 없는 속성이나 문자열 변환에 실패한 속성은 빈 값으로 남습니다.
- T100 없는 예외는 011에 50자 × 4개를 담습니다. 200자를 넘는 원문은 previous에 남습니다.
- 심각도 미지정 시 RAP 인터페이스 → 동적 메시지 타입 → error 순으로 결정합니다.
  `raise_wrapped`도 선택 인자가 미지정인 상태를 유지합니다.
- `raise_from_sy`는 subrc가 0이면 아무것도 하지 않습니다. 메시지 ID가 없으면 007로 반환합니다.
  레거시 호출 직후 subrc를 전달하세요. 메서드 호출이 무조건 SY-SUBRC를 초기화한다는 전제는 사용하지 않습니다.
- `raise_from_bapiret`는 한 행을 항상 예외로 바꿉니다. E/A/X는 error, W/S/I는 대응 심각도,
  빈/알 수 없는 타입은 error로 판정합니다. 메시지 ID가 없으면 MESSAGE 텍스트를 011로 운반합니다.
- `raise_if_bapiret_error`는 첫 E/A/X만 발생시킵니다.
- `get_symsg`는 T100 키가 지정하는 실제 속성을 읽으므로 `RAISE ... MESSAGE`의 MSGV도 지원합니다.
  동적 MSGTY가 있으면 이를 보존합니다. `get_bapiret`는 그 결과와 현재 언어의 텍스트를 반환합니다.

`RAISE EXCEPTION TYPE ... MESSAGE w...`처럼 동적 경고를 직접 발생시키는 호출자는
`EXPORTING severity = if_abap_behv_message=>severity-warning`도 지정해야 합니다.
생성자의 기본 심각도는 error이며 ABAP이 나중에 채우는 MSGTY와 자동 동기화되지 않습니다.

SYMSG/BAPIRET2 메시지 변수는 50자여서 긴 문자열은 잘릴 수 있습니다. BAPIRET2의 PARAMETER,
ROW, FIELD, SYSTEM, LOG_NO 등 부가 메타데이터는 현재 보존 대상이 아닙니다.
011은 외부 예외 텍스트를 운반할 뿐 이를 자동 번역하지 않으며 T100 렌더링의 공백 처리도 적용됩니다.
현재 카탈로그는 원본 언어 E에 사용자 제공 한국어 문구를 저장했습니다. 별도 언어 번역은 미작성입니다.

## RAP 및 트랜잭션 경계

위반은 raise 없이 수집하고 `%msg = violation-error`로 직접 전달합니다.
reported는 심각도와 무관하게 채우고 failed만 `has_errors()`로 결정합니다.
실행 장애는 필요한 경계에서 catch 후 wrap하며 성공으로 간주하지 않습니다.
어느 공통 클래스도 DB 저장·COMMIT·ROLLBACK·로그 기록을 실행하지 않습니다.
