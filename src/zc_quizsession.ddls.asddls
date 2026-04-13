@EndUserText.label: 'Quiz Session - Consumption'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_QuizSession
  provider contract transactional_query
  as projection on ZI_QuizSession
{
    key SessionUuid,
    UserId,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_QuizTopic', element: 'TopicId' } }]
    TopicId,
    _Topic.Title as TopicTitle,
    Status,
    CurrentBand,
    TotalScore,
    QuestionsAnswered,
    LocalLastChangedAt,
    _Responses : redirected to composition child ZC_QuizUserResp
}
