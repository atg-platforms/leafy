if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}
const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;
const Web3 = require('web3');
const router = express.Router();
const coinsABI = require('./ERC20Token.json');
const Tx = require('ethereumjs-tx');

// 1. Connect to Kaleido Blockchain
const WEB3_USER = process.env.WEB3_USER;
const WEB3_PASSWORD = process.env.WEB3_PASSWORD;
const WEB3_PROVIDER = process.env.WEB3_PROVIDER;
const signer = process.env.signer;
const signerKey = Buffer.from('process.env.signerKey','hex');
const contractAddress = process.env.erc20ContractAddress;

var transfer = '';

const web3 = new Web3(new Web3.providers.HttpProvider(`https://${WEB3_USER}:${WEB3_PASSWORD}@${WEB3_PROVIDER}`));

// 2. Validate Connection
web3.eth.net.isListening() //Promise
.then(() => console.log('Connected to LFY token'))
.catch((err) => console.log(err))

// update endpoint
const coinsContract = new web3.eth.Contract(
    coinsABI,
    contractAddress,
);

// get $LFY balance of specific address
router.get('/balance/:address', async (req, res) => {
    console.log("calling balanceOf: " + req.params.address);
    const balance = await coinsContract.methods.balanceOf(req.params.address).call(); 

    return res.status(200).json({
      message: 'Successfully retrieved balance.',
      balance: balance,
    });
});

// get total $LFY balance
router.get('/total', async (req, res) => {
  console.log("calling totalSupply");
  const totalSupply = await coinsContract.methods.totalSupply().call(); 

  return res.status(200).json({
    message: 'Successfully retrieved total Supply.',
    balance: totalSupply,
  });
});

// transfer $LFY
router.post('/transfer', async (req, res) => {
  console.log(req.body.sender +" calling transfer of " +req.body.amount+" LFY for "+req.body.receiver);
  const isAddressNotValid = req.body.receiver.length !== 42;

  if (isAddressNotValid === true) {
    return res.status(400).json({
      message: 'Invalid address.'
    });
  }

  try{
    const txData = coinsContract.methods.transfer(req.body.receiver, req.body.amount).encodeABI();
    transfer = await buildSendTransaction(signer, signerKey, txData);
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      message: 'Server Error'
    });
  }

  res.status(200).json({
    message: 'Successfully transferred amount!',
    txHash: transfer,
    amount: req.body.amount,
    recipient: req.body.receiver
  });
});

// mint coins
router.post('/mint', async (req, res) => {
  console.log(req.body.minter+" calling mint of " +req.body.amount+" LFY for "+req.body.receiver);
  const isAddressNotValid = req.body.receiver.length !== 42;

  if (isAddressNotValid === true) {
    return res.status(400).json({
      message: 'Invalid address.'
    });
  }

  try {
    const txData = coinsContract.methods.mint(req.body.receiver, req.body.amount).encodeABI();
    transfer = await buildSendTransaction(signer, signerKey, txData);
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      message: 'Server Error'
    });
  }

  res.status(200).json({
    message: 'Successfully mint!',
    txHash: transfer,
    amount: req.body.amount,
    recipient: req.body.receiver
  });

});

// send and sign transaction
async function buildSendTransaction(account, accountKey, data) {
  // FORM TRANSACTION
  const txParams = {
      from: account,
      nonce: await web3.eth.getTransactionCount(account),
      to: contractAddress, // contract address
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


router.get('/accounts', async (req, res) => {
  web3.eth.getAccounts().then(accounts => {
    res.status(200).json({
      message: 'Accounts in node:',
      addresses: accounts
    });
  });
});

module.exports = router ;