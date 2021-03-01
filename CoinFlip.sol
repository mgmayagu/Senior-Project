pragma solidity ^0.6.6;

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
        require(msg.value == 1 ether);
        casinoDeposit = msg.value;
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