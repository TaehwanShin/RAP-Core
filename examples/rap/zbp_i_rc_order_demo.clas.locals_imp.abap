" Business-specific rules are separate from the BO-specific RAP adapter.
CLASS lcl_order_rules DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS validate
      IMPORTING param TYPE za_createordersparam
                today TYPE d
      RETURNING VALUE(result) TYPE REF TO zcl_param_validator.
ENDCLASS.

CLASS lcl_order_rules IMPLEMENTATION.
  METHOD validate.
    result = zcl_param_validator=>create(
      )->required( field = 'CustomerId' value = param-customerid
      )->required( field = 'OrderType' value = param-ordertype
      )->ensure( that = xsdbool( param-amount > 0 ) field = 'Amount'
                  textid = zcx_app_error=>invalid_state v1 = 'Amount <= 0' v2 = 'Order validation'
      )->required_if( cond = xsdbool( param-amount > 0 ) field = 'Currency' value = param-currency
      )->in_range( field = 'RequestedDate' value = param-requesteddate
                    low = today high = CONV d( '99991231' )
      )->max_length( field = 'CustomerId' value = param-customerid max = 5
                      severity = if_abap_behv_message=>severity-warning ).

    " Avoid two messages for an empty order type.
    IF param-ordertype IS NOT INITIAL.
      result->one_of( field = 'OrderType' value = param-ordertype
                       in = VALUE string_table( ( `OR` ) ( `RE` ) ( `CR` ) ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_salesorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS validateorder FOR MODIFY
      IMPORTING keys FOR ACTION SalesOrder~validateOrder.
    METHODS read FOR READ
      IMPORTING keys FOR READ SalesOrder RESULT result.
ENDCLASS.

CLASS lhc_salesorder IMPLEMENTATION.
  METHOD validateorder.
    DATA line LIKE LINE OF reported-salesorder.
    FIELD-SYMBOLS <flag> TYPE any.
    LOOP AT keys INTO DATA(key).
      DATA(validator) = lcl_order_rules=>validate(
        param = key-%param today = cl_abap_context_info=>get_system_date( ) ).

      " Always report messages, including warning-only requests.
      LOOP AT validator->get_violations( ) INTO DATA(violation).
        line = VALUE #( %cid = key-%cid %msg = violation-error
                         %op-%action-validateOrder = if_abap_behv=>mk-on ).
        " These flags address BO fields, not action-dialog parameter fields.
        UNASSIGN <flag>.
        ASSIGN COMPONENT violation-field OF STRUCTURE line-%element TO <flag>.
        IF sy-subrc = 0.
          <flag> = if_abap_behv=>mk-on.
        ENDIF.
        APPEND line TO reported-salesorder.
      ENDLOOP.

      IF validator->has_errors( ) = abap_true.
        APPEND VALUE #( %cid = key-%cid %fail-cause = if_abap_behv=>cause-unspecific
                         %op-%action-validateOrder = if_abap_behv=>mk-on ) TO failed-salesorder.
        CONTINUE.
      ENDIF.
      " Validation-only demo: success has no failed entry. No database writes.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(key).
      SELECT SINGLE FROM zi_rc_order_demo FIELDS *
        WHERE OrderId = @key-OrderId INTO @DATA(order).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( order ) TO result.
      ELSE.
        APPEND VALUE #( %tky = key-%tky %fail-cause = if_abap_behv=>cause-not_found )
          TO failed-salesorder.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

" This BO has no transactional buffer or persistence changes to save.
CLASS lsc_order_demo DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.
CLASS lsc_order_demo IMPLEMENTATION.
  METHOD finalize.
  ENDMETHOD.
  METHOD check_before_save.
  ENDMETHOD.
  METHOD save.
  ENDMETHOD.
  METHOD cleanup.
  ENDMETHOD.
  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
