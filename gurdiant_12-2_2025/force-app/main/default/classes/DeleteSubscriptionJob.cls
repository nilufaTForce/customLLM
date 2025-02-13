public without sharing  class DeleteSubscriptionJob implements Queueable, Database.AllowsCallouts {
    private String deleteUrl;
    private String accessToken;

    public DeleteSubscriptionJob(String deleteUrl, String accessToken) {
        this.deleteUrl = deleteUrl;
        this.accessToken = accessToken;
    }

    public void execute(QueueableContext context) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(deleteUrl);
        req.setMethod('DELETE');
        req.setHeader('Authorization', 'Bearer ' + accessToken);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 204) {
            System.debug('Subscription deleted successfully.');
        } else {
            System.debug('Error deleting subscription: ' + res.getBody());
        }
    }
}