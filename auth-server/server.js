require('dotenv').load();

const express = require('express');
const bodyParser = require('body-parser');
const passport = require('passport');
const mongoose = require('mongoose');
const port = process.env.PORT || 3000;
const cors = require('cors');

const app = express();
app.use(cors());

// get our request parameters
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

// Use the passport package in our application
app.use(passport.initialize());
const passportMiddleware = require('./middleware/passport');
passport.use(passportMiddleware);

/*
app.get('/', function (req, res) {
    return res.send('Hello! The API is at http://localhost:' + port + '/api');
});
*/
const routes = require('./routes');
app.use('/', routes);

mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useCreateIndex: true });

const connection = mongoose.connection;

connection.once('open', () => {
    console.log('MongoDB database connection established successfully!');
});

connection.on('error', (err) => {
    console.log("MongoDB connection error. Please make sure MongoDB is running. " + err);
    process.exit();
});

// Start the server
app.listen(port);
console.log('Express auth server up and running');
