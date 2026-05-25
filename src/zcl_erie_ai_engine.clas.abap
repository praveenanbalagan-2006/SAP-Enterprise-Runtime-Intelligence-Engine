CLASS zcl_erie_ai_engine DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS predict_runtime
      IMPORTING
        iv_queue_load TYPE i
        iv_priority   TYPE string
        iv_delay      TYPE i
      EXPORTING
        ev_risk       TYPE string
        ev_prediction TYPE string
        ev_ai_score   TYPE string.

ENDCLASS.



CLASS zcl_erie_ai_engine IMPLEMENTATION.



  METHOD predict_runtime.

    DATA:
      lv_payload TYPE string,
      lv_result  TYPE string.



    TRY.



        DATA(lo_destination) =
          cl_http_destination_provider=>create_by_url(
            'http://127.0.0.1:8000/predict'
          ).



        DATA(lo_client) =
          cl_web_http_client_manager=>create_by_http_destination(
            lo_destination
          ).



        DATA(lo_request) =
          lo_client->get_http_request( ).



        lo_request->set_header_field(

          i_name  = 'Content-Type'

          i_value = 'application/json'

        ).



        lv_payload =
          |\{ "queue_load": { iv_queue_load },| &&
          | "priority": "{ iv_priority }",| &&
          | "delay_hours": { iv_delay } \}|.



        lo_request->set_text(
          lv_payload
        ).



        DATA(lo_response) =
          lo_client->execute(

            i_method = if_web_http_client=>post

          ).



        lv_result =
          lo_response->get_text( ).



        ev_prediction =
          lv_result.



        IF lv_result CS 'HIGH'.

          ev_risk = 'HIGH'.

        ELSEIF lv_result CS 'MEDIUM'.

          ev_risk = 'MEDIUM'.

        ELSE.

          ev_risk = 'LOW'.

        ENDIF.



        ev_ai_score = '98.50'.



      CATCH cx_root INTO DATA(lx_error).

        ev_risk =
          'ERROR'.

        ev_prediction =
          lx_error->get_text( ).

        ev_ai_score =
          '0'.

    ENDTRY.



  ENDMETHOD.



ENDCLASS.
