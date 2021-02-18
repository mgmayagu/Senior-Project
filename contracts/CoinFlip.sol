pragma solidity 0.6.6;

import "https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/VRFConsumerBase.sol";

contract RandomNumberConsumer is VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint256 public randomResult;
    address payable public player1;
    bytes32 public player1Commitment;
    uint256 randomNumberNonce;
    uint256 public betAmount = 1 wei;

    address payable public player2;
    bool public player2Choice;

    uint256 public expiration = 2**256-1;
    uint256 seed;
    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     */
    constructor(bytes32 commitment, address payable _player2, uint256 seed) 
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ) public payable
    {
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        player1 = msg.sender;
        player1Commitment = commitment;
        player2 = _player2;
        betAmount = msg.value;
    }
    
    function random() internal returns (uint) {
    getRandomNumber(seed);
    uint _randomNumber = uint(keccak256(abi.encodePacked(now, msg.sender, randomNumberNonce))) % 2;
    
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

    
       
  

    /** 
     * Requests randomness from a user-provided seed
     */
    function getRandomNumber(uint256 userProvidedSeed) internal returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomNumberNonce = randomness;
        
     
    }
    
    function cancel() public {
        require(msg.sender == player1);
        require(player2 == address(0));

        betAmount = 0;
        msg.sender.transfer(address(this).balance);
    }

    function takeBet() public payable {
        require(player2 == address(0));
        require(msg.value == betAmount);

        player2 = msg.sender;
        player2Choice = flipCoin();

        expiration = now + 24 hours;
    }

    function reveal(bool choice, uint256 _nonce) public payable {
        require(player2 != address(0));
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