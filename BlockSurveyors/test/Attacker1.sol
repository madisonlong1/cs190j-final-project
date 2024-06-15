// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol";

// The attacker contract do selfdestruct attack
// it sends all the funds to the survey contract
// expectation: won't casue any issue as the survey contract 
// is not vulnerable to selfdestruct attack
contract SelfDestructAttacker {
        SmartSurvey public surveyContract;
        constructor(SmartSurvey _surveyContract) payable {
            surveyContract = _surveyContract;
        }
        function attack() public {
            address payable addr = payable(address(surveyContract)); //get the contracts address
            selfdestruct(addr); //try to destroy it and send the funds to the contract
        }
    }