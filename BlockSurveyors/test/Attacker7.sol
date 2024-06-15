// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// underflow / overflow doesn't work starting 0.8

import {SmartSurvey} from "../src/SurveyContract.sol";

// underflow attack on passing the underflow number
// to manipulate the survey end time.
// expectation: the transaction will revert
contract underflowAttacker {
    SmartSurvey public surveyContract;

    constructor(SmartSurvey _surveyContract) payable {
        surveyContract = _surveyContract;
    }
    
    function attack() public {
        string[] memory options = new string[](2); 
        options[0] = "no";
        options[1] = "yes";
        surveyContract.registerUser("attacker", 1234);
        uint256 _duration = type(uint256).min - 1 + block.timestamp;
        surveyContract.create_survey("Local School Poll", "Do you support more funding for local schools?", options, _duration, 3,1234);
    }
}