@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'TO KNOW ABOUT QUIZ'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_QuizTopic 
  as select from zquiz_topic
{
    key topic_id    as TopicId,
    title           as Title,
    description     as Description
}
