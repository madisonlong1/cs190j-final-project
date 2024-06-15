// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol";

// An attack contract about user try to access
// unauthorised password (accessing private data)
// expectation: the transaction will revert
// since the account didn't match the password
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
    