# CoinFlip 
#### by Green Team 

### Set up
1. Clone the repository 
2. Copy and paste code from Contract/CoinFlip.sol into Remix
3. Set up Metamask
4. Deploy Dapp

### Directory
.
├── Contract                
│   └── CoinFlip.sol        # SmartContract 
├── Dapp                    # Decentralized Application
│   ├── index.html          # Structures the web page and its content 
│   ├── index.js            # Connects the smart contract with the app
│   ├── package.json        # Loads dependecies
│   ├── server.js           # Deploys the app
│   └── style.css           # Text styling
├── Testing                 
│   └── CoinFlip1_test.sol  # End-to-end, integration tests 
└── README.md

---

### Metamask 

#### Instalation and Configuration

 - Add Metamask as an extension to the browser 
 - Create and account
 - Connect account with Remix
 - Link tokens using: `0xa36085F69e2889c224210F603D836748e7dC0088` 
 
 Find a more detailed instructions [here](https://developers.rsk.co/tutorials/ethereum-devs/remix-and-metamask-with-rsk-testnet/)

<!-- ### Walkthrough GIF

<img src="" width=250><br> -->

---

### Smart Contract 

#### Steps to deploy the contract:

1.	Casino will deploy the contract
2.	A contract address will be deployed (we can copy that address directly into the front end). The contract address will always be the same. This is the address needed for players to join the game.
3.	After deploying contract the Casino must deposit money using the deposit money function (recommended amount is 1 ether)
4.	Contract can deposit any amount of money to contract at any time

#### After the contract is deployed:

1.	Player will join contract by deploying at the contract address
2.	Player will choose heads or tails
3.	Player will input a bet amount between 1 wei and 1 milli-ether
4.	Upon submission, the choice of heads or tails should be concatenated with a randomly generated hash and the hashed using keccak256
5.	The random number generation process may take time (about 5 seconds)
6.	After submitting the bet, the player will be able to see the results of the coin flip 
7.	The player will then reveal his/her choice by inputting the choice and the randomly generated hash
8.	If the player wins the money will automatically be sent to their wallet, if they lose the money is sent to the casino deposit
9.	The player can choose to forfeit the bet instead of revealing
10.	If the player fails to reveal their choice within 2 minutes of inputting their choice, they will automatically lose, and the money will be sent to the casino deposit. 
11.	The player will not be able to play another round until they reveal their choice, forfeit their bet, or the 2 minutes are up. 


<!-- ### Walkthrough GIF

<img src="" width=250><br> -->

---

### Client-Side Application - The front end 

#### Updating index.js
- Once the contract is deployed, we need to copy the contract address
- Open index.js 
- Edit this line: 
`var contractAddress = [YOUR CONTRACT ADDRESS GOES HERE];`

#### Starting Server 
The last step is to execute the express server. Input the command below into the terminal.
 - Navigate in terminal to the folder where the repository was clone and run this command:
`node server.js`

- In your browser, go to:
`http://localhost:3300`

- Click on the Connect button when the Metamask Wallet pops up

<!-- #### Interacting with UI -->
