
# CoinFlip 
#### by Green Team 

- Clone the repository for the Front-End
- Copy and paste code from CoinFlip.sol into Remix

---

### Metamask 

#### Instalation and Configuration

 - Add Metamask as an extension to the browser 
 - Create and account
 - Connect account with Remix
 - Link tokens using: 0xa36085F69e2889c224210F603D836748e7dC0088 
 
 Find a more detailed instructions [here](https://developers.rsk.co/tutorials/ethereum-devs/remix-and-metamask-with-rsk-testnet/)

<!-- ### Walkthrough GIF

<img src="" width=250><br> -->

---

### Smart Contract 

#### Steps to deploy the contract:

1.	Casino will deploy the contract by sending 1 Ether of value and inputting a seed for random number generation
2.	A contract address will be deployed (we can copy that address directly into the front end). The contract address will always be the same. This is the address needed for players to join the game.
3.	The contract will stay deployed until the casino deposit runs out

#### After the contract is deployed:

1.	Player will join contract by deploying at the contract address
2.	Player will choose heads or tails
3.	Player will input a bet amount between 1 wei and 1 millether
4.	Upon submission the choice of heads or tails should be hashed concatenated with a randomly generated hash and the hashed again using keccak256
5.	The randomness number generation process may take time (about 20 seconds) so maybe stall for a little before allowing to see results or reveal choice
6.	After submitting the bet, the player will be able to see the results of the coin flip 
7.	The player will then reveal his/her choice by inputting the choice and the randomly generated hash
8.	If the player wins the money will automatically be sent to their wallet, if they lose the money is sent to the casino deposit
9.	If the player fails to reveal their choice within 5 minutes of inputting their choice, they will automatically lose, and the money will be sent to the casino deposit. 
10.	The player will not be able to play another round until they reveal their choice or the 5 minutes are up. 


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

