@EndUserText.label: 'User Response - Consumption'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_QuizUserResp
  as projection on ZI_QuizUserResp
{
    key ResponseUuid,
    SessionUuid,
    QuestionUuid,
    SelectedOpt,
    IsCorrect,
    DifficultyAtResp,
    _Session : redirected to parent ZC_QuizSession
}
