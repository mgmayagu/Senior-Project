// Source code to interact with smart contract

var crypto = require('crypto');
//connection with node
var web3 = new Web3(Web3.givenProvider);
// var randomBytes = 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb;
var randomBytes = generateRandomBytes();

var choice = 0;

// checks if Metamask is available 
if (typeof window.ethereum !== 'undefined') {
  console.log('MetaMask is installed!');
} else alert("install metamask");

// contractAddress and abi are setted after contract deploy
  var contractAddress = '0x30922d87841514e0237F4DFcFfBae31B3d435a8e';
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

// Hash Function
function keccak256(...args) {
  args = args.map(arg => {
    if (typeof arg === 'string') {
      if (arg.substring(0, 2) === '0x') {
          return arg.slice(2)
      } else {
          return web3.utils.toHex(arg).slice(2)
      }
    }

    if (typeof arg === 'number') {
      return leftPad((arg).toString(16), 64, 0)
    } else {
      return ''
    }
  })

  args = args.join('')

  return web3.utils.sha3(args, { encoding: 'hex' })
}

function generateRandomBytes(){
  var randomBytesArray = new Uint32Array(8);
  var randomBytes= "0x";
  randomBytesArray = crypto.getRandomValues(randomBytesArray);
  randomBytesArray.forEach(number => {
    randomBytes = randomBytes + number.toString(16);
  })
  return randomBytes;
}

// Smart contract functions

// When player clicks 'Place bet' button, playerCommit is called
function playerCommitBet() {
  
  let allAreFilled = true;

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

  // const buf = crypto.randomBytes(32);
  // console.log(
  // `${buf.length} bytes of random data: ${buf.toString('hex')}`);

  var betChoice = document.querySelector('input[name="coinFlip"]:checked').value; //stores the choice: 0/1
  var betAmt = $('#newInfo').val(); // stores the amount of the bet
  tempChoice = betChoice;

  if (betChoice == "1"){
    choice = 1;
  }
  // hashes the choice -> need to generate rnadomBytes
  // var hasedBet = keccak256(betChoice);
  var hasedBet = web3.utils.sha3(choice+randomBytes.toString());  
  // alert(hasedBet)
  contract.methods.playerCommit(hasedBet).send( {from: account, value:web3.utils.toWei(betAmt,'wei')}).then( function(tx) { 
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
          contract.methods.forfeitGame().send( {from: account}).then( function(tx) { 
            console.log("Transaction: ", tx); 
          }).catch(function(txt)
          {
            console.log(txt);
          });
        }
      }
      else{
        $('#coin').addClass('tails');
        console.log('it is heads');
        if (confirm('Its heads!')) {
          location.reload();
          //call forfeit function
          contract.methods.forfeitGame().send( {from: account}).then( function(tx) { 
            console.log("Transaction: ", tx); 
          }).catch(function(txt)
          {
            console.log(txt);
          });
        }
      }
    }, 100);

    contract.methods.reveal (tempChoice, randomBytes).send( {from: account}).then( function(tx) { 
      alert("")
      console.log("Transaction: ", tx); 
    }).catch(function(txt)
    {
      console.log(txt);
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
    location.reload();
    //call forfeit function
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

var interval;

function countdown() {
  clearInterval(interval);
  interval = setInterval( function() {
    var timer = $('.js-timeout').html();
    timer = timer.split(':');
    var minutes = timer[0];
    var seconds = timer[1];
    seconds -= 1;
    if (minutes < 0) return;
    else if (seconds < 0 && minutes != 0) {
      minutes -= 1;
      seconds = 59;
    }
    else if (seconds < 10 && length.seconds != 2) seconds = '0' + seconds;

    $('.js-timeout').html(minutes + ':' + seconds);

    if (minutes == 0 && seconds == 0)
    {
      // calls forfeitGame function when time is up
      contract.methods.forfeitGame().send( {from: account}).then( function(tx) { 
        console.log("Transaction: ", tx); 
        alert("Time is up!")
      }).catch(function(txt)
      {
        console.log(txt);
      }); 
      clearInterval(interval); 
    }
  }, 1000);
}

$('#check').click(function () {
  $('.js-timeout').text("2:00");
  countdown();
});

$('#js-resetTimer').click(function () {
  $('.js-timeout').text("2:00");
  clearInterval(interval);
});
