// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol"; //import game contract

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