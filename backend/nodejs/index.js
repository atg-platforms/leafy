var express = require("express");
var app = express(),
    mysql = require('mysql'),
    bodyParser = require('body-parser');

const username = process.env.DB_USER || '';
const password = process.env.DB_PASS || '';
const dbhost = process.env.DB_DBHOST || ';
const dbport = process.env.DB_DBPORT || '';
const dbname = process.env.DB_NAME || '';

db = mysql.createConnection({
host: dbhost,
user: username,
password: password,
database: dbname
});

const accountsRouter = require('./routes/accounts');
const transactionsRouter = require('./routes/transactions');

app.use(bodyParser.json());

app.use('/accounts', accountsRouter);
app.use('/transactions', transactionsRouter);
app.use('/coins', erc20tokenRouter);




app.listen(3000, () => {
    console.log("Server running on port 3000");
});