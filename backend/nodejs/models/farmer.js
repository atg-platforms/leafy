const express = require('express'),
router = express.Router();

/*
/farmers/
*/
router.get('/', function(req, res) {
  let sql = `select id,acct_number,acct_name,created_date,modified_date from account`;
  db.query(sql, function(err, data, fields) {
    if (err) throw err;
    res.json({
      status: 200,
      data,
      message: "Account lists retrieved successfully"
    })
  })
});

/*
/accounts/{acct number}
*/
router.get('/:id', function(req, res) {
  let sql = `select id,acct_number,acct_name,created_date,modified_date from account where id=?`;
  db.query(sql,[req.params.id], function(err, data, fields) {
    if (err) throw err;
    res.json({
      status: 200,
      data,
      message: "Account lists retrieved successfully"
    })
  })
});

/*
/accounts/create
*/
router.post('/create', function(req, res) {
  let sql = `INSERT INTO account(acct_number, acct_name) VALUES (?)`;
  let values = [
    req.body.acct_number,
    req.body.acct_name
  ];
  db.query(sql, [values], function(err, data, fields) {
    if (err) throw err;
    res.json({
      status: 200,
      message: "New account added successfully"
    })
  })
});

/*
/accounts/update
*/
router.post('/update', function(req, res) {
  let sql = `UPDATE account SET acct_name=? WHERE acct_number=?`;
  let acct_name = req.body.acct_name,
    acct_number = req.body.acct_number;

  db.query(sql, [acct_name,acct_number], function(err, data, fields) {
    if (err) throw err;
    res.json({
      status: 200,
      message: "Account updated successfully"
    })
  })
});

module.exports = router;