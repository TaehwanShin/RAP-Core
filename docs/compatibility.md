# 설치 및 호환성

| 항목 | 확인 결과 |
|---|---|
| 검증 ABAP 플랫폼 | On-premise, SAP_BASIS 758, S4CORE 108 |
| 언어 버전 | Standard ABAP |
| 공통 타입 | CX_STATIC_CHECK, CX_ROOT, IF_T100_MESSAGE, IF_T100_DYN_MSG, IF_ABAP_BEHV_MESSAGE, BAPIRET2_T |
| 개발 패키지 | ZRAP 아래 ZRAP_CORE |
| 서버 반영 | ARC-1/ADT로 9개 객체 생성·활성화 |
| 자동 테스트 | ABAP Unit 36/36 통과 |
| abapGit | `/src/`용 메타데이터 작성. import 재설치 미검증 |
| ABAP Cloud / 다른 릴리즈 | 미검증. released API 상태도 별도 확인 필요 |

## 공통 객체 설치

abapGit에서는 저장소를 선택한 개발 패키지에 연결하고 `/src/` 객체를 가져옵니다.
메타데이터는 abapGit CLAS/MSAG 형식을 따르지만 이번 서버 설치는 ARC-1을 사용했습니다.
ADT 수동 설치 시 ZMC_APP 카탈로그, 예외 클래스 main/testclasses, Validator main/testclasses 순으로
반영하고 활성화합니다. 기존 객체가 있으면 공개 API와 메시지 번호 충돌을 먼저 비교하세요.

실행: ADT에서 두 클래스 또는 패키지를 선택하고 **Run As → ABAP Unit Test**.
선택 예제 설치는 [examples](../examples/README.md)에 설명했습니다.
테스트 위험 수준은 HARMLESS이며 테스트 더블의 합성 데이터만 사용합니다.

RAP 예제는 non-strict unmanaged BDEF로, 서버가 strict 사용 권고 경고 1건을 냅니다.
권한·잠금·저장 기능을 생략한 검증 예제입니다. 실제 운영 BO에 적용할 때 해당 계약을 구현하세요.
공통 클래스와 EML 테스트 클래스 최종 활성화에는 오류가 없습니다.

## 참고

- [SAP ABAP Unit assertions](https://help.sap.com/docs/ABAP_PLATFORM_NEW/ba879a6e2ea04d9bb94c7ccd7cdac446/49268dc67b6716b4e10000000a42189d.html)
- [RAP action implementation contract](https://help.sap.com/docs/abap-cloud/abap-rap/implementation-contract-action)
- [abapGit MSAG serializer](https://github.com/abapGit/abapGit/blob/main/src/objects/zcl_abapgit_object_msag.clas.abap)
