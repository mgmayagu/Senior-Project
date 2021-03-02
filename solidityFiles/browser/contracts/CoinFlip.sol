pragma solidity ^0.6.6;

import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/VRFConsumerBase.sol";
// Deploy with this hash 0x83853f8c4ca91ae85231d68dec421e7d9210f65860b863a574dfc0dc0c7e815e
// Equivalent to 0 hashed with 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb

contract CoinFlip is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 seed;
    uint256 public randomResult;
    uint256 randomnum;
    
    struct Player {
        address payable playerAddress;
        uint256 betAmount;
        uint256 gameTimeOut;
        bytes32 commitHash;
        bool win;
        uint256 result;
    }
    
    mapping(address => Player) playerMap;
    address[] playerAddressArray;
    address payable casino;
    uint256 public casinoDeposit;
    uint256 maxBet = .001 ether;
    address payable contractAddress = address(this);
    
    constructor (uint256 _seed) VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ) public payable{
        // Casino initiates the contract by depositing 1 ether
        require(msg.value == 1 ether);
        casinoDeposit = msg.value;
        casino = msg.sender;
        seed=_seed;
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }
    
    /** 
     * Requests randomness from a user-provided seed
     */
    function getRandomNumber(uint256 userProvidedSeed) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
        randomnum =  randomness;
     
    }
    function playerCommit(bytes32 _commitHash) external payable {
        require(msg.value < casinoDeposit);
        require(msg.value >= 1 wei, "Bets must be  at least 1 wei");
        require(msg.value <= maxBet, "Max bet exceeded");
        address _playerAddress  = msg.sender;
        playerAddressArray.push(msg.sender);
        playerMap[_playerAddress].playerAddress = msg.sender;
        playerMap[_playerAddress].betAmount = msg.value;
        playerMap[_playerAddress].commitHash = _commitHash;
        sendViaCall(contractAddress, playerMap[_playerAddress].betAmount);
        matchBet(playerMap[_playerAddress].betAmount);
        playerMap[_playerAddress].gameTimeOut = now + 2 minutes;
        // timer(gameTimeOut);
        playerMap[_playerAddress].result = flipCoin();
    }
    
    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
    
    function sendViaCall(address payable _to, uint256 _amount) internal {
        (bool sent, bytes memory data) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function flipCoin() internal returns (uint256) {
        getRandomNumber(seed);
        return randomResult % 2; 
    }
    
    function seeResult() public view returns(uint){
        require (playerMap[msg.sender].betAmount > 0, "Please place your bet" );
        require(randomnum != 0, 'please wait until random num has been generated ~ 20 secs');
        return playerMap[msg.sender].result;
    }
    
    function matchBet(uint256 _betAmount) internal {
        casinoDeposit = casinoDeposit - _betAmount;
    }
    
    function payOut(address payable _playerAddress) internal{
        if (playerMap[_playerAddress].win == true){
            sendViaCall(_playerAddress, 2 * playerMap[_playerAddress].betAmount);
            playerMap[_playerAddress].betAmount = 0;
            playerMap[_playerAddress].gameTimeOut = 0;
        }
        else {
            casinoDeposit = casinoDeposit + 2 * playerMap[_playerAddress].betAmount;
            playerMap[_playerAddress].betAmount = 0;
        }
    }
    
    function reveal(uint  _choice, bytes32 _hashValue) public payable {
        require(now < playerMap[msg.sender].gameTimeOut, "Game Timed Out");
        require(randomnum != 0, 'please wait until random num has been generated ~ 20 secs');
        require (playerMap[msg.sender].betAmount > 0, "Please place your bet" );
        // require (getBalance() == 2 * betAmount, "Please wait for the casino to match your bet" );
        require(keccak256(abi.encodePacked(_choice, _hashValue)) == playerMap[msg.sender].commitHash, "Commitment hash does not match");
        if(_choice == playerMap[msg.sender].result ){
            playerMap[msg.sender].win = true;
        }
        else {
            playerMap[msg.sender].win =  false;
        }
        payOut(msg.sender);
    }
    
    
    
    function collectGameTimeout() public {
        for(uint256 i = 0; i < playerAddressArray.length; i++){
            if (playerMap[playerAddressArray[i]].gameTimeOut <  now){
                casinoDeposit = casinoDeposit + 2* playerMap[playerAddressArray[i]].betAmount;
                playerMap[playerAddressArray[i]].betAmount = 0;
                playerMap[playerAddressArray[i]].gameTimeOut = 0;
            }
        }
    }
}
