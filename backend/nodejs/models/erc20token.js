const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;
const Web3 = require('web3');

const chainUrl = 'ws://localhost:8545'; // change to your own chain url
const coinsABI = require('./contracts/JairusCoin.json');

const web3 = new Web3(chainUrl);

const contractAddress = '0xfe11704312cd0Ae87A647F0945F99fa3A1cABc73'; // add contract address
const coinsContract = new web3.eth.Contract(
    coinsABI,
    contractAddress,
);

const db = {
    users: [
      {
        username: 'admin',
        password: 'admin',
        role: 'admin',
        address: '', // add minter address
      }
    ],
  };

app.use(bodyParser.json());

// create a user
app.post('/users', async (req, res) => {
    const ethUser = web3.eth.accounts.create();
    console.log(ethUser);
  
    db.users.push({
      username: req.body.username,
      password: req.body.password,
      address: ethUser.address,
    });
  
    res.status(201).json({
      message: 'Successfully created a user',
      address: ethUser.address,
    });
  });
  
  // get list of users and their addresses
  app.get('/users', async (req, res) => {
    res.status(200).json({
      message: 'Successfully retrieved users',
      users: db.users.map((user) => {
        return {username: user.username, address: user.address};
      }),
    });
  });

app.get('/example', async (req, res) => {
    const accounts = await web3.eth.getAccounts();
    console.log(accounts);
    res.send('Hello World!');
});

app.get('/coins/:address', async (req, res) => {
    console.log(req.params);
    const balance = await coinsContract.methods.balances(req.params.address).call();
  
    res.status(200).json({
      message: 'Successfully get address balance',
      balance: balance,
    });
  });

  app.post('/coins/transfer', async (req, res) => {
    const user = db.users.find((user) => {
      return user.username === req.body.username && user.password === req.body.password;
    });
  
    if (!user) {
      res.status(401).json({
        message: 'Username/password is incorrect',
      });
    }
  
    console.log(req.body);
  
    await coinsContract.methods.send(req.body.receiver, Number(req.body.amount)).send({from: user.address});
  
    res.status(200).json({
      message: 'Successfully minted coins',
    });
  });
  
  // mint coins
  app.post('/coins/mint', async (req, res) => {
    const user = db.users.find((user) => {
      return user.username === req.body.username && user.password === req.body.password;
    });
  
    if (!user) {
      res.status(401).json({
        message: 'Username/password is incorrect',
      });
    }
  
    if (user.role !== 'admin') {
      res.status(403).json({
        message: 'You are not the minter',
      });
    }
  
    console.log(req.body);
  
    await coinsContract.methods.mint(req.body.receiver, Number(req.body.amount)).send({from: minterAddress});
  
    res.status(200).json({
      message: 'Successfully minted coins',
    });
  });

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});