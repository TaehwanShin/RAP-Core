# 이관 및 변경 내역

기준은 사용자가 제공한 `ZCL_PARAM_VALIDATOR` T100 리팩토링 버전과 `ZCX_APP_ERROR` v2입니다.
외부 저장소/원본 커밋은 제공되지 않았습니다. 서버에는 세 객체가 없어 새로 생성했습니다.

| 항목 | 최종 구현에서 변경된 동작 |
|---|---|
| `ensure` | false뿐 아니라 undefined 등 true가 아닌 조건도 위반 |
| `in_range` | 기존 초기값 생략을 유지. 선택 인자 `include_initial` 추가 |
| `has_errors` | 추가. `is_valid`와 반대 판정 |
| `to_text` | 변환 오류를 빈 메시지 변수로 숨기지 않음 |
| `merge` | 자기 병합도 유한하게 처리하도록 행 snapshot 사용 |
| 예외 생성자 | 빈 textid는 명시적으로 ZMC_APP 007 사용 |
| `wrap` | 기존 앱 예외에도 명시한 심각도 override 반영. 원본은 변경하지 않음 |
| `raise_wrapped` | severity 미지정과 명시적인 초기값을 구별 |
| T100 번호 | 000을 유효한 번호로 취급 |
| 외부 T100 변수 | 내부 공백을 condense하지 않음 |
| `get_symsg` | 비어 있지 않은 변수 우선 방식 대신 t100key의 attr 매핑을 해석 |
| BAPIRET | ID 없는 텍스트도 011로 처리. 빈 타입은 error로 판정 |
| `raise_if` | `cond = abap_true`일 때만 발생 |
| RAP 예제 | 경고만 있어도 reported에 전달. 실패 원인은 서버 상수 `cause-unspecific` 사용 |

ZMC_APP 001~011의 번호·의미를 보존했습니다. 최초 free-text Validator의 `get_messages()` API는
최종 기준 버전에 없으며 `get_violations()`와 `violation-error`로 전환해야 합니다.
최초 구상의 독립 severity 타입은 도입하지 않았고 사용자 제공 T100/RAP 메시지 계약을 유지했습니다.

순서: ZMC_APP → ZCX_APP_ERROR + 테스트 → ZCL_PARAM_VALIDATOR + 테스트 → 선택 RAP 예제.
검증 내역과 남은 제약은 [테스트 결과](../tests/test-results.md)를 참고하세요.
