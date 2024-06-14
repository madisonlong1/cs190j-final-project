// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol"; 

contract voteDenialofService {
    // An attack contract about user try to cause a denial of service
    // by calling the vote function multiple times
    SmartSurvey public surveyContract;

    constructor(SmartSurvey _surveyContract) payable {
        surveyContract = _surveyContract;
    }

    function attack() public {
        surveyContract.registerUser("attacker", 1234); 
        surveyContract.viewSurvey("Survey 1");
        for (uint i = 0; i < 100; i++) {
            surveyContract.vote("Survey 1", 0);
        }       
    }
}