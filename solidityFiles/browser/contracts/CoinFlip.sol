pragma solidity ^0.4.21;

contract CoinFlip {
    address public player1;
    bytes32 public player1Commitment;
    uint256 randomNumberNonce = 0;
    uint256 public betAmount = 1 wei;

    address public player2;pragma solidity ^0.6.6;

// Deploy with this hash 0x83853f8c4ca91ae85231d68dec421e7d9210f65860b863a574dfc0dc0c7e815e
// Equivalent to 0 hashed with 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb

contract CoinFlip {
    
    address payable player;
    
    address payable casino;
    uint256 public casinoDeposit;
    uint256 betAmount;
    uint256 maxBet = .001 ether;
    bytes32 commitHash;
    uint gameTimeOut;
    uint256  matchBetTimeOut;
    uint256 revealTimeOut;
    uint256 result;
    bool win;
    address payable contractAddress = address(this);
    
    constructor () public payable{
        // Casino initiates the contract by depositing 1 ether
        require(msg.value == 1 ether);
        casinoDeposit = msg.value;
        casino = msg.sender;
    }
    
    
    function playerCommit(bytes32 _commitHash) external payable {
        require(msg.value < casinoDeposit);
        require(msg.value >= 1 wei, "Bets must be  at least 1 wei");
        require(msg.value <= maxBet, "Max bet exceeded");
        player = msg.sender;
        betAmount = msg.value;
        commitHash = _commitHash;
        sendViaCall(contractAddress, betAmount);
        matchBet();
        // gameTimeOut = now + 5 minutes;
        // timer(gameTimeOut);
        flipCoin();
    }
    
    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
    
    
    // function timer(uint256 _timeLeft) internal{
    //   while(now < _timeLeft ) {}
    //     //  User bet is never matched
    //     //  User places bet, is matched, player never reveals
    //   if(getBalance() > 0){
    //     //  Send money to the casino
    //      casino.transfer(address(this).balance);
    //   }
      
    // }
    
    function sendViaCall(address payable _to, uint256 _amount) internal {
        (bool sent, bytes memory data) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function flipCoin() internal {
        result = uint(keccak256(abi.encodePacked(now, commitHash, player))) % 2;
    }
    
    function seeResult() public view returns(uint){
        require (betAmount > 0, "Please place your bet" );
        return result;
    }
    
    // modifier betsPlaced {
    //     require (betAmount > 0, "Please place your bet" );
    //     require (getBalance() == 2 * betAmount, "Please wait for the casino to match your bet" );
    //     _;
    // }
    
    // function placeBet() public payable {
    //     require(now < gameTimeOut, "Game Timed Out");
    //     require(msg.value > 1 wei, "Bets must be  at least 1 wei");
    //     require(msg.value < maxBet, "Max bet exceeded");
    //     betAmount = msg.value;
    //     sendViaCall(contractAddress, betAmount);
    //     matchBetTimeOut = now + 1 minutes;
    // }
    
    function matchBet() internal {
        casinoDeposit = casinoDeposit - betAmount;
        // sendViaCall(contractAddress, betAmount);
        // require(now < gameTimeOut, "Game Timed Out");
        // require (betAmount > 0, "Please place your bet" );
        // require(msg.sender == casino);
        // require(msg.value == betAmount);
        // sendViaCall(contractAddress);
    }
    
    function payOut() internal{
        if (win == true){
            // player.transfer(address(this).balance);
            sendViaCall(player, 2 * betAmount);
            betAmount = 0;
        }
        else {
            // casino.transfer(address(this).balance);
            casinoDeposit = casinoDeposit + 2* betAmount;
            betAmount = 0;
        }
    }
    
    function reveal(uint  _choice, bytes32 _hashValue) public payable {
        // require(now < gameTimeOut, "Game Timed Out");
        require (betAmount > 0, "Please place your bet" );
        // require (getBalance() == 2 * betAmount, "Please wait for the casino to match your bet" );
        require(keccak256(abi.encodePacked(_choice, _hashValue)) == commitHash, "Commitment hash does not match");
        if(_choice == result ){
            win = true;
        }
        else {
            win =  false;
        }
        payOut();
    }
    
    
    
}
    bool public player2Choice;

    uint256 public expiration = 2**256-1;

    constructor(bytes32 commitment, address _player2) public payable {
        player1 = msg.sender;
        player1Commitment = commitment;
        player2 = _player2;
        betAmount = msg.value;
    }
    
    function random() internal returns (uint) {
    uint _randomNumber = uint(keccak256(abi.encodePacked(now, msg.sender, randomNumberNonce))) % 2;
    randomNumberNonce++;
    return _randomNumber;
    }
    
    function flipCoin() internal returns (bool) {
        uint randomNumber = random();
        bool winningBet;
        if (randomNumber == 0){
            winningBet = true;
        }
        else {
            winningBet = false;
        }
        return winningBet;
    }

    function cancel() public {
        require(msg.sender == player1);
        require(player2 == 0);

        betAmount = 0;
        msg.sender.transfer(address(this).balance);
    }

    function takeBet() public payable {
        require(player2 == 0);
        require(msg.value == betAmount);

        player2 = msg.sender;
        player2Choice = flipCoin();

        expiration = now + 24 hours;
    }

    function reveal(bool choice, uint256 _nonce) public payable {
        require(player2 != 0);
        require(now < expiration);

        require(keccak256(abi.encodePacked(choice, _nonce)) == player1Commitment);

        if (player2Choice == choice) {
            player2.transfer(address(this).balance);
        } else {
            player1.transfer(address(this).balance);
        }
    }

    function claimTimeout() public {
        require(now >= expiration);

        player2.transfer(address(this).balance);
    }
}
