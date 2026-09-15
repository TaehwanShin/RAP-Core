CLASS ltc_param_validator DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS empty_and_isolated FOR TESTING RAISING cx_static_check.
    METHODS required_label_and_key FOR TESTING RAISING cx_static_check.
    METHODS required_initial_types FOR TESTING RAISING cx_static_check.
    METHODS required_if_branches FOR TESTING RAISING cx_static_check.
    METHODS ensure_bool_and_variables FOR TESTING RAISING cx_static_check.
    METHODS one_of_found_missing_empty FOR TESTING RAISING cx_static_check.
    METHODS one_of_numeric_hashed FOR TESTING RAISING cx_static_check.
    METHODS range_boundaries FOR TESTING RAISING cx_static_check.
    METHODS range_initial_opt_in FOR TESTING RAISING cx_static_check.
    METHODS range_dates FOR TESTING RAISING cx_static_check.
    METHODS length_boundary_and_spaces FOR TESTING RAISING cx_static_check.
    METHODS non_errors_do_not_block FOR TESTING RAISING cx_static_check.
    METHODS raise_first_error_identity FOR TESTING RAISING cx_static_check.
    METHODS add_error_unbound_and_chain FOR TESTING RAISING cx_static_check.
    METHODS merge_snapshot_and_self FOR TESTING RAISING cx_static_check.
    METHODS texts_and_bapiret_order FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltc_param_validator IMPLEMENTATION.
  METHOD empty_and_isolated.
    DATA(first) = zcl_param_validator=>create( ).
    DATA(second) = zcl_param_validator=>create( ).
    cl_abap_unit_assert=>assert_bound( first ).
    cl_abap_unit_assert=>assert_equals( act = first->is_valid( ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = first->has_messages( ) exp = abap_false ).
    first->required( field = 'A' value = `` ).
    cl_abap_unit_assert=>assert_equals( act = second->has_messages( ) exp = abap_false ).
  ENDMETHOD.

  METHOD required_label_and_key.
    DATA(v) = zcl_param_validator=>create( )->required( field = 'CustomerId' value = `` label = 'Customer' ).
    DATA(rows) = v->get_violations( ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-field exp = 'CUSTOMERID' ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->mv_v1 exp = 'Customer' ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->if_t100_message~t100key
                                     exp = zcx_app_error=>required_field ).
    cl_abap_unit_assert=>assert_equals( act = v->has_errors( ) exp = abap_true ).
  ENDMETHOD.

  METHOD required_initial_types.
    DATA d TYPE d.
    DATA(v) = zcl_param_validator=>create(
      )->required( field = 'Number' value = 0
      )->required( field = 'Date' value = d
      )->required( field = 'Text' value = 'present' ).
    DATA(rows) = v->get_violations( ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->mv_v1 exp = 'Number' ).
  ENDMETHOD.

  METHOD required_if_branches.
    DATA(v) = zcl_param_validator=>create(
      )->required_if( cond = abap_false field = 'A' value = ``
      )->required_if( cond = abap_true field = 'B' value = 'ok'
      )->required_if( cond = abap_true field = 'C' value = ``
                      textid = zcx_app_error=>not_found label = 'Caption'
                      severity = if_abap_behv_message=>severity-warning ).
    DATA(rows) = v->get_violations( ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->if_t100_message~t100key-msgno exp = '002' ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->mv_v1 exp = 'Caption' ).
    cl_abap_unit_assert=>assert_equals( act = v->is_valid( ) exp = abap_true ).
  ENDMETHOD.

  METHOD ensure_bool_and_variables.
    DATA(v) = zcl_param_validator=>create(
      )->ensure( that = abap_true field = 'A' textid = zcx_app_error=>unexpected
      )->ensure( that = abap_false field = 'B' textid = zcx_app_error=>unexpected
                  v1 = 'a' v2 = 'b' v3 = 'c' v4 = 'd'
      )->ensure( that = abap_undefined field = 'C' textid = zcx_app_error=>unexpected ).
    DATA(rows) = v->get_violations( ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->mv_v4 exp = 'd' ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->mv_v3 exp = 'c' ).
  ENDMETHOD.

  METHOD one_of_found_missing_empty.
    DATA(v) = zcl_param_validator=>create(
      )->one_of( field = 'A' value = 'OR' in = VALUE string_table( ( `RE` ) ( `OR` ) )
      )->one_of( field = 'B' value = 'XX' in = VALUE string_table( ( `OR` ) )
      )->one_of( field = 'C' value = 'OR' in = VALUE string_table( ) ).
    DATA(rows) = v->get_violations( ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->if_t100_message~t100key-msgno exp = '008' ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->mv_v2 exp = 'XX' ).
  ENDMETHOD.

  METHOD one_of_numeric_hashed.
    TYPES ints TYPE HASHED TABLE OF i WITH UNIQUE KEY table_line.
    DATA(v) = zcl_param_validator=>create(
      )->one_of( field = 'A' value = 2 in = VALUE ints( ( 1 ) ( 2 ) )
      )->one_of( field = 'B' value = 3 in = VALUE ints( ( 1 ) ( 2 ) ) ).
    DATA(rows) = v->get_violations( ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->mv_v2 exp = '3' ).
  ENDMETHOD.

  METHOD range_boundaries.
    DATA(v) = zcl_param_validator=>create(
      )->in_range( field = 'Low' value = 1 low = 1 high = 10
      )->in_range( field = 'High' value = 10 low = 1 high = 10
      )->in_range( field = 'Below' value = -1 low = 1 high = 10
      )->in_range( field = 'Above' value = 11 low = 1 high = 10 ).
    DATA(rows) = v->get_violations( ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->if_t100_message~t100key-msgno exp = '009' ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->mv_v2 exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->mv_v3 exp = '10' ).
  ENDMETHOD.

  METHOD range_initial_opt_in.
    DATA(v) = zcl_param_validator=>create(
      )->in_range( field = 'Skip' value = 0 low = 1 high = 10
      )->in_range( field = 'Check' value = 0 low = 1 high = 10 include_initial = abap_true ).
    DATA(rows) = v->get_violations( ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-field exp = 'CHECK' ).
  ENDMETHOD.

  METHOD range_dates.
    DATA(v) = zcl_param_validator=>create(
      )->in_range( field = 'Date' value = CONV d( '20260101' )
                    low = CONV d( '20260101' ) high = CONV d( '20261231' )
      )->in_range( field = 'Date' value = CONV d( '20251231' )
                    low = CONV d( '20260101' ) high = CONV d( '20261231' ) ).
    cl_abap_unit_assert=>assert_equals( act = lines( v->get_violations( ) ) exp = 1 ).
  ENDMETHOD.

  METHOD length_boundary_and_spaces.
    DATA chars TYPE c LENGTH 5 VALUE 'AB'.
    DATA(v) = zcl_param_validator=>create(
      )->max_length( field = 'A' value = `` max = 0
      )->max_length( field = 'B' value = 'ABC' max = 3
      )->max_length( field = 'C' value = 'ABCD' max = 3
      )->max_length( field = 'D' value = chars max = 2
      )->max_length( field = 'E' value = `AB ` max = 2 ).
    DATA(rows) = v->get_violations( ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->if_t100_message~t100key-msgno exp = '010' ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->mv_v2 exp = '3' ).
  ENDMETHOD.

  METHOD non_errors_do_not_block.
    DATA(v) = zcl_param_validator=>create(
      )->required( field = 'W' value = `` severity = if_abap_behv_message=>severity-warning
      )->required( field = 'I' value = `` severity = if_abap_behv_message=>severity-information
      )->required( field = 'S' value = `` severity = if_abap_behv_message=>severity-success ).
    cl_abap_unit_assert=>assert_equals( act = v->has_messages( ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = v->has_errors( ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = v->is_valid( ) exp = abap_true ).
    v->raise_if_invalid( ).
  ENDMETHOD.

  METHOD raise_first_error_identity.
    DATA(first) = NEW zcx_app_error( textid = zcx_app_error=>not_found ).
    DATA(v) = zcl_param_validator=>create(
      )->required( field = 'W' value = `` severity = if_abap_behv_message=>severity-warning
      )->add_error( field = 'E' error = first
      )->required( field = 'Later' value = `` ).
    TRY.
        v->raise_if_invalid( ).
        cl_abap_unit_assert=>fail( 'Expected the first error' ).
      CATCH zcx_app_error INTO DATA(caught).
        cl_abap_unit_assert=>assert_equals( act = caught exp = first ).
    ENDTRY.
  ENDMETHOD.

  METHOD add_error_unbound_and_chain.
    DATA unbound TYPE REF TO zcx_app_error.
    DATA(previous) = NEW zcx_app_error( ).
    DATA(error) = NEW zcx_app_error( previous = previous ).
    DATA(v) = zcl_param_validator=>create( ).
    DATA(same) = v->add_error( error = unbound )->add_error( field = 'Mixed' error = error ).
    DATA(rows) = v->get_violations( ).
    cl_abap_unit_assert=>assert_equals( act = same exp = v ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error exp = error ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error->previous exp = previous ).
  ENDMETHOD.

  METHOD merge_snapshot_and_self.
    DATA unbound TYPE REF TO zcl_param_validator.
    DATA(other) = zcl_param_validator=>create( )->required( field = 'First' value = `` ).
    DATA(v) = zcl_param_validator=>create( )->merge( unbound )->merge( other ).
    other->required( field = 'Later' value = `` ).
    cl_abap_unit_assert=>assert_equals( act = lines( v->get_violations( ) ) exp = 1 ).
    v->merge( v ).
    DATA(rows) = v->get_violations( ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-error exp = rows[ 2 ]-error ).
    CLEAR rows.
    cl_abap_unit_assert=>assert_equals( act = lines( v->get_violations( ) ) exp = 2 ).
  ENDMETHOD.

  METHOD texts_and_bapiret_order.
    DATA(v) = zcl_param_validator=>create(
      )->required( field = 'Customer' value = `` severity = if_abap_behv_message=>severity-warning
      )->one_of( field = 'Type' value = 'XX' in = VALUE string_table( ( `OR` ) ) ).
    DATA(returns) = v->get_bapiret( ).
    DATA(texts) = v->get_texts( ).
    DATA(rows) = v->get_violations( ).
    cl_abap_unit_assert=>assert_equals( act = lines( returns ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = returns[ 1 ]-type exp = 'W' ).
    cl_abap_unit_assert=>assert_equals( act = returns[ 2 ]-type exp = 'E' ).
    cl_abap_unit_assert=>assert_equals( act = returns[ 2 ]-message_v2 exp = 'XX' ).
    cl_abap_unit_assert=>assert_equals( act = texts[ 1 ] exp = rows[ 1 ]-error->get_text( ) ).
    cl_abap_unit_assert=>assert_not_initial( texts[ 1 ] ).
    cl_abap_unit_assert=>assert_equals( act = v->is_valid( ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
