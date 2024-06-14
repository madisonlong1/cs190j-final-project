// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol"; 

contract attackByEndNow {
    // An attack contract about user try to access 
    // unauthorised function and data ()
    SmartSurvey public surveyContract;

    constructor(SmartSurvey _surveyContract) payable {
        surveyContract = _surveyContract;
    }

    function attack() public {
        surveyContract.registerUser("attacker", 1234);
        surveyContract.endByOwner("Survey 1");       
    }
}