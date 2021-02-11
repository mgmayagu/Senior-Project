pragma solidity ^0.4.21;

contract CoinFlip {
    address public player1;
    bytes32 public player1Commitment;
    uint256 randomNumberNonce = 0;
    uint256 public betAmount = 1 wei;

    address public player2;
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
