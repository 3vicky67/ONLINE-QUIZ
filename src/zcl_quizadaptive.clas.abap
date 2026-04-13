CLASS zcl_quizadaptive DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS calculate_performance
      IMPORTING
        iv_session_uuid TYPE sysuuid_x16
      EXPORTING
        ev_new_band     TYPE int1
        ev_new_score    TYPE int4.
ENDCLASS.

CLASS zcl_quizadaptive IMPLEMENTATION.
  METHOD calculate_performance.
    DATA: lv_correct_count TYPE i,
          lv_total_count   TYPE i,
          lv_current_band  TYPE int1.

    " Get current session state
    SELECT SINGLE current_band FROM zquiz_session
      WHERE session_uuid = @iv_session_uuid INTO @lv_current_band.

    " Calculate stats from responses
    SELECT COUNT( * ) FROM zquiz_user_resp
      WHERE session_uuid = @iv_session_uuid INTO @lv_total_count.

    SELECT COUNT( * ) FROM zquiz_user_resp
      WHERE session_uuid = @iv_session_uuid AND is_correct = @abap_true
      INTO @lv_correct_count.

    ev_new_score = lv_correct_count * 10.
    ev_new_band  = lv_current_band.

    " Adaptive Logic: Shift band after 3 questions based on 85% success rate
    IF lv_total_count >= 3.
      DATA(lv_ratio) = ( lv_correct_count * 100 ) / lv_total_count.
      IF lv_ratio >= 85 AND lv_current_band < 5.
        ev_new_band = lv_current_band + 1.
      ELSEIF lv_ratio < 75 AND lv_current_band > 1.
        ev_new_band = lv_current_band - 1.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
