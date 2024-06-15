// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol"; 

// An attack contract about user try to access 
// unauthorised function and data (accessing private data)
// expectation: the transaction will revert
// the attacker will not be able to access the survey
contract wrongAccessEndByOwner {
    SmartSurvey public surveyContract;

    constructor(SmartSurvey _surveyContract) payable {
        surveyContract = _surveyContract;
    }

    function attack() public {
        surveyContract.registerUser("attacker", 1234);
        surveyContract.endByOwner("Survey 1");       
    }
}