pragma solidity ^0.4.21;

contract CoinFlip {
    address public player1;
    bytes32 public player1Commitment;
    // uint256 public betAmount;
    uint nonce = 0; 
    uint256 public randomNumber;
    bool public winningBet;
    
    
    
    constructor (bytes32 _player1Commitment) public payable{
        player1Commitment = _player1Commitment;
        player1 = msg.sender;
    }
    
    function random() internal returns (uint) {
    uint _randomNumber = uint(keccak256(abi.encodePacked(now, msg.sender, nonce))) % 2;
    nonce++;
    return _randomNumber;
    }
    
    function flipCoin() public returns (string) {
        randomNumber = random();
        if (randomNumber == 0){
            winningBet = true;
            return "Heads";
        }
        else {
            winningBet = false;
            return "False";
        }
    }
    
    function reveal(bool choice, uint _nonce) payable public returns (string) {
        
        require(keccak256(abi.encodePacked(choice, _nonce)) == player1Commitment);
        if (choice == winningBet){
            return "Player Wins";
        }
        else {
            return "Player Loses";
        }
    }
    
}
