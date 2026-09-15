"! T100 application exception with RAP, SYMSG and BAPIRET2 adapters.
CLASS zcx_app_error DEFINITION
  PUBLIC INHERITING FROM cx_static_check CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_t100_message.
    INTERFACES if_t100_dyn_msg.
    INTERFACES if_abap_behv_message.

    CONSTANTS: BEGIN OF required_field,
                 msgid TYPE symsgid VALUE 'ZMC_APP',
                 msgno TYPE symsgno VALUE '001',
                 attr1 TYPE scx_attrname VALUE 'MV_V1',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF required_field.

    CONSTANTS: BEGIN OF not_found,
                 msgid TYPE symsgid VALUE 'ZMC_APP',
                 msgno TYPE symsgno VALUE '002',
                 attr1 TYPE scx_attrname VALUE 'MV_V1',
                 attr2 TYPE scx_attrname VALUE 'MV_V2',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF not_found.

    CONSTANTS: BEGIN OF locked_by_user,
                 msgid TYPE symsgid VALUE 'ZMC_APP',
                 msgno TYPE symsgno VALUE '003',
                 attr1 TYPE scx_attrname VALUE 'MV_V1',
                 attr2 TYPE scx_attrname VALUE 'MV_V2',
                 attr3 TYPE scx_attrname VALUE 'MV_V3',
                 attr4 TYPE scx_attrname VALUE '',
               END OF locked_by_user.

    CONSTANTS: BEGIN OF no_authorization,
                 msgid TYPE symsgid VALUE 'ZMC_APP',
                 msgno TYPE symsgno VALUE '004',
                 attr1 TYPE scx_attrname VALUE 'MV_V1',
                 attr2 TYPE scx_attrname VALUE 'MV_V2',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF no_authorization.

    CONSTANTS: BEGIN OF update_failed,
                 msgid TYPE symsgid VALUE 'ZMC_APP',
                 msgno TYPE symsgno VALUE '005',
                 attr1 TYPE scx_attrname VALUE 'MV_V1',
                 attr2 TYPE scx_attrname VALUE 'MV_V2',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF update_failed.

    CONSTANTS: BEGIN OF invalid_state,
                 msgid TYPE symsgid VALUE 'ZMC_APP',
                 msgno TYPE symsgno VALUE '006',
                 attr1 TYPE scx_attrname VALUE 'MV_V1',
                 attr2 TYPE scx_attrname VALUE 'MV_V2',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF invalid_state.

    CONSTANTS: BEGIN OF unexpected,
                 msgid TYPE symsgid VALUE 'ZMC_APP',
                 msgno TYPE symsgno VALUE '007',
                 attr1 TYPE scx_attrname VALUE 'MV_V1',
                 attr2 TYPE scx_attrname VALUE 'MV_V2',
                 attr3 TYPE scx_attrname VALUE 'MV_V3',
                 attr4 TYPE scx_attrname VALUE 'MV_V4',
               END OF unexpected.

    CONSTANTS: BEGIN OF value_not_allowed,
                 msgid TYPE symsgid VALUE 'ZMC_APP',
                 msgno TYPE symsgno VALUE '008',
                 attr1 TYPE scx_attrname VALUE 'MV_V1',
                 attr2 TYPE scx_attrname VALUE 'MV_V2',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF value_not_allowed.

    CONSTANTS: BEGIN OF out_of_range,
                 msgid TYPE symsgid VALUE 'ZMC_APP',
                 msgno TYPE symsgno VALUE '009',
                 attr1 TYPE scx_attrname VALUE 'MV_V1',
                 attr2 TYPE scx_attrname VALUE 'MV_V2',
                 attr3 TYPE scx_attrname VALUE 'MV_V3',
                 attr4 TYPE scx_attrname VALUE '',
               END OF out_of_range.

    CONSTANTS: BEGIN OF max_length_exceeded,
                 msgid TYPE symsgid VALUE 'ZMC_APP',
                 msgno TYPE symsgno VALUE '010',
                 attr1 TYPE scx_attrname VALUE 'MV_V1',
                 attr2 TYPE scx_attrname VALUE 'MV_V2',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF max_length_exceeded.

    CONSTANTS: BEGIN OF free_text,
                 msgid TYPE symsgid VALUE 'ZMC_APP',
                 msgno TYPE symsgno VALUE '011',
                 attr1 TYPE scx_attrname VALUE 'MV_V1',
                 attr2 TYPE scx_attrname VALUE 'MV_V2',
                 attr3 TYPE scx_attrname VALUE 'MV_V3',
                 attr4 TYPE scx_attrname VALUE 'MV_V4',
               END OF free_text.

    DATA mv_v1 TYPE string READ-ONLY.
    DATA mv_v2 TYPE string READ-ONLY.
    DATA mv_v3 TYPE string READ-ONLY.
    DATA mv_v4 TYPE string READ-ONLY.

    METHODS constructor
      IMPORTING textid LIKE if_t100_message=>t100key OPTIONAL
                previous LIKE previous OPTIONAL
                severity TYPE if_abap_behv_message=>t_severity
                  DEFAULT if_abap_behv_message=>severity-error
                v1 TYPE clike OPTIONAL
                v2 TYPE clike OPTIONAL
                v3 TYPE clike OPTIONAL
                v4 TYPE clike OPTIONAL.

    CLASS-METHODS raise
      IMPORTING textid LIKE if_t100_message=>t100key
                previous TYPE REF TO cx_root OPTIONAL
                severity TYPE if_abap_behv_message=>t_severity
                  DEFAULT if_abap_behv_message=>severity-error
                v1 TYPE clike OPTIONAL
                v2 TYPE clike OPTIONAL
                v3 TYPE clike OPTIONAL
                v4 TYPE clike OPTIONAL
      RAISING zcx_app_error.

    CLASS-METHODS raise_if
      IMPORTING cond TYPE abap_bool
                textid LIKE if_t100_message=>t100key
                severity TYPE if_abap_behv_message=>t_severity
                  DEFAULT if_abap_behv_message=>severity-error
                v1 TYPE clike OPTIONAL
                v2 TYPE clike OPTIONAL
                v3 TYPE clike OPTIONAL
                v4 TYPE clike OPTIONAL
      RAISING zcx_app_error.

    CLASS-METHODS wrap
      IMPORTING previous TYPE REF TO cx_root
                severity TYPE if_abap_behv_message=>t_severity OPTIONAL
      RETURNING VALUE(ro_error) TYPE REF TO zcx_app_error.

    CLASS-METHODS raise_wrapped
      IMPORTING previous TYPE REF TO cx_root
                severity TYPE if_abap_behv_message=>t_severity OPTIONAL
      RAISING zcx_app_error.

    "! Pass subrc immediately after the legacy call; zero is a no-op.
    CLASS-METHODS raise_from_sy
      IMPORTING subrc TYPE sysubrc DEFAULT 4
                previous TYPE REF TO cx_root OPTIONAL
                severity TYPE if_abap_behv_message=>t_severity
                  DEFAULT if_abap_behv_message=>severity-error
      RAISING zcx_app_error.

    CLASS-METHODS raise_from_bapiret
      IMPORTING is_return TYPE bapiret2
                previous TYPE REF TO cx_root OPTIONAL
      RAISING zcx_app_error.

    CLASS-METHODS raise_if_bapiret_error
      IMPORTING it_return TYPE bapiret2_t
                previous TYPE REF TO cx_root OPTIONAL
      RAISING zcx_app_error.

    METHODS get_symsg RETURNING VALUE(rs_msg) TYPE symsg.
    METHODS get_bapiret RETURNING VALUE(rs_return) TYPE bapiret2.

  PRIVATE SECTION.
    CLASS-METHODS read_attribute
      IMPORTING obj TYPE REF TO cx_root
                attr TYPE scx_attrname
      RETURNING VALUE(result) TYPE string.
    CLASS-METHODS chunk_text
      IMPORTING text TYPE string
      RETURNING VALUE(result) TYPE string_table.
    CLASS-METHODS severity_from_type
      IMPORTING msgty TYPE symsgty
      RETURNING VALUE(result) TYPE if_abap_behv_message=>t_severity.
ENDCLASS.

CLASS zcx_app_error IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).
    CLEAR me->textid.
    if_t100_message~t100key = COND #( WHEN textid IS INITIAL THEN unexpected ELSE textid ).
    mv_v1 = v1.
    mv_v2 = v2.
    mv_v3 = v3.
    mv_v4 = v4.
    if_abap_behv_message~m_severity = severity.
  ENDMETHOD.

  METHOD raise.
    RAISE EXCEPTION NEW zcx_app_error( textid = textid
                                       previous = previous
                                       severity = severity
                                       v1 = v1
                                       v2 = v2
                                       v3 = v3
                                       v4 = v4 ).
  ENDMETHOD.

  METHOD raise_if.
    CHECK cond = abap_true.
    raise( textid = textid severity = severity v1 = v1 v2 = v2 v3 = v3 v4 = v4 ).
  ENDMETHOD.

  METHOD wrap.
    DATA effective_severity TYPE if_abap_behv_message=>t_severity.
    IF severity IS SUPPLIED.
      effective_severity = severity.
    ELSEIF previous IS INSTANCE OF if_abap_behv_message.
      effective_severity = CAST if_abap_behv_message( previous )->m_severity.
    ELSEIF previous IS INSTANCE OF if_t100_dyn_msg.
      effective_severity = severity_from_type( CAST if_t100_dyn_msg( previous )->msgty ).
    ELSE.
      effective_severity = if_abap_behv_message=>severity-error.
    ENDIF.

    IF previous IS INSTANCE OF zcx_app_error.
      DATA(existing) = CAST zcx_app_error( previous ).
      IF severity IS NOT SUPPLIED OR effective_severity = existing->if_abap_behv_message~m_severity.
        ro_error = existing.
        RETURN.
      ENDIF.
    ENDIF.

    IF previous IS NOT BOUND.
      ro_error = NEW #( textid = unexpected
                        severity = effective_severity
                        v1 = 'Unbound exception reference' ).
      RETURN.
    ENDIF.

    IF previous IS INSTANCE OF if_t100_message.
      DATA(source_key) = CAST if_t100_message( previous )->t100key.
      " Message 000 is valid; only an empty message class means no T100 key.
      IF source_key-msgid IS NOT INITIAL.
        DATA(target_key) = VALUE scx_t100key( msgid = source_key-msgid
                                            msgno = source_key-msgno
                                            attr1 = 'MV_V1' attr2 = 'MV_V2'
                                            attr3 = 'MV_V3' attr4 = 'MV_V4' ).
        ro_error = NEW #( textid = target_key
                          previous = previous
                          severity = effective_severity
                          v1 = read_attribute( obj = previous attr = source_key-attr1 )
                          v2 = read_attribute( obj = previous attr = source_key-attr2 )
                          v3 = read_attribute( obj = previous attr = source_key-attr3 )
                          v4 = read_attribute( obj = previous attr = source_key-attr4 ) ).
        RETURN.
      ENDIF.
    ENDIF.

    DATA(chunks) = chunk_text( previous->get_text( ) ).
    ro_error = NEW #( textid = free_text
                      previous = previous
                      severity = effective_severity
                      v1 = chunks[ 1 ] v2 = chunks[ 2 ]
                      v3 = chunks[ 3 ] v4 = chunks[ 4 ] ).
  ENDMETHOD.

  METHOD raise_wrapped.
    DATA error TYPE REF TO zcx_app_error.
    IF severity IS SUPPLIED.
      error = wrap( previous = previous severity = severity ).
    ELSE.
      error = wrap( previous = previous ).
    ENDIF.
    RAISE EXCEPTION error.
  ENDMETHOD.

  METHOD read_attribute.
    CHECK obj IS BOUND AND attr IS NOT INITIAL.
    ASSIGN obj->(attr) TO FIELD-SYMBOL(<value>).
    CHECK sy-subrc = 0.
    TRY.
        " Preserve spaces in string attributes, including free-text chunks.
        result = <value>.
      CATCH cx_sy_conversion_error.
        CLEAR result.
    ENDTRY.
  ENDMETHOD.

  METHOD chunk_text.
    DATA(offset) = 0.
    DO 4 TIMES.
      DATA(size) = nmin( val1 = 50 val2 = strlen( text ) - offset ).
      APPEND substring( val = text off = offset len = size ) TO result.
      offset = offset + size.
    ENDDO.
  ENDMETHOD.

  METHOD raise_from_sy.
    CHECK subrc <> 0.
    DATA(message) = VALUE symsg( msgid = sy-msgid msgno = sy-msgno msgty = sy-msgty
                                 msgv1 = sy-msgv1 msgv2 = sy-msgv2
                                 msgv3 = sy-msgv3 msgv4 = sy-msgv4 ).
    IF message-msgid IS INITIAL.
      raise( textid = unexpected previous = previous severity = severity
             v1 = 'SY-SUBRC' v2 = |{ subrc }| ).
    ENDIF.
    IF message-msgty IS INITIAL.
      message-msgty = 'E'.
    ENDIF.
    RAISE EXCEPTION TYPE zcx_app_error
      MESSAGE ID message-msgid TYPE message-msgty NUMBER message-msgno
      WITH message-msgv1 message-msgv2 message-msgv3 message-msgv4
      EXPORTING previous = previous severity = severity.
  ENDMETHOD.

  METHOD severity_from_type.
    result = SWITCH #( msgty
      WHEN 'W' THEN if_abap_behv_message=>severity-warning
      WHEN 'S' THEN if_abap_behv_message=>severity-success
      WHEN 'I' THEN if_abap_behv_message=>severity-information
      ELSE if_abap_behv_message=>severity-error ).
  ENDMETHOD.

  METHOD raise_from_bapiret.
    DATA(severity) = severity_from_type( is_return-type ).
    IF is_return-id IS INITIAL.
      DATA(chunks) = chunk_text( CONV string( is_return-message ) ).
      raise( textid = free_text previous = previous severity = severity
             v1 = chunks[ 1 ] v2 = chunks[ 2 ] v3 = chunks[ 3 ] v4 = chunks[ 4 ] ).
    ENDIF.
    DATA(msgty) = COND symsgty( WHEN is_return-type IS INITIAL THEN 'E' ELSE is_return-type ).
    RAISE EXCEPTION TYPE zcx_app_error
      MESSAGE ID is_return-id TYPE msgty NUMBER is_return-number
      WITH is_return-message_v1 is_return-message_v2 is_return-message_v3 is_return-message_v4
      EXPORTING previous = previous severity = severity.
  ENDMETHOD.

  METHOD raise_if_bapiret_error.
    LOOP AT it_return INTO DATA(message).
      IF message-type = 'E' OR message-type = 'A' OR message-type = 'X'.
        raise_from_bapiret( is_return = message previous = previous ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_symsg.
    DATA(key) = if_t100_message~t100key.
    rs_msg-msgid = key-msgid.
    rs_msg-msgno = key-msgno.
    rs_msg-msgty = COND #(
      WHEN if_t100_dyn_msg~msgty IS NOT INITIAL THEN if_t100_dyn_msg~msgty
      WHEN if_abap_behv_message~m_severity = if_abap_behv_message=>severity-warning THEN 'W'
      WHEN if_abap_behv_message~m_severity = if_abap_behv_message=>severity-success THEN 'S'
      WHEN if_abap_behv_message~m_severity = if_abap_behv_message=>severity-information THEN 'I'
      ELSE 'E' ).
    " Resolve the key's actual attributes, also for RAISE ... MESSAGE.
    rs_msg-msgv1 = read_attribute( obj = me attr = key-attr1 ).
    rs_msg-msgv2 = read_attribute( obj = me attr = key-attr2 ).
    rs_msg-msgv3 = read_attribute( obj = me attr = key-attr3 ).
    rs_msg-msgv4 = read_attribute( obj = me attr = key-attr4 ).
  ENDMETHOD.

  METHOD get_bapiret.
    DATA(message) = get_symsg( ).
    rs_return = VALUE #( type = message-msgty id = message-msgid number = message-msgno
                         message_v1 = message-msgv1 message_v2 = message-msgv2
                         message_v3 = message-msgv3 message_v4 = message-msgv4
                         message = get_text( ) ).
  ENDMETHOD.
ENDCLASS.
