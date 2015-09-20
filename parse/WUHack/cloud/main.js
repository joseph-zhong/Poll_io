//initialize twilio client
var client = require('twilio')('ACce74634b53fda11e3948c74211d8e8f8', '0195f254440349851c19c169234ac873');

var twilionumber = "+15745164355"


var ALCHEMY_URL = "http://gateway-a.watsonplatform.net/";
var APIKEY  = "782cd262fac787868506f9351c4c2945f737f6a0";

function isEmpty(obj) {
    return Object.keys(obj).length === 0;
}

// Send plaintext response to alchemy api and persist in database
Parse.Cloud.define("analyzeEntity", function(request, response) {
    var params = request.params;
    if (isEmpty(params) || !params.body) {
        response.error("Body cannot be empty");
    }
    else {
        console.log("Params provided");
        var textBody = params.body;
        var parsedtextBody = encodeURIComponent(textBody);
        console.log("textBody: " + parsedtextBody);
        Parse.Cloud.httpRequest({
            url: ALCHEMY_URL + "calls/text/TextGetRankedNamedEntities",
            params: {
                "apikey": APIKEY,
                "text": textBody,
                "outputMode": "json",
                "sentiment": 1, 
                "showSourceText": 1
            }
        }).then(function(alchemyResponse) {
            //console.log("Success: " + alchemyResponse);
            // console.log(alchemyResponse);
            console.log(alchemyResponse.text);
            var json = JSON.parse(alchemyResponse.text);
            var entities = json.entities;
            var Alchemy = Parse.Object.extend("Alchemy");
            var Entity = Parse.Object.extend("Entities");
            var alchobject = new Alchemy();
            alchobject.set("body", json.text)
            alchobject.save(null, {
              success: function(object) {
                for(var i = 0; i < entities.length; i++){
                  var current = entities[i];
                  var newentitity = new Entity();
                  newentitity.set("name", current.text);
                  newentitity.set("relevance", current.relevance);
                  var jobj = current.sentiment;
                  newentitity.set("score", jobj.score);
                  newentitity.set("Alchemy", object.id);
                  newentitity.save();
                }
              },
              error: function(gameScore, error) {
                // Execute any logic that should take place if the save fails.
              // error is a Parse.Error with an error code and message.
              alert('Failed to create new object, with error code: ' + error.message);
              }
          });
        }, function(alchemyResponse) {
            console.error("Failed with response: " + response.status);
            response.error("Alchemy API is unavailable");
        });
    }
});



Parse.Cloud.afterSave("Poll", function(request, response){
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
      var query = new Parse.Query('UserChannels');
      query.equalTo("Channels", channelobject.id);
      query.find({
        success: function(results) {
            console.log(results);
            for(var i = 0; i < results.length; i++){
              var userobj = results[i];
              var phonenum = userobj.get('phonenumber');
              console.log(phonenum);
              if(phonenum == senderphone)
              {
                continue;
              }
              client.sendSms({
                to: phonenum,
                from: twilionumber,
                body: topic
              }, function(err, responseData) {
                  if (err) {
                    console.log(err);
                  }
                  else {
                    console.log(responseData.body);
                  }
                });
              }
          },
          error: function(error){
            console.log(error);
          }
        });
      },
      error: function(error){
        console.log(error);
      }
    });
});

Parse.Cloud.afterSave("Response", function(request, response){
  var body = request.object.get("body");
  console.log(body);
  Parse.Cloud.run("analyzeEntity", { "body" : body }, {
    success: function(response) {
    },
    error: function(error) {
    }
  });
});

//note if things are being saved synchronously as this goes it will not work
Parse.Cloud.beforeSave("Response", function(request, response) {
    var responsequery = new Parse.Query("Response");
    var twilio_id = request.object.get("twilio_id");
    console.log(twilio_id);
    var Response = Parse.Object.extend("Response");
    responsequery.equalTo("twilio_id", twilio_id);
    responsequery.first({
      success: function(object) {
          if (object) {
              console.log("object found");
              response.error("Response already exists");
          }
          else {
              response.success();
         }
      },
      error: function(error) {
          response.error("An error occured");
      }
  });
});

