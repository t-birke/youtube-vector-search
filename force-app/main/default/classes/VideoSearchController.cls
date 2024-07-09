public with sharing class VideoSearchController {
    @AuraEnabled(cacheable=false)
    public static ConnectApi.CdpQueryOutputV2 query(String query) {
        ConnectApi.CdpQueryInput input;
        input = new ConnectApi.CdpQueryInput();
        String sql = 'select v.score__c Score__c, c.Chunk__c Chunk__c, r.video_id_c__c video_id_c__c FROM vector_search(table(video_transcript_c_Home_index__dlm),\'' +
            query +
            '\', \'\', 500) v JOIN video_transcript_c_Home_chunk__dlm c ON v.RecordId__c = c.RecordId__c JOIN video_transcript_c_Home__dlm r ON c.SourceRecordId__c = r.Id__c ORDER BY Score__c DESC LIMIT 5';
        input.sql = sql;
        return ConnectAPI.CdpQuery.queryAnsiSqlV2(input);
    }
}
