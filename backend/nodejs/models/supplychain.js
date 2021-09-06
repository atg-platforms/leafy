const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;
const Web3 = require('web3');
const router = express.Router();
const supplyChainABI = require('./supplyChain.json');
const chainUrl = 'HTTP://127.0.0.1:7545'; // change to your own chain url
const web3 = new Web3(chainUrl);

// update endpoint
const contractAddress = '0xC5A2Dc0EEB800FC88d36B7B472Fc0B3C8cb98F68'; // add contract address
const supplyChainContract = new web3.eth.Contract(
    supplyChainABI,
    contractAddress,
);

// search available products by plant type
router.get('/searchByType/:plantType', async (req, res) => {
    console.log("getting available " + req.params.plantType);
    var productsArr = [];
    const productsCount = await supplyChainContract.methods.product_id().call();
    for (let counter = 0; counter < productsCount; counter++){
        const products = await supplyChainContract.methods.getProductDetails(counter).call();

        const provenance = await supplyChainContract.methods.getProvenance(counter).call();
        if (provenance.length < 2 && products[0] == req.params.plantType){
            productsArr.push(counter);
        }
    }

    return res.status(200).json({
      message: 'Successfully retrieved available harvest.',
      productDetails: productsArr
    });
});

// search available products by farmer
router.get('/searchByFarmer/:farmerId', async (req, res) => {
    console.log("getting products available from farmer: " + req.params.farmerId);
    var productsArr = [];
    const productsCount = await supplyChainContract.methods.product_id().call();
    for (let counter = 0; counter < productsCount; counter++){
        const products = await supplyChainContract.methods.getProductDetails(counter).call();

        const provenance = await supplyChainContract.methods.getProvenance(counter).call();
        const latestOwnership = provenance[provenance.length-1];
        const ownership = await supplyChainContract.methods.getOwnershipDetails(latestOwnership).call();

        if (ownership[1] == req.params.farmerId){
            productsArr.push(counter);
        }
    }

    return res.status(200).json({
      message: 'Successfully retrieved available harvest.',
      productDetails: JSON.stringify(productsArr)
    });
});

// get ownership details, accepts ownershipId
router.get('/getOwnershipDetails/:ownershipId', async (req, res) => {
    console.log("getting details of ownershipId: " + req.params.ownershipId);
    const ownership = await supplyChainContract.methods.getOwnershipDetails(req.params.ownershipId).call();
    const ownedTimestamp = new Date(ownership[3] * 1000);

    return res.status(200).json({
      message: 'Successfully retrieved ownership details.',
      productId: ownership[0],
      ownerId: ownership[1],
      ownerAddress: ownership[2],
      timestamp: ownedTimestamp
    });
});

// get latest owner, returns participantId of owner
router.get('/getOwner/:productId', async (req, res) => {
    console.log("getting owner of: " + req.params.productId);
    const provenance = await supplyChainContract.methods.getProvenance(req.params.productId).call();
    const latestOwnership = provenance[provenance.length-1];
    const ownership = await supplyChainContract.methods.getOwnershipDetails(latestOwnership).call();

    return res.status(200).json({
      message: 'Successfully retrieved provenance.',
      ownerId: ownership[1]
    });
});

// get ownership movement details, returns ownershipId[]
router.get('/getProvenance/:productId', async (req, res) => {
    console.log("getting ownership movement details of: " + req.params.productId);
    const provenance = await supplyChainContract.methods.getProvenance(req.params.productId).call(); 

    return res.status(200).json({
      message: 'Successfully retrieved provenance.',
      ownershipTrail: provenance
    });
});

// get participant details
router.get('/participant/:participantId', async (req, res) => {
    console.log("getting details of: " + req.params.participantId);
    const userDetails = await supplyChainContract.methods.getParticipant(req.params.participantId).call(); 

    return res.status(200).json({
      message: 'Successfully retrieved participant.',
      participantId: req.params.participantId,
      address: userDetails[0],
      participantType: userDetails[1]
    });
});

// get product details
router.get('/getProduct/:prodId', async (req, res) => {
    console.log("calling product details of: " + req.params.prodId);
    const prodDetails = await supplyChainContract.methods.getProductDetails(req.params.prodId).call(); 
    var date = new Date(prodDetails[4] * 1000);

    return res.status(200).json({
        message: req.params.prodId + ' Product Details',
        id: req.params.prodId,
        farmer: prodDetails[1],
        farmerAddress: prodDetails[2],
        plantType: prodDetails[0],
        unitCost: prodDetails[3],
        timeStamp: date
    });
});

// set new owner (farmer-consumer). created new ownership
router.post('/newOwner', async (req, res) => {
    console.log("Setting new owner:");
    console.log(req.body);

    var returnStmt;
    var latestOwnership;
    var ownerId;
    var ownerAddress;

    // get latest ownershipId
    try{
        await supplyChainContract.methods.getProvenance(req.body.productId).call()
        .then(function(stmt){
            returnStmt=stmt;
            latestOwnership = returnStmt[returnStmt.length - 1];
        });
    } catch (error) {
    console.error(error);
    return res.status(500).json({
        message: 'Server Error when getting lastest ownership ID'
    });
    }

    // get partcipantId of latest ownership
    try{
        await supplyChainContract.methods.getOwnershipDetails(latestOwnership).call()
        .then(function(stmt){
            ownerId=stmt[1];
        });
    } catch (error) {
    console.error(error);
    return res.status(500).json({
        message: 'Server Error when getting latest owner ID'
    });
    }

    console.log(ownerId);
    console.log(req.body.oldOwnerId);

    //compare current owner and id1 in request
    if (ownerId === req.body.oldOwnerId){

        // get address of new owner of latest ownership
        try{
            await supplyChainContract.methods.getParticipant(req.body.oldOwnerId).call()
            .then(function(stmt){
                ownerAddress=stmt[0];
            });
        } catch (error) {
        console.error(error);
        return res.status(500).json({
            message: 'Server Error when getting address of last owner ID'
        });
        }

        // set new owner
        try{
            console.log(ownerAddress);
            await supplyChainContract.methods.newOwner(req.body.oldOwnerId,req.body.newOwnerId,req.body.productId).send({from: ownerAddress, gas: 6721975 });
        } catch (error) {
        console.error(error);
        return res.status(500).json({
            message: 'Server Error Unable to set new owner. '+error.message
        });
        }
    
        return res.status(201).json({
            message: 'Successfully set new owner!',

        });
    }

    return res.status(403).json({
        message: 'Transaction must be executed by owner.'
    });



});

// add new Participant
//QUESTION: .send before .call?
router.post('/addParticipant', async (req, res) => {
    console.log("Adding new participant:");
    console.log(req.body);

    var userId;
    const isAddressNotValid = req.body.address.length !== 42;

    if (isAddressNotValid === true) {
        return res.status(400).json({
        message: 'Invalid address.'
        });
    }

    try{
        await supplyChainContract.methods.addParticipant(req.body.address, req.body.type).send({from: req.body.address});
        await supplyChainContract.methods.addParticipant(req.body.address, req.body.type).call()
        .then(function(uid){userId=uid-1;});
    } catch (error) {
    console.error(error);
    return res.status(500).json({
        message: 'Server Error'
    });
    }

    res.status(201).json({
        message: 'Successfully added participant!',
        address: req.body.address,
        participantType: req.body.type,
        userId: userId,
    });
});

// add new Product
// QUESTION: send (out of gas) vs estimateGas?
router.post('/addProduct', async (req, res) => {
    console.log("Adding new product:");
    console.log(req.body);

    var prodId;

    try {
        await supplyChainContract.methods.addProduct(req.body.farmer, req.body.plantType, req.body.unitCost).send({from: req.body.address,gas: 6721975});
        await supplyChainContract.methods.addProduct(req.body.farmer, req.body.plantType, req.body.unitCost).call()
            .then(function(pid){prodId=pid-1;});
            console.log(prodId);
        } catch (error) {
            console.error(error);
        return res.status(500).json({
            message: 'Server Error'
        });
    }

    res.status(201).json({
        message: 'Successfully added new Product!',
        farmer: req.body.farmer,
        plantType: req.body.plantType,
        farmerAddress: req.body.address,
        unitCost: req.body.unitCost,
        productId: prodId
    });

});

module.exports = router ;