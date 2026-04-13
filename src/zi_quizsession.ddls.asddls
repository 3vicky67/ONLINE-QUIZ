@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Quiz Session - Interface'
define root view entity ZI_QuizSession
  as select from zquiz_session
  composition [0..*] of ZI_QuizUserResp as _Responses
  association [1..1] to ZI_QuizTopic    as _Topic on $projection.TopicId = _Topic.TopicId
{
  key session_uuid          as SessionUuid,
      user_id               as UserId,
      topic_id              as TopicId,
      status                as Status,
      current_band          as CurrentBand,
      total_score           as TotalScore,
      questions_answered    as QuestionsAnswered,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Responses,
      _Topic
}
