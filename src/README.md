# 공통 ABAP 객체

`ZMC_APP` → `ZCX_APP_ERROR` → `ZCL_PARAM_VALIDATOR` 순으로 설치·활성화합니다.
클래스별 `.clas.testclasses.abap`는 해당 클래스의 Local Test Classes include입니다.
예외 클래스의 `##ADT_SUPPRESS_GENERATION`은 서버가 보존한 생성자 pragma입니다.

루트 `.abapgit.xml`은 `/src/`만 설치 대상으로 설정합니다. 클래스 및 메시지 XML은
abapGit 형식으로 작성했으며 소스는 실제 SAP 활성 버전과 일치합니다.
이번 설치는 ARC-1/ADT로 수행했으며 abapGit import 자체는 아직 검증하지 않았습니다.
예제는 [별도 설치 순서](../examples/README.md)를 따릅니다.
