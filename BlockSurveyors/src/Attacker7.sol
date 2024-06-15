// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// underflow / overflow doesn't work starting 0.8

import {SmartSurvey} from "../src/SurveyContract.sol"; //import game contract

contract underflowAttacker {
        SmartSurvey public surveyContract;
        constructor(SmartSurvey _surveyContract) payable {
            surveyContract = _surveyContract;
        }
        function attack() public {

        }
    

    }