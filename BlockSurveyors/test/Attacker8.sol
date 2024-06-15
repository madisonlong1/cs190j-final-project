// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol";

contract passwordAttacker {
    SmartSurvey public surveyContract;

    constructor(SmartSurvey _surveyContract) payable {
        surveyContract = _surveyContract;
    }
    
    function attack() public {
        
    }
}
    