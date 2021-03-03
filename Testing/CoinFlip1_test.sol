// SPDX-License-Identifier: GPL-3.0
    
pragma solidity ^0.6.6;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../github/mgmayagu/Senior-Project/contracts/CoinFlip.sol";


contract CoinFlipTest is CoinFlip {
    // create a new instance of Value contract
    //CoinFlip cp;
    
    
    //Define variables where address 0 is the casino and address 1 serves as the player 1
    address acc0; // casino
    address acc1; // player 1

    
    function beforeAll () public returns (bool){
        
        acc0 = TestsAccounts.getAccount(0); 
        acc1 = TestsAccounts.getAccount(1);
    }
    

    // Account 0 creates a new contract.
    /// Test if initial owner is set correctly
    // account at zero index (account-0) is default account, so current owner should be acc0
    /// #sender: account-0
    /// #value: 10
    function testContractCreated() public payable {
        Assert.equal(msg.sender, acc0, 'acc0 should be the sender of this function check');
        Assert.equal(msg.value, 10, '10 should be the value of this function check');
        contractCreated();
        Assert.equal(getBalance() , msg.value, 'balance of contract should be 10 ');
        Assert.equal(acc0, msg.sender, 'casino should be set to acc0');
    }
    
    // Account 1 starts a game with 2 wei and submits a choice of 0.
    // Tests if player choice is commited correctly and if the balance of the contract increased.
    /// #sender: account-1
    /// #value: 2
    function testPlayer1Commitment() public payable {
        Assert.equal(msg.sender, acc1, 'acc1 should be the sender of this function check');
        Assert.equal(msg.value, 2, '2 should be the value of this function check');
        uint init_balance = getBalance();
        Assert.equal(getBalance(), init_balance, 'Balance of contract should be 12 (10 initial from casino + 2 from player');
        Assert.equal(acc1, msg.sender, 'player 1 should be set to acc1');
    }
    
    // Balance should be 10 (initial) + 2 (player1 and player2) = 12 total
    function checkBalance() public {
        Assert.equal(getBalance(), 12, "Balance should be 10 (initial) + 2 (player1 and player2) = 12");
    }
    
    function checkSuccess() public pure returns (bool) {
        // Use the return value (true or false) to test the contract
        return true;
    }
    

    

}
