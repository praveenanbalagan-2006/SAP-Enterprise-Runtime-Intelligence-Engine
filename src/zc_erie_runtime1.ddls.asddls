@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ERIE Runtime Consumption'
@Metadata.allowExtensions: true

define root view entity ZC_ERIE_RUNTIME1
  provider contract transactional_query
  as projection on ZI_ERIE_RUNTIME
{
  @EndUserText.label: 'Request ID'
  key RequestId,
  
  @EndUserText.label: 'Department'
  Department,
  
  @EndUserText.label: 'Request Type'
  RequestType,
  
  @EndUserText.label: 'Priority'
  Priority,
  
  @EndUserText.label: 'Amount'
  Amount,
  
  @EndUserText.label: 'Status'
  Status,
  
  @EndUserText.label: 'Execution State'
  ExecutionState,
  
  @EndUserText.label: 'Queue Load'
  QueueLoad,
  
  @EndUserText.label: 'Delay Hours'
  DelayHours,
  
  CukyField,
  
  @EndUserText.label: 'Congestion Level'
  CongestionLevel,
  
  @EndUserText.label: 'Optimized Route'
  OptimizedRoute,
  
  @EndUserText.label: 'AI Recommendation'
  AiRecommendation,
  
  @EndUserText.label: 'Runtime Score'
  RuntimeScore,
  
  @EndUserText.label: 'Risk Level'
  RiskLevel,
  
  @EndUserText.label: 'Next Best Action'
  NextBestAction,
  
  @EndUserText.label: 'Runtime Prediction'
  RuntimePrediction,
  
  @EndUserText.label: 'AI Confidence Score'
  AiConfidenceScore,
  
  @EndUserText.label: 'Alert Message'
  AlertMessage,
  
  @EndUserText.label: 'Event Status'
  EventStatus,
  
  @EndUserText.label: 'Forecast Load'
  ForecastLoad,
  
  @EndUserText.label: 'Anomaly Detected'
  AnomalyDetected,
  
  CreatedBy,
  CreatedAt,
  UpdatedAt
}
