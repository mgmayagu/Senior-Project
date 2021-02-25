pragma solidity ^0.6.6;

// Deploy with this hash 0x83853f8c4ca91ae85231d68dec421e7d9210f65860b863a574dfc0dc0c7e815e
// Equivalent to 0 hashed with 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb

contract CoinFlip {
    
    address payable player = msg.sender;
    address payable public casino = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    uint betAmount;
    bytes32 commitHash;
    uint result;
    bool win;
    address payable contractAddress = address(this);
    
    constructor (bytes32 _commitHash) public{
        commitHash = _commitHash;
        flipCoin();
    }
    
    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
    
    
    function sendViaCall(address payable _to) internal {
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
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
    
    function placeBet() public payable {
        require(msg.value > 0);
        betAmount = msg.value;
        sendViaCall(contractAddress);
    }
    
    function matchBet() external payable {
        require (betAmount > 0, "Please place your bet" );
        require(msg.sender == casino);
        require(msg.value == betAmount);
        sendViaCall(contractAddress);
    }
    
    function payOut() internal{
        if (win == true){
            player.transfer(address(this).balance);
        }
        else {
            casino.transfer(address(this).balance);
        }
    }
    
    function reveal(uint  _choice, bytes32 _hashValue) public payable {
        require (betAmount > 0, "Please place your bet" );
        require (getBalance() == 2 * betAmount, "Please wait for the casino to match your bet" );
        require(keccak256(abi.encodePacked(_choice, _hashValue)) == commitHash);
        if(_choice == result ){
            win = true;
        }
        else {
            win =  false;
        }
        payOut();
    }
    
    
    
}
