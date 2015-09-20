//initialize twilio client
var client = require('twilio')('ACce74634b53fda11e3948c74211d8e8f8', 'ACce74634b53fda11e3948c74211d8e8f8');

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

Parse.Cloud.beforeSave("Poll", function(request, response){
  console.log("started");
  if(request.object.existed() == true)
  {
    //checks if the save makes a new object todo implement bool logic
    console.log("Page already Existed prior...exiting");
  }
  var channel = request.object.get("channel");
  var topic = request.object.get("topic");
  var senderphone = request.object.get("submitter").get("phonenumber");
  console.log(senderphone);
  channel.fetch({
    success: function(channelobject){
      console.log(channelobject);
      var userquery = new Parse.Query('Parse.User');
      //query.equalTo("Channels", channelobject.id);
      userquery.find({
        success: function(results) {
            console.log('hello')
            // console.log('results');
            // for(var i = 0; i < results.length; i++){
            //   var userobj = results[i];
            //   var phonenum = userobj.get('phonenumber');
            //   console.log(phonenum);
            //   if(phonenum == senderphone)
            //   {
            //     continue;
            //   }
            //   client.sendSms({
            //     to: phonenum,
            //     from: senderphone,
            //     body: topic
            //   }, function(err, responseData) {
            //       if (err) {
            //         console.log(err);
            //       }
            //       else {
            //         console.log(responseData.body);
            //       }
            //     });
            //   }
            //   response.success();
          },
          error: function(error){
            console.log(error);
          }
        })
        response.success();
      },
      error: function(error){
        console.log(error);
        response.error(error);
      }
    })
})
