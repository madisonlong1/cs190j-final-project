// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol";

// reentrancy attack on the vote, view and getSurvey
// so that the attacker can vote multiple times
// view and get the survey multiple times
// expectation: the vote function has protection against reentrancy
// and other functions are view only
// so the attack will fail
contract reentrancyAttacker3 {
    SmartSurvey public smartSurvey;
    string public surveyName;

    constructor(SmartSurvey _smartSurvey, string memory _surveyName) {
        smartSurvey = _smartSurvey;
        surveyName = _surveyName;
    }

    function attack() external payable {
        //register the attacker
        smartSurvey.registerUser("attacker", 1111);
        
        //make a survey 
        string[] memory options = new string[](2); 
        options[0] = "no";
        options[1] = "yes";
        smartSurvey.create_survey{value: 100 ether}("BlockChainClass", "Should I take our course in blockchain?", options, 1000, 2,1111);
        smartSurvey.vote("BlockChainClass", 0);

        //end it
        smartSurvey.endByOwner(surveyName);
    }

    //fallback function tries to vote multiple times
    fallback() external payable {
        if (address(smartSurvey).balance >= 1 ether) {
            smartSurvey.viewSurvey(surveyName);
            smartSurvey.getSurvey(surveyName);
            smartSurvey.vote(surveyName, 1);
        }
    }
}