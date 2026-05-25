@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ERIE Runtime Interface'
@Metadata.allowExtensions: true

define root view entity ZI_ERIE_RUNTIME
  as select from zerie_workflow
{

  key request_id            as RequestId,

  department                as Department,
  request_type              as RequestType,
  priority                  as Priority,

  amount                    as Amount,

  status                    as Status,
cast( 'INR' as abap.cuky ) as CukyField,
  execution_state           as ExecutionState,

  queue_load                as QueueLoad,
  delay_hours               as DelayHours,

  congestion_level          as CongestionLevel,

  optimized_route           as OptimizedRoute,

  ai_recommendation         as AiRecommendation,

  runtime_score             as RuntimeScore,

  risk_level                as RiskLevel,

  next_best_action          as NextBestAction,

  runtime_prediction        as RuntimePrediction,

  ai_confidence_score       as AiConfidenceScore,

  alert_message             as AlertMessage,

  event_status              as EventStatus,

  forecast_load             as ForecastLoad,

  anomaly_detected          as AnomalyDetected,

  created_by                as CreatedBy,

  created_at                as CreatedAt,

  updated_at                as UpdatedAt

}
