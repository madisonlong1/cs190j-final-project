// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Survey {
    //FUNCTIONS TO INCLUDE:
    // endNow()
    // vote()
    // getResults()
    
    address private owner;
    uint256 id;
    registered_user user; // name of registered_user
    string problem; // the question the user asks
    string[] solutions; // Written multiple choice options
    uint256[] answers; // collect answers
    uint256 numAllowedResponces; // how many people have answered
    uint256 startTime; // when the survey opens
    uint256 endTime; // when the survey closes
    uint256 ethReward; // amount of reward given to users

    modifier onlyOwner {
        require(msg.sender == owner, 'call exclusive to owner');
    }

    struct registered_user {
        address userAddress;
        string username;
        uint password;
    }
}
