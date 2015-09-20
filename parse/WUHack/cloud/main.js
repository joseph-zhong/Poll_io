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
            console.log("parsed");
            var entities = json.entities;
            var Alchemy = Parse.Object.extend("Alchemy");
            var Entity = Parse.Object.extend("Entities")
            var object = new Alchemy();
            object.set("body", json.text)
            object.save(null, {
            success: function(object) {
              for(var i = 0; i < entities.length; i++){
                var current = entities[i];
                console.log("hi1");
                var parsedcurrent = JSON.parse(current);
                console.log("hi2");
                var newentitity = new Entity();
                console.log("new entity");
                newentitity.set("name", parsedcurrent.text);
                newentitity.set("relevance", parsedcurrent.relevance);
                var parsedsent = JSON.parse(parsedcurrent.sentiment);
                console.log("second parse");
                newentitity.set("score", parsedsent.score);
                newentitity.set("Alchemy", object);
                console.log(newentitity);
                newentitity.save(null, {
                  success: function(object){

                  },
                  error: function(object, error){
                    alert('Failed to create new object, with error code: ' + error.message); 
                  }
                });
              }
            },
            error: function(object, error) {
              alert('Failed to create new object, with error code: ' + error.message);
            }
          });

            console.log(entities);
            response.success(alchemyResponse);
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

Parse.Cloud.beforeSave("Response", function(request, response) {
    var twilio_id = request.object.twilio_id;
    var Response = Parse.Object.extend("Response");
    var query = new Parse.Query(Response);
    query.equalTo("twilio_id", twilio_id);
    query.find({
      success: function(results) {
          if (results.length === 0) {
              response.success();
          }
          else {
              response.error("Response already exists");
         }
      },
      error: function(error) {
          response.error();
      }
  });
});


Parse.Cloud.afterSave("Alchemy", function(request, response){
  //parsing for webapp here
})

