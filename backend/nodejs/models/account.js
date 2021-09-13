const express = require('express');
const sc = require('./supplychain');
router = express.Router();

const bcrypt = require('bcryptjs');
const saltRounds = 10;

/*
/account/getParticipant/
returns details of an account
*/
router.get('/:userId', async function (req, res) {
  var participant = await sc.getParticipant(req.params.userId);
      return res.status(200).json({
          userId:participant[0],
          participantAddress:participant[1],
          participantType:participant[2],
          message: "Transaction lists retrieved successfully"
      })
});

/*
/accounts/create
*/
router.post('/create', async function (req, res) {
  var participantType = req.body.participantType;
  var participant = await sc.addParticipant(participantType);

  var pword = req.body.password;

  var salt = bcrypt.genSaltSync(10);
  var hash = bcrypt.hashSync(pword, salt);
        // Now we can store the password hash in db.

  let sql = `INSERT INTO account(email, password, name, participantType, city, participantAddress, userID) VALUES (?)`;
  let values = [
    req.body.email,
    hash,
    req.body.name,
    req.body.participantType,
    req.body.city,
    participant[0],
    participant[1],
  ];
  connection.query(sql, [values], function (err, data, fields) {
    if (err) throw err;
    return res.status(201).json({
      email: req.body.email,
      name: req.body.name,
      participantType: req.body.participantType,
      city: req.body.city,
      participantAddress: participant[0],
      userID: participant[1],
      message: 'Account created successfully',
    });
  })

});

module.exports = router;