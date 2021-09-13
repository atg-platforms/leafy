const express = require('express');
const app = express();
const Web3 = require('web3');
const supplyChainABI = require('./supplyChain.json');
const Tx = require('ethereumjs-tx');

// 1. Connect to Kaleido Blockchain
const WEB3_USER = process.env.WEB3_USER;
const WEB3_PASSWORD = process.env.WEB3_PASSWORD;
const WEB3_PROVIDER = process.env.WEB3_PROVIDER;
const signer = process.env.signer;
const signerKey = Buffer.from(process.env.signerKey,'hex');
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

async function addParticipant(p_participantType){
    console.log("Adding new participant:");

    var userId;

    const ethUser = web3.eth.accounts.create();

    try {
        const txData = supplyChainContract.methods.addParticipant(ethUser.address, p_participantType).encodeABI();
        transfer = await buildSendTransaction(signer, signerKey, txData);
        await supplyChainContract.methods.addParticipant(ethUser.address, p_participantType).call()
            .then(function (uid) { userId = uid - 1; });
    } catch (error) {
        console.error(error);
        return res.status(500).json({
            message: 'Server Error'
        });
    }
    return [ethUser.address,userId];
}

async function addProduct(p_farmer, p_plantType, p_unitCost){
        console.log("Adding new product:");
        console.log([p_farmer, p_plantType, p_unitCost]);
    
        var prodId;
    
        try {
                const txData = supplyChainContract.methods.addProduct(p_farmer, p_plantType, p_unitCost).encodeABI();
                transfer = await buildSendTransaction(signer, signerKey, txData);
                prodId = await supplyChainContract.methods.product_id().call() - 1;
            } catch (error) {
                console.error(error);
            return res.status(500).json({
                message: 'Server Error'
            });
        }
        
            return prodId;
}

async function newOwner(productId,requestingId,newOwnerId){
            console.log("Setting new owner:");
            console.log([productId,requestingId,newOwnerId]);
        
            var returnStmt;
            var latestOwnership;
            var ownerId;
            var ownerAddress;
        
            // get latest ownershipId
            try{
                await supplyChainContract.methods.getProvenance(productId).call()
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
            if (ownerId === requestingId){
                // set new owner
                try{
                    const txData = supplyChainContract.methods.newOwner(requestingId, newOwnerId,productId).encodeABI();
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
    
}

// get participant details
async function getParticipant(p_participantId) {
    console.log("getting details of: " + p_participantId);
    const userDetails = await supplyChainContract.methods.getParticipant(p_participantId).call(); 

    return [p_participantId,userDetails[0],userDetails[1],'Successfully retrieved participant.'];
}

// get product details
async function getProduct(prodId){
    console.log("calling product details of: " + prodId);
    const prodDetails = await supplyChainContract.methods.getProductDetails(prodId).call(); 
    var date = new Date(prodDetails[4] * 1000);

    return [prodId,prodDetails[1],prodDetails[2],prodDetails[0],prodDetails[3],date]
    
}

module.exports = {
    addParticipant,
    addProduct,
    newOwner,
    getParticipant,
    getProduct
}