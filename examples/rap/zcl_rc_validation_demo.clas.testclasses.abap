CLASS ltc_rap_validation DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS teardown.
    METHODS valid_request FOR TESTING.
    METHODS warning_only FOR TESTING.
    METHODS mixed_requests FOR TESTING.
    METHODS invalid_amount_and_currency FOR TESTING.
ENDCLASS.

CLASS ltc_rap_validation IMPLEMENTATION.
  METHOD teardown.
    ROLLBACK ENTITIES.
  ENDMETHOD.

  METHOD valid_request.
    MODIFY ENTITIES OF zi_rc_order_demo
      ENTITY SalesOrder EXECUTE validateOrder FROM VALUE #(
        ( %cid = 'OK' %param = VALUE #( CustomerId = 'C001' OrderType = 'OR'
          Amount = 100 Currency = 'KRW' RequestedDate = '99991231' ) ) )
      FAILED DATA(failed) REPORTED DATA(reported).
    cl_abap_unit_assert=>assert_initial( failed-salesorder ).
    cl_abap_unit_assert=>assert_initial( reported-salesorder ).
  ENDMETHOD.

  METHOD warning_only.
    MODIFY ENTITIES OF zi_rc_order_demo
      ENTITY SalesOrder EXECUTE validateOrder FROM VALUE #(
        ( %cid = 'WARN' %param = VALUE #( CustomerId = 'LONGID' OrderType = 'OR'
          Amount = 100 Currency = 'KRW' RequestedDate = '99991231' ) ) )
      FAILED DATA(failed) REPORTED DATA(reported).
    cl_abap_unit_assert=>assert_initial( failed-salesorder ).
    cl_abap_unit_assert=>assert_equals( act = lines( reported-salesorder ) exp = 1 ).
    DATA(line) = reported-salesorder[ 1 ].
    cl_abap_unit_assert=>assert_equals( act = line-%cid exp = 'WARN' ).
    cl_abap_unit_assert=>assert_equals( act = line-%msg->m_severity
                                       exp = if_abap_behv_message=>severity-warning ).
    cl_abap_unit_assert=>assert_equals( act = line-%element-CustomerId exp = if_abap_behv=>mk-on ).
    cl_abap_unit_assert=>assert_equals( act = line-%op-%action-validateOrder exp = if_abap_behv=>mk-on ).
    cl_abap_unit_assert=>assert_true( xsdbool( line-%msg IS INSTANCE OF zcx_app_error ) ).
  ENDMETHOD.

  METHOD mixed_requests.
    MODIFY ENTITIES OF zi_rc_order_demo
      ENTITY SalesOrder EXECUTE validateOrder FROM VALUE #(
        ( %cid = 'BAD1' %param = VALUE #( OrderType = 'OR' Amount = 100 Currency = 'KRW' ) )
        ( %cid = 'GOOD' %param = VALUE #( CustomerId = 'C001' OrderType = 'OR' Amount = 100 Currency = 'KRW' ) )
        ( %cid = 'BAD2' %param = VALUE #( CustomerId = 'LONGID' OrderType = 'XX' Amount = 100 Currency = 'KRW' ) ) )
      FAILED DATA(failed) REPORTED DATA(reported).
    cl_abap_unit_assert=>assert_equals( act = lines( failed-salesorder ) exp = 2 ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( failed-salesorder[ KEY cid %cid = 'BAD1' ] ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( failed-salesorder[ KEY cid %cid = 'BAD2' ] ) ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( reported-salesorder[ KEY cid %cid = 'GOOD' ] ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lines( reported-salesorder ) exp = 3 ).
    LOOP AT reported-salesorder INTO DATA(line).
      IF line-%element-OrderType = if_abap_behv=>mk-on.
        cl_abap_unit_assert=>assert_initial( line-%element-CustomerId ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD invalid_amount_and_currency.
    MODIFY ENTITIES OF zi_rc_order_demo
      ENTITY SalesOrder EXECUTE validateOrder FROM VALUE #(
        ( %cid = 'ZERO' %param = VALUE #( CustomerId = 'C001' OrderType = 'OR' Amount = 0 ) )
        ( %cid = 'CURR' %param = VALUE #( CustomerId = 'C001' OrderType = 'OR' Amount = 1 ) ) )
      FAILED DATA(failed) REPORTED DATA(reported).
    cl_abap_unit_assert=>assert_equals( act = lines( failed-salesorder ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( reported-salesorder ) exp = 2 ).
    DATA(amount_message) = reported-salesorder[ %cid = 'ZERO' ].
    DATA(currency_message) = reported-salesorder[ %cid = 'CURR' ].
    cl_abap_unit_assert=>assert_equals( act = amount_message-%element-Amount exp = if_abap_behv=>mk-on ).
    cl_abap_unit_assert=>assert_equals( act = currency_message-%element-Currency exp = if_abap_behv=>mk-on ).
  ENDMETHOD.
ENDCLASS.
