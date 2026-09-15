# 최소 RAP 사용 예제

`rap/`에는 서버에서 활성화하고 EML로 검증한 **unmanaged static action `validateOrder`**가 있습니다.
원래 createSalesOrders의 검증·메시지 배선만 독립적으로 실행할 수 있도록 이름을 정했습니다.
주문 생성·채번·저장·결과 $self 반환은 구현하지 않습니다. 공통 클래스를 복제하지 않습니다.

## 객체 설치 순서

공통 `src/` 객체를 먼저 설치한 후 아래 순서로 ADT에서 생성합니다. 모두 검증 서버에서는
ZRAP_CORE에 있습니다. `examples/`는 루트 abapGit import의 설치 대상이 아닙니다.
파일은 ADT 소스이며 전체 예제의 abapGit 직렬화 패키지는 아닙니다.

1. `ZRC_ORDER_DEMO` — `.tabl.asddl`의 테이블 DDL, root view용 빈 저장소
2. `ZA_CREATEORDERSPARAM` — Abstract Entity `.ddls.asddls`
3. `ZI_RC_ORDER_DEMO` — root view `.ddls.asddls`
4. 같은 이름의 BDEF `.bdef.asbdef`와 `ZBP_I_RC_ORDER_DEMO` behavior pool을 함께 활성화
5. behavior pool `.clas.locals_imp.abap`를 Local Types/implementations include에 반영
6. `ZCL_RC_VALIDATION_DEMO`와 `.clas.testclasses.abap`를 반영하고 ABAP Unit 실행

## 실행 예

```abap
MODIFY ENTITIES OF zi_rc_order_demo
  ENTITY SalesOrder EXECUTE validateOrder FROM VALUE #(
    ( %cid = 'OK' %param = VALUE #( CustomerId = 'C001' OrderType = 'OR'
      Amount = 100 Currency = 'KRW' RequestedDate = '99991231' ) ) )
  FAILED DATA(failed) REPORTED DATA(reported).
```

정상: failed/reported가 비어 있습니다. CustomerId를 비우면 001과 해당 `%cid`의 failed가 생깁니다.
CustomerId가 5자를 넘으면 예제용 길이 경고만 반환하고 실패하지 않습니다.
RequestedDate는 선택 항목이며 초기값을 생략합니다. 입력된 날짜만 현재 날짜 이상인지 검사합니다.
날짜 형식의 유효성 자체는 범위 검사와 별도입니다.

`lcl_order_rules`는 입력과 기준 날짜를 받고 규칙을 구성합니다. Handler는 위반을 항상 reported로,
error가 있는 요청만 failed로 매핑합니다. `%msg`에는 `ZCX_APP_ERROR`를 직접 넣습니다.
`%element`는 BO 속성용입니다. 같은 이름의 액션 파라미터라도 Fiori 팝업 강조를 보장하지 않습니다.
동적 매핑 때마다 line을 새로 만들고 field symbol을 해제하므로 이전 필드 플래그가 남지 않습니다.

EML 테스트 4개: 정상, 경고만 있음, 여러 `%cid`의 오류·경고 혼합, 금액/통화 오류.
테스트는 DB를 변경하지 않고 teardown에서 `ROLLBACK ENTITIES`로 상태를 정리합니다.
서비스 정의·바인딩·UI를 배포하지 않았으며 OData/Fiori 동작은 별도 검증 대상입니다.
