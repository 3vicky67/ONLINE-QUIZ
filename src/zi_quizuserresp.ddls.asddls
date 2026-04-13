@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'User Response - Interface'
define view entity ZI_QuizUserResp
  as select from zquiz_user_resp
  association to parent ZI_QuizSession as _Session on $projection.SessionUuid = _Session.SessionUuid
{
  key response_uuid      as ResponseUuid,
      session_uuid       as SessionUuid,
      question_uuid      as QuestionUuid,
      selected_opt       as SelectedOpt,
      is_correct         as IsCorrect,
      difficulty_at_resp as DifficultyAtResp,
      
      _Session
}
