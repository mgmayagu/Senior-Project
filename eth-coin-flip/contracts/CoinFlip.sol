pragma solidity ^0.5.0;

contract CoinFlip {
    uint public taskCount = 0;

    struct Task {
        uint id;
        string content;
        bool completed;
    }

    mapping (uint => Task) public tasks;
    
    constructor() public {
        createTask("Finish up projects and hw");
    }

    function createTask(string memory _content) public {
        taskCount ++;
        tasks[taskCount] = Task(taskCount, _content, false);
    }

}