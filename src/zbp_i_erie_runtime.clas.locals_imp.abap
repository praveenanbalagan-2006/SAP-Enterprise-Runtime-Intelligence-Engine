
CLASS lhc_zi_erie_runtime DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS optimizeexecution
      FOR MODIFY
      IMPORTING keys FOR ACTION zi_erie_runtime~optimizeexecution.

    METHODS balanceruntimeload
      FOR MODIFY
      IMPORTING keys FOR ACTION zi_erie_runtime~balanceruntimeload.

    METHODS assignbackupapprover
      FOR MODIFY
      IMPORTING keys FOR ACTION zi_erie_runtime~assignbackupapprover.

    METHODS enablefasttrack
      FOR MODIFY
      IMPORTING keys FOR ACTION zi_erie_runtime~enablefasttrack.

    METHODS triggeraianalysis
      FOR MODIFY
      IMPORTING keys FOR ACTION zi_erie_runtime~triggeraianalysis.

    METHODS generateforecast
      FOR MODIFY
      IMPORTING keys FOR ACTION zi_erie_runtime~generateforecast.

    METHODS generatedemodata
      FOR MODIFY
      IMPORTING keys FOR ACTION zi_erie_runtime~generatedemodata.

METHODS autooptimize
  FOR DETERMINE ON MODIFY
  IMPORTING keys FOR zi_erie_runtime~autooptimize.

METHODS validatepriority
  FOR VALIDATE ON SAVE
  IMPORTING keys FOR zi_erie_runtime~validatepriority.
METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
  IMPORTING REQUEST requested_authorizations FOR zi_erie_runtime RESULT result.
ENDCLASS.



CLASS lhc_zi_erie_runtime IMPLEMENTATION.

  METHOD optimizeexecution.

  READ ENTITIES OF zi_erie_runtime IN LOCAL MODE
    ENTITY zi_erie_runtime
    FIELDS (
      QueueLoad
      Priority
    )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_runtime).

  DATA lt_update TYPE TABLE FOR UPDATE zi_erie_runtime.

  LOOP AT lt_runtime INTO DATA(ls_runtime).

    DATA(lv_state) = 'NORMAL'.
    DATA(lv_route) = 'STANDARD_ROUTE'.

    IF ls_runtime-QueueLoad >= 500.

      lv_state = 'CRITICAL_OPTIMIZED'.
      lv_route = 'FAST_TRACK_ROUTE'.

    ELSEIF ls_runtime-QueueLoad >= 200.

      lv_state = 'BALANCED'.
      lv_route = 'SMART_DYNAMIC_ROUTE'.

    ENDIF.

    APPEND VALUE #(
      %tky           = ls_runtime-%tky
      ExecutionState = lv_state
      OptimizedRoute = lv_route
    ) TO lt_update.

  ENDLOOP.

  MODIFY ENTITIES OF zi_erie_runtime IN LOCAL MODE
    ENTITY zi_erie_runtime
    UPDATE FIELDS (
      ExecutionState
      OptimizedRoute
    )
    WITH lt_update.

ENDMETHOD.

  METHOD balanceruntimeload.

  READ ENTITIES OF zi_erie_runtime IN LOCAL MODE
    ENTITY zi_erie_runtime
    FIELDS ( QueueLoad )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_runtime).

  DATA lt_update TYPE TABLE FOR UPDATE zi_erie_runtime.

  LOOP AT lt_runtime INTO DATA(ls_runtime).

    DATA(lv_load) = ls_runtime-QueueLoad.
    DATA(lv_congestion) = 'LOW'.

    IF lv_load > 500.

      lv_load = 250.
      lv_congestion = 'CRITICAL'.

    ELSEIF lv_load > 200.

      lv_load = 120.
      lv_congestion = 'MEDIUM'.

    ENDIF.

    APPEND VALUE #(
      %tky            = ls_runtime-%tky
      QueueLoad       = lv_load
      CongestionLevel = lv_congestion
    ) TO lt_update.

  ENDLOOP.

  MODIFY ENTITIES OF zi_erie_runtime IN LOCAL MODE
    ENTITY zi_erie_runtime
    UPDATE FIELDS (
      QueueLoad
      CongestionLevel
    )
    WITH lt_update.

ENDMETHOD.
  METHOD autooptimize.

  MODIFY ENTITIES OF zi_erie_runtime IN LOCAL MODE
    ENTITY zi_erie_runtime
    UPDATE FIELDS (
      ExecutionState
      CongestionLevel
    )
    WITH VALUE #(
      FOR key IN keys (
        %tky            = key-%tky
        ExecutionState  = 'AUTO_OPTIMIZED'
        CongestionLevel = 'AI_MONITORING'
      )
    ).

ENDMETHOD.
METHOD validatepriority.

  READ ENTITIES OF zi_erie_runtime IN LOCAL MODE
    ENTITY zi_erie_runtime
    FIELDS ( Priority )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

  LOOP AT lt_data INTO DATA(ls_data).

    IF ls_data-Priority IS INITIAL.

      APPEND VALUE #(
        %tky = ls_data-%tky
      ) TO failed-zi_erie_runtime.

      APPEND VALUE #(
        %tky = ls_data-%tky
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'Priority cannot be empty'
        )
      ) TO reported-zi_erie_runtime.

    ENDIF.

  ENDLOOP.

ENDMETHOD.

  METHOD assignbackupapprover.
    MODIFY ENTITIES OF zi_erie_runtime IN LOCAL MODE
      ENTITY zi_erie_runtime
      UPDATE FIELDS (
        NextBestAction
      )
      WITH VALUE #(
        FOR key IN keys (
          %tky           = key-%tky
          NextBestAction = 'BACKUP_APPROVER'
        )
      ).
  ENDMETHOD.

  METHOD enablefasttrack.
    MODIFY ENTITIES OF zi_erie_runtime IN LOCAL MODE
      ENTITY zi_erie_runtime
      UPDATE FIELDS (
        ExecutionState
      )
      WITH VALUE #(
        FOR key IN keys (
          %tky           = key-%tky
          ExecutionState = 'FAST_TRACK_ENABLED'
        )
      ).
  ENDMETHOD.
METHOD triggeraianalysis.

  DATA:
    lt_update      TYPE TABLE FOR UPDATE zi_erie_runtime,
    lv_risk        TYPE string,
    lv_prediction  TYPE string,
    lv_score       TYPE string,
    lv_state       TYPE string,
    lv_route       TYPE string,
    lv_forecast    TYPE i,
    lv_anomaly     TYPE string,
    lv_congestion  TYPE string.

  READ ENTITIES OF zi_erie_runtime IN LOCAL MODE
    ENTITY zi_erie_runtime
    FIELDS (
      QueueLoad
      DelayHours
      Priority
    )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_runtime).

  LOOP AT lt_runtime INTO DATA(ls_runtime).

    CLEAR:
      lv_risk,
      lv_prediction,
      lv_score,
      lv_state,
      lv_route,
      lv_forecast,
      lv_anomaly,
      lv_congestion.

    IF ls_runtime-QueueLoad >= 500
       OR ls_runtime-DelayHours >= 10.

      lv_risk       = 'HIGH'.
      lv_prediction = 'SLA_RISK'.
      lv_score      = '98.50'.
      lv_state      = 'CRITICAL_OPTIMIZED'.
      lv_route      = 'FAST_TRACK_ROUTE'.
      lv_forecast   = 600.
      lv_anomaly    = 'YES'.
      lv_congestion = 'CRITICAL'.

    ELSEIF ls_runtime-QueueLoad >= 200.

      lv_risk       = 'MEDIUM'.
      lv_prediction = 'PERFORMANCE_WARNING'.
      lv_score      = '89.20'.
      lv_state      = 'MONITORING'.
      lv_route      = 'SMART_DYNAMIC_ROUTE'.
      lv_forecast   = 300.
      lv_anomaly    = 'NO'.
      lv_congestion = 'MEDIUM'.

    ELSE.

      lv_risk       = 'LOW'.
      lv_prediction = 'STABLE'.
      lv_score      = '82.10'.
      lv_state      = 'NORMAL'.
      lv_route      = 'STANDARD_ROUTE'.
      lv_forecast   = 120.
      lv_anomaly    = 'NO'.
      lv_congestion = 'LOW'.

    ENDIF.

    APPEND VALUE #(
      %tky               = ls_runtime-%tky
      RiskLevel          = lv_risk
      RuntimePrediction  = lv_prediction
      AiConfidenceScore  = lv_score
      ExecutionState     = lv_state
      OptimizedRoute     = lv_route
      ForecastLoad       = lv_forecast
      AnomalyDetected    = lv_anomaly
      CongestionLevel    = lv_congestion
    ) TO lt_update.

  ENDLOOP.

  MODIFY ENTITIES OF zi_erie_runtime IN LOCAL MODE
    ENTITY zi_erie_runtime
    UPDATE FIELDS (
      RiskLevel
      RuntimePrediction
      AiConfidenceScore
      ExecutionState
      OptimizedRoute
      ForecastLoad
      AnomalyDetected
      CongestionLevel
    )
    WITH lt_update.

ENDMETHOD.
METHOD generateforecast.

  READ ENTITIES OF zi_erie_runtime IN LOCAL MODE
    ENTITY zi_erie_runtime
    FIELDS ( QueueLoad )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_runtime).

  DATA lt_update TYPE TABLE FOR UPDATE zi_erie_runtime.

  LOOP AT lt_runtime INTO DATA(ls_runtime).

    DATA(lv_forecast) = ls_runtime-QueueLoad + 20.
    DATA(lv_anomaly) = 'NO'.

    IF lv_forecast > 500.
      lv_anomaly = 'YES'.
    ENDIF.

    APPEND VALUE #(
      %tky            = ls_runtime-%tky
      ForecastLoad    = lv_forecast
      AnomalyDetected = lv_anomaly
    ) TO lt_update.

  ENDLOOP.

  MODIFY ENTITIES OF zi_erie_runtime IN LOCAL MODE
    ENTITY zi_erie_runtime
    UPDATE FIELDS (
      ForecastLoad
      AnomalyDetected
    )
    WITH lt_update.

ENDMETHOD.
  METHOD generatedemodata.
    " In RAP, factory/demo data creation should be executed using standard
    " business entity creation mechanics via EML MODIFY ENTITIES
    MODIFY ENTITIES OF zi_erie_runtime IN LOCAL MODE
      ENTITY zi_erie_runtime
      CREATE FIELDS (
        RequestId Department RequestType Priority Amount Status
        ExecutionState QueueLoad DelayHours CongestionLevel OptimizedRoute
        AiRecommendation RuntimeScore RiskLevel NextBestAction
        RuntimePrediction AiConfidenceScore AlertMessage EventStatus
        ForecastLoad AnomalyDetected
      )
      WITH VALUE #(
        ( %cid                = 'DEMO_REQ001'
          RequestId           = 'REQ001'
          Department          = 'Finance'
          RequestType         = 'Invoice Approval'
          Priority            = 'HIGH'
          Amount              = '250000'
          Status              = 'OPEN'
          ExecutionState      = 'RUNNING'
          QueueLoad           = 92
          DelayHours          = 5
          CongestionLevel     = 'CRITICAL'
          OptimizedRoute      = 'BACKUP_APPROVER_ROUTE'
          AiRecommendation    = 'Enable Dynamic Rerouting'
          RuntimeScore        = '96.50'
          RiskLevel           = 'HIGH'
          NextBestAction      = 'FAST_TRACK'
          RuntimePrediction   = 'CONGESTION_RISK'
          AiConfidenceScore   = '98.10'
          AlertMessage        = 'Critical runtime congestion detected'
          EventStatus         = 'TRIGGERED'
          ForecastLoad        = 97
          AnomalyDetected     = 'YES' )

        ( %cid                = 'DEMO_REQ002'
          RequestId           = 'REQ002'
          Department          = 'HR'
          RequestType         = 'Recruitment Approval'
          Priority            = 'LOW'
          Amount              = '50000'
          Status              = 'OPEN'
          ExecutionState      = 'STABLE'
          QueueLoad           = 25
          DelayHours          = 1
          CongestionLevel     = 'LOW'
          OptimizedRoute      = 'NORMAL_FLOW'
          AiRecommendation    = 'No optimization required'
          RuntimeScore        = '88.00'
          RiskLevel           = 'LOW'
          NextBestAction      = 'NORMAL_PROCESSING'
          RuntimePrediction   = 'STABLE'
          AiConfidenceScore   = '91.50'
          AlertMessage        = 'Runtime stable'
          EventStatus         = 'NORMAL'
          ForecastLoad        = 35
          AnomalyDetected     = 'NO' )

        ( %cid                = 'DEMO_REQ003'
          RequestId           = 'REQ003'
          Department          = 'Procurement'
          RequestType         = 'Vendor Payment'
          Priority            = 'MEDIUM'
          Amount              = '120000'
          Status              = 'OPEN'
          ExecutionState      = 'WARNING'
          QueueLoad           = 67
          DelayHours          = 3
          CongestionLevel     = 'MEDIUM'
          OptimizedRoute      = 'SMART_DYNAMIC_ROUTE'
          AiRecommendation    = 'Enable Queue Balancing'
          RuntimeScore        = '90.20'
          RiskLevel           = 'MEDIUM'
          NextBestAction      = 'LOAD_BALANCING'
          RuntimePrediction   = 'WARNING'
          AiConfidenceScore   = '94.20'
          AlertMessage        = 'Runtime nearing congestion'
          EventStatus         = 'MONITORING'
          ForecastLoad        = 72
          AnomalyDetected     = 'NO' )

        ( %cid                = 'DEMO_REQ004'
          RequestId           = 'REQ004'
          Department          = 'IT Operations'
          RequestType         = 'Hardware Provisioning'
          Priority            = 'MEDIUM'
          Amount              = '75000'
          Status              = 'OPEN'
          ExecutionState      = 'RUNNING'
          QueueLoad           = 45
          DelayHours          = 2
          CongestionLevel     = 'LOW'
          OptimizedRoute      = 'NORMAL_FLOW'
          AiRecommendation    = 'Standard execution path'
          RuntimeScore        = '85.40'
          RiskLevel           = 'LOW'
          NextBestAction      = 'NONE'
          RuntimePrediction   = 'STABLE'
          AiConfidenceScore   = '89.00'
          AlertMessage        = 'Processing normally'
          EventStatus         = 'NORMAL'
          ForecastLoad        = 48
          AnomalyDetected     = 'NO' )

        ( %cid                = 'DEMO_REQ005'
          RequestId           = 'REQ005'
          Department          = 'Legal'
          RequestType         = 'Contract Review'
          Priority            = 'HIGH'
          Amount              = '0'
          Status              = 'OPEN'
          ExecutionState      = 'STALLED'
          QueueLoad           = 88
          DelayHours          = 24
          CongestionLevel     = 'CRITICAL'
          OptimizedRoute      = 'ESCALATION_ROUTE'
          AiRecommendation    = 'Assign Backup Approver'
          RuntimeScore        = '94.10'
          RiskLevel           = 'HIGH'
          NextBestAction      = 'BACKUP_APPROVER'
          RuntimePrediction   = 'SLA_VIOLATION'
          AiConfidenceScore   = '97.50'
          AlertMessage        = 'SLA threshold exceeded'
          EventStatus         = 'ALERT_RAISED'
          ForecastLoad        = 90
          AnomalyDetected     = 'YES' )

        ( %cid                = 'DEMO_REQ006'
          RequestId           = 'REQ006'
          Department          = 'Sales'
          RequestType         = 'Discount Approval'
          Priority            = 'HIGH'
          Amount              = '450000'
          Status              = 'OPEN'
          ExecutionState      = 'QUEUED'
          QueueLoad           = 78
          DelayHours          = 4
          CongestionLevel     = 'HIGH'
          OptimizedRoute      = 'FAST_TRACK_ROUTE'
          AiRecommendation    = 'Bypass Standard Validation'
          RuntimeScore        = '92.00'
          RiskLevel           = 'HIGH'
          NextBestAction      = 'FAST_TRACK'
          RuntimePrediction   = 'DELAY_RISK'
          AiConfidenceScore   = '95.00'
          AlertMessage        = 'High value item delayed in queue'
          EventStatus         = 'WARNING'
          ForecastLoad        = 82
          AnomalyDetected     = 'NO' )

        ( %cid                = 'DEMO_REQ007'
          RequestId           = 'REQ007'
          Department          = 'Logistics'
          RequestType         = 'Shipment Dispatch'
          Priority            = 'LOW'
          Amount              = '15000'
          Status              = 'CLOSED'
          ExecutionState      = 'COMPLETED'
          QueueLoad           = 12
          DelayHours          = 0
          CongestionLevel     = 'NONE'
          OptimizedRoute      = 'STANDARD_DEFAULT'
          AiRecommendation    = 'Archive record'
          RuntimeScore        = '99.10'
          RiskLevel           = 'LOW'
          NextBestAction      = 'ARCHIVE'
          RuntimePrediction   = 'COMPLETED'
          AiConfidenceScore   = '99.90'
          AlertMessage        = 'Execution successful'
          EventStatus         = 'SUCCESS'
          ForecastLoad        = 10
          AnomalyDetected     = 'NO' )

        ( %cid                = 'DEMO_REQ008'
          RequestId           = 'REQ008'
          Department          = 'R&D'
          RequestType         = 'Project Budget Extension'
          Priority            = 'MEDIUM'
          Amount              = '600000'
          Status              = 'OPEN'
          ExecutionState      = 'RUNNING'
          QueueLoad           = 55
          DelayHours          = 1
          CongestionLevel     = 'MEDIUM'
          OptimizedRoute      = 'SMART_DYNAMIC_ROUTE'
          AiRecommendation    = 'Monitor resource limits'
          RuntimeScore        = '87.30'
          RiskLevel           = 'MEDIUM'
          NextBestAction      = 'LOAD_BALANCING'
          RuntimePrediction   = 'STABLE'
          AiConfidenceScore   = '92.40'
          AlertMessage        = 'Normal load variance'
          EventStatus         = 'MONITORING'
          ForecastLoad        = 60
          AnomalyDetected     = 'NO' )

        ( %cid                = 'DEMO_REQ009'
          RequestId           = 'REQ009'
          Department          = 'Facilities'
          RequestType         = 'Lease Renewal'
          Priority            = 'LOW'
          Amount              = '90000'
          Status              = 'OPEN'
          ExecutionState      = 'SUSPENDED'
          QueueLoad           = 95
          DelayHours          = 48
          CongestionLevel     = 'CRITICAL'
          OptimizedRoute      = 'REROUTE_TO_POOL'
          AiRecommendation    = 'Purge deadlocks'
          RuntimeScore        = '97.80'
          RiskLevel           = 'HIGH'
          NextBestAction      = 'AUTO_OPTIMIZE'
          RuntimePrediction   = 'SYSTEM_STALL'
          AiConfidenceScore   = '98.90'
          AlertMessage        = 'System buffer deadlock detected'
          EventStatus         = 'CRITICAL_ERROR'
          ForecastLoad        = 99
          AnomalyDetected     = 'YES' )

        ( %cid                = 'DEMO_REQ010'
          RequestId           = 'REQ010'
          Department          = 'Marketing'
          RequestType         = 'Campaign Spend'
          Priority            = 'HIGH'
          Amount              = '180000'
          Status              = 'OPEN'
          ExecutionState      = 'RUNNING'
          QueueLoad           = 35
          DelayHours          = 0
          CongestionLevel     = 'LOW'
          OptimizedRoute      = 'NORMAL_FLOW'
          AiRecommendation    = 'Execute standard path'
          RuntimeScore        = '89.10'
          RiskLevel           = 'LOW'
          NextBestAction      = 'NONE'
          RuntimePrediction   = 'STABLE'
          AiConfidenceScore   = '94.00'
          AlertMessage        = 'Optimal execution metrics'
          EventStatus         = 'NORMAL'
          ForecastLoad        = 38
          AnomalyDetected     = 'NO' )
      ).
  ENDMETHOD.

METHOD get_global_authorizations.

  result-%create = if_abap_behv=>auth-allowed.
  result-%update = if_abap_behv=>auth-allowed.
  result-%delete = if_abap_behv=>auth-allowed.
  result-%action-OptimizeExecution = if_abap_behv=>auth-allowed.
  result-%action-TriggerAIAnalysis = if_abap_behv=>auth-allowed.

ENDMETHOD.

ENDCLASS.


