"! Fluent parameter validation using T100 exception objects.
"! No RAP handler or transaction dependency; message types come from RAP.
CLASS zcl_param_validator DEFINITION
  PUBLIC FINAL CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ts_violation,
        field TYPE string,
        error TYPE REF TO zcx_app_error,
      END OF ts_violation,
      tt_violation TYPE STANDARD TABLE OF ts_violation WITH EMPTY KEY.

    CLASS-METHODS create
      RETURNING VALUE(result) TYPE REF TO zcl_param_validator.

    METHODS required
      IMPORTING field TYPE clike
                value TYPE any
                label TYPE clike OPTIONAL
                textid LIKE if_t100_message=>t100key DEFAULT zcx_app_error=>required_field
                severity TYPE if_abap_behv_message=>t_severity
                  DEFAULT if_abap_behv_message=>severity-error
      RETURNING VALUE(self) TYPE REF TO zcl_param_validator.

    METHODS required_if
      IMPORTING cond TYPE abap_bool
                field TYPE clike
                value TYPE any
                label TYPE clike OPTIONAL
                textid LIKE if_t100_message=>t100key DEFAULT zcx_app_error=>required_field
                severity TYPE if_abap_behv_message=>t_severity
                  DEFAULT if_abap_behv_message=>severity-error
      RETURNING VALUE(self) TYPE REF TO zcl_param_validator.

    METHODS ensure
      IMPORTING that TYPE abap_bool
                field TYPE clike
                textid LIKE if_t100_message=>t100key
                v1 TYPE clike OPTIONAL
                v2 TYPE clike OPTIONAL
                v3 TYPE clike OPTIONAL
                v4 TYPE clike OPTIONAL
                severity TYPE if_abap_behv_message=>t_severity
                  DEFAULT if_abap_behv_message=>severity-error
      RETURNING VALUE(self) TYPE REF TO zcl_param_validator.

    "! Elementary value and comparable elementary table rows are required.
    METHODS one_of
      IMPORTING field TYPE clike
                value TYPE any
                in TYPE ANY TABLE
                label TYPE clike OPTIONAL
                textid LIKE if_t100_message=>t100key DEFAULT zcx_app_error=>value_not_allowed
                severity TYPE if_abap_behv_message=>t_severity
                  DEFAULT if_abap_behv_message=>severity-error
      RETURNING VALUE(self) TYPE REF TO zcl_param_validator.

    "! Inclusive bounds. Set include_initial to validate numeric zero too.
    METHODS in_range
      IMPORTING field TYPE clike
                value TYPE any
                low TYPE any
                high TYPE any
                label TYPE clike OPTIONAL
                include_initial TYPE abap_bool DEFAULT abap_false
                textid LIKE if_t100_message=>t100key DEFAULT zcx_app_error=>out_of_range
                severity TYPE if_abap_behv_message=>t_severity
                  DEFAULT if_abap_behv_message=>severity-error
      RETURNING VALUE(self) TYPE REF TO zcl_param_validator.

    "! Uses ABAP strlen semantics; trailing blanks in fixed CHAR are ignored.
    METHODS max_length
      IMPORTING field TYPE clike
                value TYPE clike
                max TYPE i
                label TYPE clike OPTIONAL
                textid LIKE if_t100_message=>t100key DEFAULT zcx_app_error=>max_length_exceeded
                severity TYPE if_abap_behv_message=>t_severity
                  DEFAULT if_abap_behv_message=>severity-error
      RETURNING VALUE(self) TYPE REF TO zcl_param_validator.

    METHODS add_error
      IMPORTING field TYPE clike OPTIONAL
                error TYPE REF TO zcx_app_error
      RETURNING VALUE(self) TYPE REF TO zcl_param_validator.

    "! Appends a snapshot of rows; exception object references are shared.
    METHODS merge
      IMPORTING other TYPE REF TO zcl_param_validator
      RETURNING VALUE(self) TYPE REF TO zcl_param_validator.

    METHODS get_violations RETURNING VALUE(result) TYPE tt_violation.
    METHODS get_texts RETURNING VALUE(result) TYPE string_table.
    METHODS get_bapiret RETURNING VALUE(result) TYPE bapiret2_t.
    METHODS is_valid RETURNING VALUE(result) TYPE abap_bool.
    METHODS has_errors RETURNING VALUE(result) TYPE abap_bool.
    METHODS has_messages RETURNING VALUE(result) TYPE abap_bool.
    METHODS raise_if_invalid RAISING zcx_app_error.

  PRIVATE SECTION.
    DATA mt_violation TYPE tt_violation.

    METHODS add
      IMPORTING field TYPE clike
                textid LIKE if_t100_message=>t100key
                severity TYPE if_abap_behv_message=>t_severity
                v1 TYPE clike OPTIONAL
                v2 TYPE clike OPTIONAL
                v3 TYPE clike OPTIONAL
                v4 TYPE clike OPTIONAL.

    METHODS caption
      IMPORTING field TYPE clike
                label TYPE clike
      RETURNING VALUE(result) TYPE string.

    METHODS to_text
      IMPORTING value TYPE any
      RETURNING VALUE(result) TYPE string.
ENDCLASS.

CLASS zcl_param_validator IMPLEMENTATION.
  METHOD create.
    result = NEW #( ).
  ENDMETHOD.

  METHOD required.
    self = me.
    CHECK value IS INITIAL.
    add( field = field
         textid = textid
         severity = severity
         v1 = caption( field = field label = label ) ).
  ENDMETHOD.

  METHOD required_if.
    self = me.
    CHECK cond = abap_true.
    self = required( field = field
                     value = value
                     label = label
                     textid = textid
                     severity = severity ).
  ENDMETHOD.

  METHOD ensure.
    self = me.
    CHECK that <> abap_true.
    add( field = field
         textid = textid
         severity = severity
         v1 = v1
         v2 = v2
         v3 = v3
         v4 = v4 ).
  ENDMETHOD.

  METHOD one_of.
    self = me.
    LOOP AT in ASSIGNING FIELD-SYMBOL(<allowed>).
      IF <allowed> = value.
        RETURN.
      ENDIF.
    ENDLOOP.
    add( field = field
         textid = textid
         severity = severity
         v1 = caption( field = field label = label )
         v2 = to_text( value ) ).
  ENDMETHOD.

  METHOD in_range.
    self = me.
    CHECK include_initial = abap_true OR value IS NOT INITIAL.
    CHECK value < low OR value > high.
    add( field = field
         textid = textid
         severity = severity
         v1 = caption( field = field label = label )
         v2 = to_text( low )
         v3 = to_text( high ) ).
  ENDMETHOD.

  METHOD max_length.
    self = me.
    CHECK strlen( value ) > max.
    add( field = field
         textid = textid
         severity = severity
         v1 = caption( field = field label = label )
         v2 = |{ max }| ).
  ENDMETHOD.

  METHOD add_error.
    self = me.
    CHECK error IS BOUND.
    APPEND VALUE #( field = to_upper( field ) error = error ) TO mt_violation.
  ENDMETHOD.

  METHOD merge.
    self = me.
    CHECK other IS BOUND.
    DATA(violations) = other->get_violations( ).
    APPEND LINES OF violations TO mt_violation.
  ENDMETHOD.

  METHOD add.
    APPEND VALUE #(
      field = to_upper( field )
      error = NEW zcx_app_error( textid = textid
                                 severity = severity
                                 v1 = v1
                                 v2 = v2
                                 v3 = v3
                                 v4 = v4 ) ) TO mt_violation.
  ENDMETHOD.

  METHOD caption.
    result = COND string( WHEN label IS NOT INITIAL THEN label ELSE field ).
  ENDMETHOD.

  METHOD to_text.
    " Conversion/type errors are programming errors, not validation results.
    result = value.
    result = condense( result ).
  ENDMETHOD.

  METHOD get_violations.
    result = mt_violation.
  ENDMETHOD.

  METHOD get_texts.
    LOOP AT mt_violation INTO DATA(violation).
      APPEND violation-error->get_text( ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_bapiret.
    LOOP AT mt_violation INTO DATA(violation).
      APPEND violation-error->get_bapiret( ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_valid.
    result = xsdbool( has_errors( ) = abap_false ).
  ENDMETHOD.

  METHOD has_errors.
    result = abap_false.
    LOOP AT mt_violation INTO DATA(violation).
      IF violation-error->if_abap_behv_message~m_severity = if_abap_behv_message=>severity-error.
        result = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_messages.
    result = xsdbool( mt_violation IS NOT INITIAL ).
  ENDMETHOD.

  METHOD raise_if_invalid.
    LOOP AT mt_violation INTO DATA(violation).
      IF violation-error->if_abap_behv_message~m_severity = if_abap_behv_message=>severity-error.
        RAISE EXCEPTION violation-error.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
