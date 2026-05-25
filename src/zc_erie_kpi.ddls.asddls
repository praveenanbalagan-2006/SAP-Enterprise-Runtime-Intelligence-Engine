@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ERIE KPI Dashboard'
@Metadata.allowExtensions: true

define view entity ZC_ERIE_KPI
  as select from zerie_workflow
{

  key request_id,

  department,

  priority,

  risk_level,

  queue_load,

  delay_hours,

  runtime_score,

  ai_confidence_score,

  forecast_load,

  execution_state,

  case
    when queue_load > 85 then 3
    when queue_load > 60 then 2
    else 1
  end as RiskCriticality

}
