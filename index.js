// Source code to interact with smart contract
//connection with node
var web3 = new Web3(Web3.givenProvider);
// web3 = new Web3(web3.currentProvider);
// contractAddress and abi are setted after contract deploy
  var contractAddress = '0xd9145CCE52D386f254917e481eB44e9943F39138';
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
  
//contract instance
contract = new web3.eth.Contract(abi, contractAddress);

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

// Smart contract functions
// function registerSetInfo() {
//   info = $("#newInfo").val();
//   contract.methods.setInfo (info).send( {from: account}).then( function(tx) { 
//     console.log("Transaction: ", tx); 
//   });
//   $("#newInfo").val('');
// }

// function registerGetInfo() {
//   contract.methods.getInfo().call().then( function( info ) { 
//     console.log("info: ", info);
//     document.getElementById('lastInfo').innerHTML = info;
//   });    
// }

// Function to hash the the choice
function keccak256(...args) {
  args = args.map(arg => {
    if (typeof arg === 'string') {
      if (arg.substring(0, 2) === '0x') {
          return arg.slice(2)
      } else {
          return web3.toHex(arg).slice(2)
      }
    }

    if (typeof arg === 'number') {
      return leftPad((arg).toString(16), 64, 0)
    } else {
      return ''
    }
  })

  args = args.join('')

  return web3.sha3(args, { encoding: 'hex' })
}

// When player clicks 'Place bet' button, playerCommit is called
function playerCommitBet() {
  let allAreFilled = true;
  var betChoice = document.querySelector('input[name="coinFlip"]:checked').value; //stores the choice: 0/1
  var betAmt = $('#newInfo').val(); // stores the mount of the bet

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
    //alert('Fill all the fields');
  }
  if (betAmt < 1 || betAmt > 1000000000000000){
    //alert('Fill all the fields');
  }
  else {
    showPanel();
    hidePanel();
  }

  // hashes the choice
  // var hasedBet = keccak256(betChoice);
  var hasedBet = web3.utils.soliditySha3(betChoice)

  console.log(betAmt);
  console.log(betChoice);
  console.log(hasedBet);
  
  
  $("#newInfo").val('');
  contract.methods.playerCommit (hasedBet).send( {from: account, value:web3.utils.toWei(betAmt,'wei')}).then( function(tx) { 
    console.log("Transaction: ", tx); 
  }).catch(function(txt)
  {
    console.log(txt);
  });
};

// Click the coin and calls on reveal 
jQuery(document).ready(function($){

  $('#coin').on('click', function(){
    var flipResult = Math.random();
    $('#coin').removeClass();
    setTimeout(function(){
      if(flipResult <= 0.5){
        $('#coin').addClass('heads');
        console.log('it is tails');
        if (confirm('Its tails!')) {
          location.reload();
          //call forfeit function
        }
      }
      else{
        $('#coin').addClass('tails');
        console.log('it is heads');
        if (confirm('Its heads!')) {
          location.reload();
          //call forfeit function
        }
      }
    }, 100);
  });
  });