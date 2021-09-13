if (process.env.NODE_ENV !== 'production') {
	require('dotenv').config();
}
var express = require("express");

const bcrypt = require('bcryptjs');
const saltRounds = 10;

var app = express(),
	mysql = require('mysql'),
	bodyParser = require('body-parser');

const dbusername = process.env.DB_USER;
const dbpassword = process.env.DB_PASS;
const dbhost = process.env.DB_DBHOST;
const dbport = process.env.DB_DBPORT;
const dbname = process.env.DB_NAME;

connection = mysql.createConnection({
	host: dbhost,
	user: dbusername,
	password: dbpassword,
	database: dbname
});

app.use(bodyParser.json());

app.post('/auth', function (request, response) {
	var username = request.body.username;
	var password = request.body.password;

	if (username && password) {
		connection.query('SELECT * FROM account WHERE email = ?', [username], function (error, results, fields) {
			if (results.length > 0) {
					// if res == true, password matched
					// else wrong password
				if(bcrypt.compareSync(password,results[0].password)){  
					return response.status(200).json({
						email: results[0].email,
						name: results[0].name,
						participantType: results[0].participantType,
						city: results[0].city,
						participantAddress: results[0].participantAddress,
						userID: results[0].userID,
						token: '',
						message: 'Login Successful',
						});
				}
			}
			return response.status(401).json({
					message: 'Incorrect username/password',
					});
		
		});
	} else {
		return response.status(401).json({
			message: 'Username and Password is required',
		});
	}
});

const account = require('./models/account');
const product = require('./models/product');
const transaction = require('./models/transaction');
const token = require('./models/erc20token.js');

app.use('/account', account);
app.use('/product', product);
app.use('/transaction', transaction);
app.use('/token', token);

module.exports = app;