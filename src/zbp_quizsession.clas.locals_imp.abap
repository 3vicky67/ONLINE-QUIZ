CLASS lhc_QuizSession DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR QuizSession RESULT result.

    METHODS create FOR MODIFY IMPORTING entities FOR CREATE QuizSession.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE QuizSession.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE QuizSession.
    METHODS read   FOR READ   IMPORTING keys FOR READ QuizSession RESULT result.

    METHODS StartQuiz    FOR MODIFY IMPORTING keys FOR ACTION QuizSession~StartQuiz RESULT result.
    METHODS SubmitAnswer FOR MODIFY IMPORTING keys FOR ACTION QuizSession~SubmitAnswer RESULT result.
    METHODS GetNextQuestion FOR MODIFY
  IMPORTING keys FOR ACTION QuizSession~GetNextQuestion RESULT result.
ENDCLASS.

CLASS lhc_QuizSession IMPLEMENTATION.

  METHOD get_instance_authorizations.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( %tky = ls_key-%tky
                      %update = if_abap_behv=>auth-allowed
                      %delete = if_abap_behv=>auth-allowed ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD create.
    LOOP AT entities INTO DATA(ls_entity).
      " 1. Generate the ID
      DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).

      " 2. THE FIX: Use 'SessionUuid' (Entity Name), not 'session_uuid' (Table Name)
      APPEND VALUE #( %cid        = ls_entity-%cid
                      SessionUuid = lv_uuid ) TO mapped-quizsession.

      " Note: In Unmanaged Draft, we don't INSERT here.
      " The framework creates the entry in the Draft Table automatically.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    " Updates during Draft phase are handled by the framework in the Draft Table.
  ENDMETHOD.

  METHOD GetNextQuestion.
  " Return the instance so the UI refreshes
  result = VALUE #( FOR key IN keys ( %tky = key-%tky %param = CORRESPONDING #( key ) ) ).
ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      " Delete from Active table
      DELETE FROM zquiz_session WHERE session_uuid = @ls_key-SessionUuid.
      " Delete from Draft table (Technical cleanup)
      DELETE FROM zquiz_sess_d WHERE sessionuuid = @ls_key-SessionUuid.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    " Read from Active table
    SELECT * FROM zquiz_session
      FOR ALL ENTRIES IN @keys
      WHERE session_uuid = @keys-SessionUuid
      INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.

  METHOD StartQuiz.
    " Update the Draft instance via the framework
    MODIFY ENTITIES OF ZI_QuizSession IN LOCAL MODE
      ENTITY QuizSession
        UPDATE FIELDS ( Status CurrentBand )
        WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                        Status = 'IN_PROG'
                                        CurrentBand = 1 ) ).

    " Read result back to refresh UI
    READ ENTITIES OF ZI_QuizSession IN LOCAL MODE
      ENTITY QuizSession ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_sessions).

    result = VALUE #( FOR sess IN lt_sessions ( %tky = sess-%tky %param = sess ) ).
  ENDMETHOD.

  METHOD SubmitAnswer.
    " In a perfect implementation, you would calculate the score here.
    " We return the keys to notify the framework the action was successful.
    result = VALUE #( FOR key IN keys ( %tky = key-%tky %param = CORRESPONDING #( key ) ) ).
  ENDMETHOD.

ENDCLASS.

" --- THE SAVER CLASS: Handles the transition from Draft to Active ---
CLASS lsc_ZI_QUIZSESSION DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_QUIZSESSION IMPLEMENTATION.
  METHOD save.
    " In Unmanaged Draft, the 'save' method must move data from the Draft table to Active.

    " 1. Select data from your Draft Table
    SELECT * FROM zquiz_sess_d INTO TABLE @DATA(lt_draft_sessions).

    IF lt_draft_sessions IS NOT INITIAL.
      " 2. Map Draft structure to Active Table structure and PERSIST
      DATA lt_active TYPE TABLE OF zquiz_session.
      lt_active = CORRESPONDING #( lt_draft_sessions MAPPING
                                   session_uuid = sessionuuid
                                   user_id      = userid
                                   topic_id     = topicid
                                   status       = status
                                   current_band = currentband ).

      MODIFY zquiz_session FROM TABLE @lt_active.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
