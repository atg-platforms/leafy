const express = require('express');
const sc = require('./supplychain');
router = express.Router();
const util = require('util');

/*
/transactions/
returns transactions for a specified user
*/
router.get('/:userId', function (req, res) {
    let sql = `select t.id as transactionid,DATE_FORMAT(date,"%c/%d/%Y") as date,a.name as farmer,t.status 
    from transaction t inner join transactionDetail td on t.id=td.transactionID inner join account a on a.userID = td.userID 
    where t.userID=? group by t.id,date,t.status order by transactionid desc`;

    connection.query(sql, [req.params.userId], function (err, data, fields) {
        if (err) throw err;
        return res.status(200).json({
            data,
            message: "Transaction lists retrieved successfully"
        })
    })
});

/*
/transaction/orders/
returns order for a specified farmer
*/
router.get('/order/:userId', function (req, res) {
    let sql = `select t.id as transactionid,DATE_FORMAT(date,"%c/%d/%Y") as date,a.name as customer,t.status 
    from transaction t inner join transactionDetail td on t.id=td.transactionID inner join account a on a.userID = t.userID 
    where td.userID=? group by t.id,date,t.status order by transactionid desc`;

    connection.query(sql, [req.params.userId], function (err, data, fields) {
        if (err) throw err;
        return res.status(200).json({
            data,
            message: "Transaction lists retrieved successfully"
        })
    })
});

/*
/transaction/checkout
checkout the content of a cart
*/
router.post('/checkout', async function (req, res) {
    consumerID = req.body.consumerID;
    farmerID = req.body.farmerID;
    plantType = req.body.plantType;
    quantity = req.body.quantity;

    const query = util.promisify(connection.query).bind(connection);


    var sql = `select * from product where userID=? and plantType=? and status=1`;
    const rows = await query(sql, [farmerID, plantType]);

    if (rows.length < quantity)
        return res.status(401).json({
            farmer: farmerID,
            plantType: plantType,
            quantity: quantity,
            message: 'Insufficient inventory',
        })
    sql = `INSERT INTO transaction(userID, status) VALUES (?)`;
    let values = [
        consumerID,
        'Ordered'
    ];

    var result = await query(sql, [values]);

    var transactionID = result.insertId;

    rows.forEach(async function (data, index) {
        if (index < quantity) {
            sql = `INSERT INTO transactionDetail(transactionID, userID, productID, status) VALUES (?)`;
            let values = [
                transactionID,
                farmerID,
                data['productID'],
                'Ordered'
            ];

            result = await query(sql, [values]);

            await sc.newOwner(data['productID'], farmerID, consumerID);

        }
    });
    return res.status(201).json({
        farmer: req.body.farmer,
        plantType: req.body.plantType,
        quantity: req.body.quantity,
        message: 'Checkout successful',
    })

});

module.exports = router;