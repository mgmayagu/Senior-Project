// SPDX-License-Identifier: GPL-3.0
    
pragma solidity ^0.6.6;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../github/mgmayagu/Senior-Project/contracts/CoinFlip.sol";


contract CoinFlipTest is CoinFlip {
    CoinFlip cp;
    
    
    //Define variables referring to different accounts
    address acc0; // casino
    address acc1; // player 1
    address acc2; // malicous 2nd player

    
    function beforeAll () public returns (bool){
        // Create an instance of contract to be tested
        cp = new CoinFlip();
        
        acc0 = TestsAccounts.getAccount(0); 
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
    }
    

    // Account 0 creates a new contract.
    // Tests if initialized balance is correct and the casino address.
    /// #sender: account-0
    /// #value: 5
    function testContractCreated() public payable {
        Assert.equal(msg.sender, casino, 'acc0 should be the sender of this function check');
        Assert.equal(msg.value, 5, '2 should be the value of this function check');
        sendViaCall(msg.sender, msg.value);
        Assert.equal(getBalance(), msg.value, 'balance of contract should be 2 (how much casino put in)');
        Assert.equal(casino, msg.sender, 'casino should be set to acc0');
    }
    
    // Account 1 starts a game with 1 wei and submits a choice of 0.
    // Tests if player choice is commited correctly and if the balance of the contract increased.
    /// #sender: account-1
    /// #value: 1
    function testPlayer1Commit() public payable {
        //Assert.equal(msg.sender, cp.Player, 'acc1 should be the sender of this function check');
         Assert.equal(msg.value, 1, '1 should be the value of this function check');
         uint init_balance = getBalance();
         //playerCommit(0);
        // int gameIdx = get_game_idx(msg.sender);
        // Assert.equal(gameIdx, 0, 'Account 1 should be a player in a game now');
        // Assert.equal(get_balance(), init_balance + 1, 'Balance of contract should be 6 (5 initial from casino + 1 from player');
        // Assert.equal(Player[uint(gameIdx)].player_choice, 0, 'Player 1 choice should be 0');
    }
    
    function testPlayer2Commit() public payable {
    //     // Assert.equal(msg.sender, acc2, 'acc2 should be the sender of this function check');
        Assert.equal(msg.value, 1, '1 should be the value of this function check');
        uint init_balance = getBalance();
    //     // player_commit(1);
    //     // int gameIdx = get_game_idx(msg.sender);
    //     // Assert.equal(gameIdx, 1, 'Account 2 should be a player in a game now');
    //     Assert.equal(getBalance(), init_balance + 1, 'Balance of contract should be 7 (6 current + 1 from acc2');
    //     // Assert.equal(Games[uint(gameIdx)].player_choice, 1, 'Player 2 choice should be 1');
    }

    
}

