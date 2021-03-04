pragma solidity ^0.6.6;

// Deploy with this hash 0x83853f8c4ca91ae85231d68dec421e7d9210f65860b863a574dfc0dc0c7e815e
// Equivalent to 0 hashed with 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb

contract CoinFlip {
    
    
    struct Player {
        address payable playerAddress;
        bool playerExists; // Whether the player has already been added to map and array;
        uint256 betAmount; // Bet Amount for the game
        uint256 gameTimeOut; // How much time is left in the game
        bytes32 commitHash; // Player choice hash
        bool win; // Whether the player won or lost
        uint256 result; // Result of the coinFlip for the player
        bool gameInProgress; // Whether the player is currently playing a game
    }
    
    mapping(address => Player) playerMap; // Map containing all players playing the game (this is not iterable)
    address[] playerAddressArray; // Array of all players addresses of players playing the game (this is iterable)
    address payable casino;  // Address of the casino, will not change after contract is deployed
    uint256 public casinoDeposit = 0; // Value of the casino deposit
    uint public balance;
    uint256 maxBet = .001 ether; 
    address payable contractAddress = address(this);  // Address of this contract
    
    constructor () public payable{
        // Casino initiates the contract
        casino = msg.sender;
    }
    
    // Function for the casino to deposit money, must be called for the rest of the contract to work
    function depositMoney() public payable {
        require(msg.sender == casino, "Only the casino can deposit money");
        casinoDeposit = casinoDeposit + msg.value;
    }
    
    // Function to submit bet, input the hash and a value to bet
    function playerCommit(bytes32 _commitHash) external payable {
        address _playerAddress  = msg.sender;
        require(_playerAddress != casino, "Casino cannot be a player");
        require(msg.value < casinoDeposit, "Casino cannot cover bet"); // Bet must be less than the money in the casino deposit to ensure casino can cover the bet
        require(msg.value >= 1 wei, "Bets must be  at least 1 wei"); // Must be greater or equal to minimum bet of 1 wei
        require(msg.value <= maxBet, "Max bet exceeded"); // Must be less than or equal to max bet of .001 ether
        
        if( !playerMap[_playerAddress].playerExists) { // If player is new
            playerAddressArray.push(msg.sender); // Add player address to array of player addresses
            playerMap[_playerAddress].playerAddress = msg.sender; 
            playerMap[_playerAddress].playerExists = true;
        }
        else {
            require( playerMap[_playerAddress].gameInProgress == false, "Player cannot be playing a game");
        }
    
        // playerMap[_playerAddress] means the Player who is mapped to the address of _playerAddress
        // Assign values to the Player (based on the Player struct)
        playerMap[_playerAddress].betAmount = msg.value;
        playerMap[_playerAddress].gameInProgress = true;
        playerMap[_playerAddress].commitHash = _commitHash;
        sendViaCall(contractAddress, playerMap[_playerAddress].betAmount); // Sends bet to the contract
        matchBet(playerMap[_playerAddress].betAmount); // Contract will match the bet
        playerMap[_playerAddress].gameTimeOut = now + 2 minutes; // Player will have 2 minutes from when they place the bet to claim their winnings
        playerMap[_playerAddress].result = flipCoin(); // Stores the result of the coin flip for that player
    }
    
    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
    
    // Function to send a value of money to an address
    function sendViaCall(address payable _to, uint256 _amount) internal {
        (bool sent, bytes memory data) = _to.call{value: _amount}(""); 
        require(sent, "Failed to send Ether");
    }
    
    // Funtion to return total balance of the contract which is casinoDeposit + all bets currently on the table
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function contractCreated() internal {
        casino = msg.sender; 
        balance = msg.value;
    }
    
    // Function to generate pseudorandom number 1 or 0
    function flipCoin() view internal returns (uint256) {
        return uint(keccak256(abi.encodePacked(now))) % 2; 
    }
    
    // Function to see result of the coin flip
    function seeResult() public view returns(uint){
        // Can only be called once bet is placed (coin will automatically be flipped upon bet)
        require (playerMap[msg.sender].betAmount > 0, "Please place your bet" ); 
        return playerMap[msg.sender].result;
    }
    
    // Function for the casino to match the bet amount
    function matchBet(uint256 _betAmount) internal {
        casinoDeposit = casinoDeposit - _betAmount; // bet amount is deducted from casinoDeposit and but remains in the contract balance
    }
    
    // Function to pay the winner
    function payOut(address payable _playerAddress) internal{
        if (playerMap[_playerAddress].win == true && playerMap[_playerAddress].gameTimeOut > now ){ // If the player wins and is within time limit
            sendViaCall(_playerAddress, 2 * playerMap[_playerAddress].betAmount); // Send money to player
        }
        else { // If the casino wins
            casinoDeposit = casinoDeposit + 2 * playerMap[_playerAddress].betAmount; // Send money to casino deposit
        }
        playerMap[_playerAddress].betAmount = 0; // reset bet
        playerMap[_playerAddress].gameTimeOut = 0; // reset game timer
        playerMap[_playerAddress].gameInProgress = false; // game is over
    }
    
    // Funtion to reveal player choice, input choice and hash value used to create initial hash
    function reveal(uint  _choice, bytes32 _hashValue) public payable {
        require(now < playerMap[msg.sender].gameTimeOut, "Game Timed Out"); // Can only reveal if the game is still valid
        require (playerMap[msg.sender].betAmount > 0, "Please place your bet" ); // Must place a bet before player can reveal
        // Hashed choice and hash must match initial hash
        require(keccak256(abi.encodePacked(_choice, _hashValue)) == playerMap[msg.sender].commitHash, "Commitment hash does not match"); 
        if(_choice == playerMap[msg.sender].result ){
            playerMap[msg.sender].win = true;
        }
        else {
            playerMap[msg.sender].win =  false;
        }
        payOut(msg.sender);
    }
    
    // function to forfeit game instead of waiting for timer to end and instead of revealing
    function  forfeitGame() public {
        address _playerAddress = msg.sender;
        require (playerMap[_playerAddress].playerAddress == _playerAddress); // Ensures that a player is calling the funtion
        require (playerMap[_playerAddress].gameInProgress == true); // Game must be in progress
        casinoDeposit = casinoDeposit + 2* playerMap[_playerAddress].betAmount; // Pays the money to the casino deposit
        playerMap[_playerAddress].betAmount = 0;
        playerMap[_playerAddress].gameTimeOut = 0;
        playerMap[_playerAddress].gameInProgress = false;
    }
    
    // Function to pay casino when time is up
    function collectGameTimeout() public {
        address _playerAddress = msg.sender;
        require(playerMap[_playerAddress].gameTimeOut <  now, "game still in progress");
        casinoDeposit = casinoDeposit + 2* playerMap[_playerAddress].betAmount;
        playerMap[_playerAddress].betAmount = 0;
        playerMap[_playerAddress].gameTimeOut = 0;
        playerMap[_playerAddress].gameInProgress = false; 
    }
}
