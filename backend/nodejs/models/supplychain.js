const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;
const Web3 = require('web3');
const router = express.Router();
const supplyChainABI = require('./supplyChain.json');
const Tx = require('ethereumjs-tx');

// 1. Connect to Kaleido Blockchain
const WEB3_USER = process.env.WEB3_USER;
const WEB3_PASSWORD = process.env.WEB3_PASSWORD;
const WEB3_PROVIDER = process.env.WEB3_PROVIDER;
const signer = process.env.signer;
const signerKey = Buffer.from('process.env.signerKey','hex');
const contractAddress = process.env.supplyChainContractAddress;

var transfer = '';
const web3 = new Web3(new Web3.providers.HttpProvider(`https://${WEB3_USER}:${WEB3_PASSWORD}@${WEB3_PROVIDER}`));

//2. Validate Connection
web3.eth.net.isListening() //Promise
.then(() => console.log('Connected to supply chain'))
.catch((err) => console.log(err));

web3.eth.accounts.create();


// update endpoint

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

// search available products by farmer, returns array of product id.
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

// set new owner (farmer-consumer). checks if request is by current owner then creates new ownership
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
            ownerAddress=stmt[2];
        });
    } catch (error) {
    console.error(error);
    return res.status(500).json({
        message: 'Server Error when getting latest owner ID'
    });
    }

    //compare current owner and requestingId in request
    if (ownerId === req.body.requestingId){
        // set new owner
        try{
            const txData = supplyChainContract.methods.newOwner(req.body.requestingId, req.body.newOwnerId,req.body.productId).encodeABI();
            transfer = await buildSendTransaction(signer, signerKey, txData);
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
router.post('/addParticipant', async (req, res) => {
    console.log("Adding new participant:");
    console.log(req.body);

    var userId;

    const ethUser = web3.eth.accounts.create();

    try{
        const txData = supplyChainContract.methods.addParticipant(ethUser.address, req.body.type).encodeABI();
        transfer = await buildSendTransaction(signer, signerKey, txData);
        await supplyChainContract.methods.addParticipant(ethUser.address, req.body.type).call()
        .then(function(uid){userId=uid-1;});
    } catch (error) {
    console.error(error);
    return res.status(500).json({
        message: 'Server Error'
    });
    }

    res.status(201).json({
        message: 'Successfully added participant!',
        txHash: transfer,
        address: ethUser.address,
        participantType: req.body.type,
        userId: userId,
    });
});

// add new Product
router.post('/addProduct', async (req, res) => {
    console.log("Adding new product:");
    console.log(req.body);

    var prodId;

    try {
            const txData = supplyChainContract.methods.addProduct(req.body.farmer, req.body.plantType, req.body.unitCost).encodeABI();
            transfer = await buildSendTransaction(signer, signerKey, txData);
            prodId = await supplyChainContract.methods.product_id().call() - 1;
        } catch (error) {
            console.error(error);
        return res.status(500).json({
            message: 'Server Error'
        });
    }

    res.status(201).json({
        message: 'Successfully added new Product!',
        txHash: transfer,
        farmer: req.body.farmer,
        plantType: req.body.plantType,
        unitCost: req.body.unitCost,
        productId: prodId
    });

});

// send and sign transaction
async function buildSendTransaction(account, accountKey, data) {
    // FORM TRANSACTION
    const txParams = {
        from: account,
        nonce: await web3.eth.getTransactionCount(account),
        to: contractAddress,
        value: 0,
        gasLimit: web3.utils.toHex(10000000),//limit of gas willing to spend
        gasPrice: web3.utils.toHex(web3.utils.toWei('0','gwei')),//transaction fee
        data,
    };
    
    //BUILD TRANSACTION
    const tx = new Tx(txParams);
  
    //SIGN TRANSACTION
    tx.sign(accountKey);
    
    //GET RAW TRANSACTION
    const serializedTx = tx.serialize();
    const rawTx = '0x' + serializedTx.toString('hex');
    
    //SEND SIGNED TRANSACTION
    const transaction = await web3.eth.sendSignedTransaction(rawTx);
    console.log('Transaction Hash: ', transaction.transactionHash);
    return transaction.transactionHash;
  
  }

module.exports = router ;