@EndUserText.label: 'ERIE Analytics Dashboard'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Analytics.dataCategory: #CUBE
@Metadata.allowExtensions: true

define view entity ZC_ERIE_ANALYTICS
as select from zerie_workflow
{

  key request_id as RequestId,

  department as Department,

  priority as Priority,

  execution_state as ExecutionState,

  risk_level as RiskLevel,

  runtime_prediction as RuntimePrediction,

  queue_load as QueueLoad,

  delay_hours as DelayHours,

  ai_confidence_score as AiConfidenceScore,

  forecast_load as ForecastLoad,

  anomaly_detected as AnomalyDetected,

  alert_message as AlertMessage,

  case
    when queue_load > 500 then 'CRITICAL'
    when queue_load > 200 then 'WARNING'
    else 'STABLE'
  end as RuntimeHealth,

  case
    when queue_load > 500 then 1
    when queue_load > 200 then 2
    else 3
  end as RuntimeCriticality

}
