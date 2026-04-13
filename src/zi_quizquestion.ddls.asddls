@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Questions - Master Data'
define view entity ZI_QuizQuestion as select from zquiz_question
  association [1..*] to ZI_QuizAnswerOpt as _Options on $projection.QuestionUuid = _Options.QuestionUuid
{
    key question_uuid as QuestionUuid,
    topic_id as TopicId,
    text as QuestionText,
    difficulty_band as DifficultyBand,
    success_rate as SuccessRate,
    _Options
}
