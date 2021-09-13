const express = require('express');
const sc = require('./supplychain');
router = express.Router();

/*
/product/ 
returns available products to consumers
*/
router.get('/', function (req, res) {
    let sql = `select CONCAT(CAST(p.userID AS CHAR(10)),p.plantType) as pid, p.userID,name as farmer,p.plantType,SUM(quantity) as quantity,unitCost as unitcost,city,pt.image as img from account a inner join product p on a.userID = p.userID inner join plantType pt on pt.type=p.plantType where status=1 group by p.userID,name,p.plantType,city,image`;
    connection.query(sql, function (err, data, fields) {
        if (err) throw err;
        return res.status(200).json({
            data,
            message: "Product lists retrieved successfully"
        })
    })
});

/*
/product/details
returns details of a specific product
*/
router.get('/detail/:productId', async function (req, res) {
    var product = await sc.getProduct(req.params.productId);
    return res.status(200).json({
        productId:product[0],
        farmer:product[1],
        farmerAddress:product[2],
        plantType:product[3],
        unitCost:product[4],
        timeStamp:product[5],
        message: "Transaction lists retrieved successfully"
    })
});

/*
/product/inventory/
returns product inventory for a specific farmer
*/
router.get('/inventory/:farmerId', function (req, res) {
    let sql = `select CONCAT(CAST(p.userID AS CHAR(10)),p.plantType) as pid, p.userID,name as farmer,p.plantType,SUM(quantity) as quantity,city,pt.image as img from account a inner join product p on a.userID = p.userID inner join plantType pt on pt.type=p.plantType where status=1 and p.userID=? group by p.userID,name,p.plantType,city,image`;
    connection.query(sql,[req.params.farmerId], function (err, data, fields) {
        if (err) throw err;
        return res.status(200).json({
            data,
            message: "Inventory lists retrieved successfully"
        })
    })
});

/*
/product/create
*/
router.post('/create', async function (req, res) {
    for (let i = 1; i <= req.body.quantity; i++) {
        var productID = await sc.addProduct(req.body.farmer, req.body.plantType, req.body.unitCost);

        let sql = `INSERT INTO product(userID, plantType, description, quantity, productID, unitCost) VALUES (?)`;
        let values = [
            req.body.farmer,
            req.body.plantType,
            req.body.description,
            1,
            productID,
            req.body.unitCost
        ];

        connection.query(sql, [values], function (err, data, fields) {
            if (err) throw err;
        });
    }

    return res.status(201).json({
        farmer: req.body.farmer,
        plantType: req.body.plantType,
        quantity: req.body.quantity,
        message: 'Product added successfully',
    })

});

module.exports = router;