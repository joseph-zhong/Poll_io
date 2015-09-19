var ALCHEMY_URL = "http://gateway-a.watsonplatform.net/";
var APIKEY  = "503b2b1e7803bf3be7e7eadad8ddf4b81abd822f";

function isEmpty(obj) {
    return Object.keys(obj).length === 0;
}

// Send plaintext response to alchemy api and persist in database
Parse.Cloud.define("analyzeResponse", function(request, response) {
    var params = request.params;
    if (isEmpty(params) || !params.body) {
        response.error("Body cannot be empty");
    }
    else {
        console.log("Params provided");
        var textBody = params.body;
        console.log("textBody: " + textBody);
        Parse.Cloud.httpRequest({
            url: ALCHEMY_URL + "calls/text/TextGetRankedNamedEntities",
            params: {
                "apikey":     APIKEY,
                "outputMode": "json",
                "text":       textBody,
                "sentiment":  1
            }
        }).then(function(alchemyResponse) {
            console.log("Success: " + alchemyResponse);
            console.log(alchemyResponse);
            console.log(alchemyResponse.data);
            response.success(alchemyResponse);
        }, function(alchemyResponse) {
            console.error("Failed with response: " + response.status);
            response.error("Alchemy API is unavailable");
        });
    }
});
