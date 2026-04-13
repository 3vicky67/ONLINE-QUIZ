@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Options - Master Data'
define view entity ZI_QuizAnswerOpt as select from zquiz_answ_opt
{
    key option_uuid as OptionUuid,
    question_uuid as QuestionUuid,
    option_text as OptionText,
    is_correct as IsCorrect
}
