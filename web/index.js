/**
 * Created by Joseph on 10/9/15.
 */
var express = require('express'),
    app = express(),
    cons = require('consolidate'),
    mongoClient = require('mongodb').MongoClient,
    ObjectID = require('mongodb').ObjectID,
    Server = require('mongodb').Server;

/**
 * MongoDB Endpoints
 * to be determined by the aws config stuffs
 * @type {string}
 */
var MONGOLAB_ENDPOINT = '',
    PORT = '',
    DB = '';

//initialize twilio client
var client = require('twilio')('ACce74634b53fda11e3948c74211d8e8f8', '0195f254440349851c19c169234ac873');
var twilionumber = '+15745164355'

/**
 * URL specifying Alchemy API
 * @type {string}
 */
var ALCHEMY_URL = 'http://gateway-a.watsonplatform.net/';

/**
 * Our API Key for Alchemy
 * @type {string}
 */
var APIKEY  = '782cd262fac787868506f9351c4c2945f737f6a0';

// app setup
app.engine('html', cons.swig);
app.set('view engine', 'html');
app.set('views', __dirname + '/views');

// intialize a global to handle MongoDB database calls
var mongoDatabase;

// connect to our MongoDB
mongoClient.connect(MONGOLAB_ENDPOINT + ':' + PORT + '/' + DB, function(err, db)
{
    if(err)
    {
        console.log('err: ' + err);
    }
    mongoDatabase = db;
    console.log('connected to db: ' + db);

    // after db connection, put online
    // dynamic port
    app.listen(process.env.PORT || 8080);
    console.log('Express server started on port 8080 or ' + process.env.PORT);
});
