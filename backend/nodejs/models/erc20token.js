const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;
const Web3 = require('web3');
const router = express.Router();
const coinsABI = require('./ERC20Token.json');
const chainUrl = 'HTTP://127.0.0.1:7545'; // change to your own chain url
const web3 = new Web3(chainUrl);

// update endpoint
const contractAddress = '0x0Dd780E5e230077D66a7067f023C9AF28E5381e8'; // add contract address
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
    await coinsContract.methods.transfer(req.body.receiver, req.body.amount).send({from: req.body.sender});
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      message: 'Server Error'
    });
  }

  res.status(200).json({
    message: 'Successfully transferred amount!',
    amount: req.body.amount,
    recipient: req.body.receiver
  });
});

// mint coins
// QUESTION: how to capture failed require statement from contract?
router.post('/mint', async (req, res) => {
  console.log(req.body.minter+" calling mint of " +req.body.amount+" LFY for "+req.body.receiver);
  const isAddressNotValid = req.body.receiver.length !== 42;

  if (isAddressNotValid === true) {
    return res.status(400).json({
      message: 'Invalid address.'
    });
  }

  try {
    await coinsContract.methods.mint(req.body.receiver, req.body.amount).send({from: req.body.minter});
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      message: 'Server Error'
    });
  }

  res.status(200).json({
    message: 'Successfully mint!',
    amount: req.body.amount,
    recipient: req.body.receiver
  });

});

module.exports = router ;