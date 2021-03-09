// Source code to interact with smart contract

//connection with node
var web3 = new Web3(Web3.givenProvider);

// generates random bytes for the hash
var randomBytes = web3.utils.randomHex(32);
console.log("Random Bytes " + randomBytes);

// default choice - tails
var choice = 0;

// checks if Metamask is available 
if (typeof window.ethereum !== 'undefined') {
  console.log('MetaMask is installed!');
} else alert("install metamask");

// contractAddress and abi are setted after contract deploy
  var contractAddress = '0xF0130d13A70D869f4fA2E1f8e2bFE0b97e6d251E';
  var abi = [
    {
      "inputs": [],
      "stateMutability": "payable",
      "type": "constructor"
    },
    {
      "stateMutability": "payable",
      "type": "fallback"
    },
    {
      "inputs": [],
      "name": "casinoDeposit",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "collectGameTimeout",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "depositMoney",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "forfeitGame",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "getBalance",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "_commitHash",
          "type": "bytes32"
        }
      ],
      "name": "playerCommit",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "_choice",
          "type": "uint256"
        },
        {
          "internalType": "bytes32",
          "name": "_hashValue",
          "type": "bytes32"
        }
      ],
      "name": "reveal",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "seeResult",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "stateMutability": "payable",
      "type": "receive"
    }
  ]
  

// Accounts
var account;
web3.eth.getAccounts(function(err, accounts) {
  if (err != null) {
    alert("Error retrieving accounts.");
    return;
  }
  if (accounts.length == 0) {
    alert("No account found! Make sure the Ethereum client is configured properly.");
    return;
  }
  account = accounts[0];
  console.log('Account: ' + account);
  web3.eth.defaultAccount = account;
});

//contract instance
let contract = new web3.eth.Contract(abi, contractAddress
  , {
  from: account,
  gasLimit: web3.utils.toHex(7900000),
  gasPrice: web3.utils.toHex(1000000000)
});


// Smart contract functions
// When player clicks 'Place bet' button, playerCommit is called from smart contract
function playerCommitBet() {
  
  let allAreFilled = true;
  // check the required field are filled before placing the bet
  document.getElementById("bet-form").querySelectorAll("[required]").forEach(function(i) {
    if (!allAreFilled) return;
    if (!i.value) allAreFilled = false;
    if (i.type === "radio") {
      let radioValueCheck = false;
      document.getElementById("bet-form").querySelectorAll(`[name=${i.name}]`).forEach(function(r) {
        if (r.checked) radioValueCheck = true;
      })
      allAreFilled = radioValueCheck;
    }
  })
  if (!allAreFilled) {
    alert('Fill all the fields');
  }
  if (betAmt < 1 || betAmt > 1000000000000000){
    alert('Fill all the fields');
  }
  else {
    showPanel();
    hidePanel();
  }

  //stores the choice: 0/1 as a String
  var betChoice = document.querySelector('input[name="coinFlip"]:checked').value; 
  // stores the amount of the bet
  var betAmt = $('#newInfo').val();
  // if betChoice is '1' updated global variable choice
  if (betChoice == "1") choice = 1;
  // hashes user choice and the random bytes
  var hashedBet = web3.utils.soliditySha3(choice, randomBytes);
  console.log("Hashed choice " + hashedBet);
  console.log('Account: ' + account);
  
  // deploys the function in the smart contract
  // contract.methods.playerCommit(hashedBet).send({from: account, value:web3.utils.toWei(betAmt,'wei')}).then( function(tx) { 
  //   console.log("Transaction: ", tx); 
  // }).catch(function(txt)
  // {
  //   console.log(txt);
  // });

  contract.methods.playerCommit(hashedBet).send({from: account, value:web3.utils.toWei(betAmt,'wei')}).on("receipt", (receipt) => {
    // Transaction succeeded
    contract.getPastEvents(
        "Bet Commited", {
            fromBlock: receipt.blockNumber,
            toBlock: receipt.blockNumber
        }, (errors, events) => {
            for (let event in events) {
                let returnValues = events[event].returnValues;
                console.log(returnValues.toString())
            }
        });
  
  }).catch(function (e) {
    // Transaction rejected or failed
    console.log(e);
  });

};

// Click the coin and calls on reveal 
jQuery(document).ready(function($){
  
  $('#coin').on('click', function(){
    // stores the result for output
    var flipResult;
    
    contract.methods.seeResult().call({from: account}).then(
      data => {
        flipResult = data;
        console.log('Result: ' + flipResult);
      }
    );

    // flips the coin
    $('#coin').removeClass();
    setTimeout(function(){
      if(flipResult <= 0.5){
        $('#coin').addClass('tails');
        console.log('it is tails');
      }
      else{
        $('#coin').addClass('heads');
        console.log('it is heads');
        
      }
    }, 100);

    // calls the reveal method from the contract
    // contract.methods.reveal (choice, randomBytes).send( {from: account}).then( function(tx) { 
    //   flipResult = data;
    //   console.log('Result Revealed: ' + flipResult);
    //   console.log("Transaction: ", tx); 
    // }).catch(function(txt)
    // {
    //   console.log(txt);
    // });

    contract.methods.reveal (choice, randomBytes).send( {from: account}).on("receipt", (receipt) => {
      // Transaction succeeded
      contract.getPastEvents(
          "Bet Commited", {
              fromBlock: receipt.blockNumber,
              toBlock: receipt.blockNumber
          }, (errors, events) => {
              for (let event in events) {
                  let returnValues = events[event].returnValues;
                  console.log(returnValues.toString())
              }
          });
    
    }).catch(function (e) {
      // Transaction rejected or failed
      console.log(e);
    });

  });
});

function showPanel(){
  document.getElementById("panel").style.display = "block";
}

function hidePanel(){
  document.getElementById("panel2").style.display = "none";
}

function hidePanel3(){
  document.getElementById("panel3").style.display = "none";
}

function startOver(){
  document.getElementById("startOver").style.display = "block";
}

function forfeitBet(){
  if (confirm('Are you sure you want to forfeit your bet?')) {
    console.log('Bet was forfeited');
    // location.reload();
    setTimeout(location.reload.bind(location), 3000);
    //call forfeit function
    contract.methods.forfeitGame().send( {from: account}).then( function(tx) { 
      console.log("Bet Forfeited!");
      console.log("Transaction: ", tx); 
    }).catch(function(txt)
    {
      console.log(txt);
    });
  } else {
    // Do nothing!
    console.log('No changes have been made');
  }
}

function displayChoice(){
  var userBet = document.getElementById("newInfo").value;
  document.getElementById("displayAmount").innerHTML = userBet;
  var userChoice = document.getElementsByName("coinFlip");
  for(i = 0; i < userChoice.length; i++) { 
    if(userChoice[i].checked) {
      if(userChoice[i].value == 1)
        document.getElementById("displayGuess").innerHTML = "Heads"; 
      if(userChoice[i].value == 0)
        document.getElementById("displayGuess").innerHTML = "Tails";
    }
  }
}


