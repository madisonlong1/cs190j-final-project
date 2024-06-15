// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol";

contract passwordAttacker {
    SmartSurvey public surveyContract;

    constructor(SmartSurvey _surveyContract) payable {
        surveyContract = _surveyContract;
    }
    
    function attack() public {
        string[] memory options = new string[](2); 
        options[0] = "no";
        options[1] = "yes";

        surveyContract.create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 3600, 2, 1234);
    }
}
    