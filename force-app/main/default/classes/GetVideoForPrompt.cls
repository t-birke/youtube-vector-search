public class GetVideoForPrompt {
    @InvocableMethod(label='Get matching videos'
        description='find videos with timestamps that match the case description')
    public static List<Response> getVideos(List<Request> requests) {
        // Validate the expected number of requests as an input
        if (requests.size() != 1)
          throw new ListException('The requests list must contain one entry only');
		//get case record
		Case c = requests[0].c;
        //get search text
        String searchText = c.Description;//'how to create apex that you can use as action in copilot?';
        //get data graph
        ConnectApi.CdpQueryInput input;
        input = new ConnectApi.CdpQueryInput();
        String sql = 'select v.score__c Score__c, c.Chunk__c Chunk__c, r.video_id_c__c video_id_c__c FROM vector_search(table(Video_Content_small_chunks_vector__dlm),\'' +
            searchText +
            '\', \'\', 500) v JOIN Video_Content_small_chunks_chunk__dlm c ON v.RecordId__c = c.RecordId__c JOIN Video_Content__dlm r ON c.SourceRecordId__c = r.Id__c ORDER BY Score__c DESC LIMIT 5';
        input.sql = sql;
        ConnectApi.CdpQueryOutputV2 result = ConnectAPI.CdpQuery.queryAnsiSqlV2(input);
        
            
        //string responseData = '"json_blob__c": "{"ssot__Id__c":"02iWz0000000iHBIAY","ssot__Name__c":"Test Vehicle","KQ_Id__c":"","KQ_PrimaryContactId__c":"","KQ_SerialNumber__c":"","ssot__PrimaryContactId__c":"003Wz000001GNcpIAG","ssot__ProductCodeText__c":"AV1","ssot__PurchaseDate__c":"2024-02-29T00:00:00.000Z","ssot__SerialNumber__c":"WVWZZZ1JZ3W386752","ssot__UniqueIdentifier__c":"","ssot__AccountContact__dlm":[{"ssot__AccountId__c":"001Wz000002NLqcIAG","ssot__Id__c":"003Wz000001GNcpIAG","ssot__ContactEmailId__c":"003Wz000001GNcpIAG","KQ_AccountId__c":"","KQ_Id__c":"","KQ_ContactEmailId__c":"","KQ_MailingAddressId__c":"","ssot__MailingAddressId__c":"003Wz000001GNcpIAG","ssot__ContactPointEmail__dlm":[{"ssot__Id__c":"003Wz000001GNcpIAG","ssot__EmailAddress__c":"lbailey@example.com","KQ_Id__c":""}],"ssot__ContactPointAddress__dlm":[{"ssot__AddressLine1__c":"1 Market St","ssot__CityId__c":"San Francisco","ssot__Id__c":"003Wz000001GNcpIAG","ssot__CountryId__c":"US","KQ_Id__c":"","ssot__PostalCodeId__c":"94105","ssot__StateProvinceId__c":"CA"}]}]}"';
        
        List<Response> responses = new List<Response>();
        Response res = new Response();

        res.Prompt = JSON.Serialize(result.data).remove('\\');
        responses.add(res);
        return responses;
    }
    
      public class Request {
          @InvocableVariable(required=true)
          public User Sender;
          @InvocableVariable(required=true)
          public Contact Recipient;
          @InvocableVariable(required=true)
          public Case c;
      }
    
    public class Response {
        @InvocableVariable
        public String Prompt;
    }
}