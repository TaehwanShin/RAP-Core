# 인수 조건과 검증 연결

| 인수 조건 | ABAP Unit 검증 |
|---|---|
| 필수값과 조건부 필수 | required_label_and_key, required_initial_types, required_if_branches |
| 자유 조건·T100 변수 | ensure_bool_and_variables |
| 허용값과 빈 집합 | one_of_found_missing_empty, one_of_numeric_hashed |
| 경계값·0·날짜 | range_boundaries, range_initial_opt_in, range_dates |
| 문자열 길이/공백 | length_boundary_and_spaces |
| 경고·정보·성공은 통과 | non_errors_do_not_block, warning_only |
| 첫 error만 발생·참조 보존 | raise_first_error_identity, add_error_unbound_and_chain |
| 행 병합·자기 병합·테이블 복사 | merge_snapshot_and_self |
| T100 키와 변수/공백 | wrap_foreign_attributes, wrap_message_zero, dynamic_message_roundtrip |
| 표준 예외와 원인 체인 | wrap_text_chunks, wrap_existing_and_override |
| 선택 심각도 유지 | raise_wrapped_default_severity, raise_wrapped_override |
| SYMSG/BAPIRET | sy_message_and_zero_subrc, bapiret_types_and_variables, bapiret_first_error |
| 한국어 T100 렌더링 | korean_t100_text |
| 실제 RAP EML 다건 분리 | mixed_requests, invalid_amount_and_currency |

실행 결과: [36/36 통과](test-results.md). ABAP Cloud, 번역 언어 전환, abapGit 재설치,
OData/Fiori 팝업 강조, 실제 unmanaged 저장 트랜잭션은 이 검증에 포함되지 않습니다.
