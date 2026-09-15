CLASS lcx_foreign DEFINITION INHERITING FROM cx_dynamic_check FINAL.
  PUBLIC SECTION.
    INTERFACES if_t100_message.
    DATA detail TYPE string.
    METHODS constructor IMPORTING number TYPE symsgno DEFAULT '008'.
ENDCLASS.
CLASS lcx_foreign IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    detail = `A  B`.
    if_t100_message~t100key = VALUE #( msgid = 'ZMC_APP' msgno = number
                                      attr1 = 'DETAIL' attr2 = 'DETAIL' ).
  ENDMETHOD.
ENDCLASS.
CLASS lcx_text DEFINITION INHERITING FROM cx_dynamic_check FINAL.
  PUBLIC SECTION.
    METHODS constructor IMPORTING text TYPE string.
    METHODS get_text REDEFINITION.
  PRIVATE SECTION.
    DATA content TYPE string.
ENDCLASS.
CLASS lcx_text IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    content = text.
  ENDMETHOD.
  METHOD get_text.
    result = content.
  ENDMETHOD.
ENDCLASS.

CLASS ltc_app_error DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS constructor_default_and_key FOR TESTING RAISING cx_static_check.
    METHODS raise_and_conditional FOR TESTING RAISING cx_static_check.
    METHODS wrap_existing_and_override FOR TESTING RAISING cx_static_check.
    METHODS wrap_foreign_attributes FOR TESTING RAISING cx_static_check.
    METHODS wrap_message_zero FOR TESTING RAISING cx_static_check.
    METHODS wrap_unbound FOR TESTING RAISING cx_static_check.
    METHODS wrap_text_chunks FOR TESTING RAISING cx_static_check.
    METHODS wrap_short_and_empty_text FOR TESTING RAISING cx_static_check.
    METHODS raise_wrapped_default_severity FOR TESTING RAISING cx_static_check.
    METHODS raise_wrapped_override FOR TESTING RAISING cx_static_check.
    METHODS dynamic_message_roundtrip FOR TESTING RAISING cx_static_check.
    METHODS bapiret_types_and_variables FOR TESTING RAISING cx_static_check.
    METHODS bapiret_text_without_id FOR TESTING RAISING cx_static_check.
    METHODS bapiret_first_error FOR TESTING RAISING cx_static_check.
    METHODS sy_message_and_zero_subrc FOR TESTING RAISING cx_static_check.
    METHODS korean_t100_text FOR TESTING.
ENDCLASS.

CLASS ltc_app_error IMPLEMENTATION.
  METHOD korean_t100_text.
    DATA(error) = NEW zcx_app_error( textid = zcx_app_error=>required_field v1 = 'Customer' ).
    cl_abap_unit_assert=>assert_equals( act = error->get_text( )
      exp = 'Customer 은(는) 필수 입력 항목입니다.' ).
  ENDMETHOD.

  METHOD constructor_default_and_key.
    DATA(error) = NEW zcx_app_error( ).
    cl_abap_unit_assert=>assert_equals( act = error->if_t100_message~t100key exp = zcx_app_error=>unexpected ).
    DATA(cause) = NEW zcx_app_error( ).
    error = NEW #( textid = zcx_app_error=>required_field previous = cause v1 = 'Customer' ).
    cl_abap_unit_assert=>assert_equals( act = error->previous exp = cause ).
    DATA(msg) = error->get_symsg( ).
    cl_abap_unit_assert=>assert_equals( act = msg-msgno exp = '001' ).
    cl_abap_unit_assert=>assert_equals( act = msg-msgv1 exp = 'Customer' ).
    cl_abap_unit_assert=>assert_equals( act = msg-msgty exp = 'E' ).
  ENDMETHOD.

  METHOD raise_and_conditional.
    zcx_app_error=>raise_if( cond = abap_false textid = zcx_app_error=>not_found ).
    zcx_app_error=>raise_if( cond = abap_undefined textid = zcx_app_error=>not_found ).
    TRY.
        zcx_app_error=>raise_if( cond = abap_true textid = zcx_app_error=>not_found v1 = 'Order' v2 = '42' ).
        cl_abap_unit_assert=>fail( 'Expected an exception' ).
      CATCH zcx_app_error INTO DATA(error).
        cl_abap_unit_assert=>assert_equals( act = error->mv_v2 exp = '42' ).
    ENDTRY.
  ENDMETHOD.

  METHOD wrap_existing_and_override.
    DATA(original) = NEW zcx_app_error( textid = zcx_app_error=>required_field v1 = 'Name'
                                       severity = if_abap_behv_message=>severity-warning ).
    cl_abap_unit_assert=>assert_equals( act = zcx_app_error=>wrap( original ) exp = original ).
    DATA(error) = zcx_app_error=>wrap( previous = original severity = if_abap_behv_message=>severity-error ).
    cl_abap_unit_assert=>assert_equals( act = error->previous exp = original ).
    cl_abap_unit_assert=>assert_equals( act = error->if_abap_behv_message~m_severity exp = if_abap_behv_message=>severity-error ).
    cl_abap_unit_assert=>assert_equals( act = original->if_abap_behv_message~m_severity exp = if_abap_behv_message=>severity-warning ).
    cl_abap_unit_assert=>assert_equals( act = error->mv_v1 exp = 'Name' ).
  ENDMETHOD.

  METHOD wrap_foreign_attributes.
    DATA(original) = NEW lcx_foreign( ).
    DATA(error) = zcx_app_error=>wrap( original ).
    cl_abap_unit_assert=>assert_equals( act = error->previous exp = original ).
    cl_abap_unit_assert=>assert_equals( act = error->if_t100_message~t100key-msgno exp = '008' ).
    cl_abap_unit_assert=>assert_equals( act = error->if_t100_message~t100key-attr1 exp = 'MV_V1' ).
    cl_abap_unit_assert=>assert_equals( act = error->mv_v1 exp = `A  B` ).
    cl_abap_unit_assert=>assert_initial( error->mv_v3 ).
  ENDMETHOD.

  METHOD wrap_message_zero.
    DATA(error) = zcx_app_error=>wrap( NEW lcx_foreign( number = '000' ) ).
    cl_abap_unit_assert=>assert_equals( act = error->if_t100_message~t100key-msgno exp = '000' ).
    cl_abap_unit_assert=>assert_equals( act = error->mv_v1 exp = `A  B` ).
  ENDMETHOD.

  METHOD wrap_unbound.
    DATA original TYPE REF TO cx_root.
    DATA(error) = zcx_app_error=>wrap( original ).
    cl_abap_unit_assert=>assert_bound( error ).
    cl_abap_unit_assert=>assert_equals( act = error->if_t100_message~t100key exp = zcx_app_error=>unexpected ).
    cl_abap_unit_assert=>assert_equals( act = error->if_abap_behv_message~m_severity exp = if_abap_behv_message=>severity-error ).
  ENDMETHOD.

  METHOD wrap_text_chunks.
    DATA(content) = repeat( val = `1234567890` occ = 23 ).
    DATA(original) = NEW lcx_text( text = content ).
    DATA(error) = zcx_app_error=>wrap( original ).
    cl_abap_unit_assert=>assert_equals( act = error->if_t100_message~t100key-msgno exp = '011' ).
    cl_abap_unit_assert=>assert_equals( act = error->mv_v1 && error->mv_v2 && error->mv_v3 && error->mv_v4
                                     exp = substring( val = content len = 200 ) ).
    cl_abap_unit_assert=>assert_equals( act = error->previous->get_text( ) exp = content ).
  ENDMETHOD.

  METHOD wrap_short_and_empty_text.
    DATA(error) = zcx_app_error=>wrap( NEW lcx_text( text = `A  B` ) ).
    cl_abap_unit_assert=>assert_equals( act = error->mv_v1 exp = `A  B` ).
    cl_abap_unit_assert=>assert_initial( error->mv_v2 ).
    error = zcx_app_error=>wrap( NEW lcx_text( text = `` ) ).
    cl_abap_unit_assert=>assert_initial( error->mv_v1 ).
  ENDMETHOD.

  METHOD raise_wrapped_default_severity.
    TRY.
        zcx_app_error=>raise_wrapped( NEW lcx_text( text = 'Failure' ) ).
        cl_abap_unit_assert=>fail( 'Expected wrapped exception' ).
      CATCH zcx_app_error INTO DATA(error).
        cl_abap_unit_assert=>assert_equals( act = error->if_abap_behv_message~m_severity exp = if_abap_behv_message=>severity-error ).
    ENDTRY.
  ENDMETHOD.

  METHOD raise_wrapped_override.
    TRY.
        zcx_app_error=>raise_wrapped( previous = NEW lcx_text( text = 'Warning' )
                                      severity = if_abap_behv_message=>severity-warning ).
        cl_abap_unit_assert=>fail( 'Expected wrapped exception' ).
      CATCH zcx_app_error INTO DATA(error).
        cl_abap_unit_assert=>assert_equals( act = error->if_abap_behv_message~m_severity exp = if_abap_behv_message=>severity-warning ).
    ENDTRY.
  ENDMETHOD.

  METHOD dynamic_message_roundtrip.
    TRY.
        RAISE EXCEPTION TYPE zcx_app_error MESSAGE e008(zmc_app) WITH 'Type' 'XX'.
      CATCH zcx_app_error INTO DATA(error).
        DATA(msg) = error->get_symsg( ).
        cl_abap_unit_assert=>assert_equals( act = msg-msgid exp = 'ZMC_APP' ).
        cl_abap_unit_assert=>assert_equals( act = msg-msgv1 exp = 'Type' ).
        cl_abap_unit_assert=>assert_equals( act = msg-msgv2 exp = 'XX' ).
    ENDTRY.
  ENDMETHOD.

  METHOD bapiret_types_and_variables.
    DATA(types) = VALUE string_table( ( `E` ) ( `A` ) ( `X` ) ( `W` ) ( `S` ) ( `I` ) ).
    LOOP AT types INTO DATA(type).
      DATA(input) = VALUE bapiret2( type = type id = 'ZMC_APP' number = '007'
                                   message_v1 = 'a' message_v2 = 'b' message_v3 = 'c' message_v4 = 'd' ).
      TRY.
          zcx_app_error=>raise_from_bapiret( input ).
          cl_abap_unit_assert=>fail( 'Expected BAPI exception' ).
        CATCH zcx_app_error INTO DATA(error).
          DATA(output) = error->get_bapiret( ).
          cl_abap_unit_assert=>assert_equals( act = output-type exp = input-type ).
          cl_abap_unit_assert=>assert_equals( act = output-message_v4 exp = 'd' ).
          cl_abap_unit_assert=>assert_equals( act = output-number exp = '007' ).
          cl_abap_unit_assert=>assert_not_initial( output-message ).
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD bapiret_text_without_id.
    TRY.
        zcx_app_error=>raise_from_bapiret( VALUE #( type = 'E' message = 'Backend failure' ) ).
      CATCH zcx_app_error INTO DATA(error).
        cl_abap_unit_assert=>assert_equals( act = error->if_t100_message~t100key-msgno exp = '011' ).
        cl_abap_unit_assert=>assert_equals( act = error->mv_v1 exp = 'Backend failure' ).
    ENDTRY.
  ENDMETHOD.

  METHOD bapiret_first_error.
    zcx_app_error=>raise_if_bapiret_error( VALUE #( ( type = 'W' ) ( type = 'S' ) ) ).
    TRY.
        zcx_app_error=>raise_if_bapiret_error( VALUE #( ( type = 'W' )
           ( type = 'A' id = 'ZMC_APP' number = '007' message_v1 = 'first' )
           ( type = 'E' id = 'ZMC_APP' number = '007' message_v1 = 'later' ) ) ).
        cl_abap_unit_assert=>fail( 'Expected first error' ).
      CATCH zcx_app_error INTO DATA(error).
        DATA(msg) = error->get_symsg( ).
        cl_abap_unit_assert=>assert_equals( act = msg-msgv1 exp = 'first' ).
    ENDTRY.
  ENDMETHOD.

  METHOD sy_message_and_zero_subrc.
    zcx_app_error=>raise_from_sy( subrc = 0 ).
    MESSAGE e008(zmc_app) WITH 'Type' 'XX' INTO DATA(text).
    TRY.
        zcx_app_error=>raise_from_sy( subrc = 4 ).
        cl_abap_unit_assert=>fail( 'Expected SY message exception' ).
      CATCH zcx_app_error INTO DATA(error).
        DATA(msg) = error->get_symsg( ).
        cl_abap_unit_assert=>assert_equals( act = msg-msgno exp = '008' ).
        cl_abap_unit_assert=>assert_equals( act = msg-msgv2 exp = 'XX' ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
