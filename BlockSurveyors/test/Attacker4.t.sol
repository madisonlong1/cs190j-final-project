// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol"; //import game contract
import {attackByEndNow} from "../src/Attacker4.sol";
import {Test, console, stdError} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

contract Attacker4Test is Test {
    SmartSurvey public surveyContract;
    attackByEndNow public attacker;
    // Remove the line that declares the 'attacker' variable
    address alice = address(0x10);
    

    function setUp() public {
        
        surveyContract = new SmartSurvey();
        attacker = new attackByEndNow(surveyContract);

        deal(address(attacker), 10 ether);
        deal(alice, 10 ether); 
    }

    function test_attacker4() public {
        string[] memory options = new string[](2);

        // Register alice
        vm.startPrank(alice);
        surveyContract.registerUser("alice", 1234);
        vm.stopPrank();


        vm.startPrank(alice);
        surveyContract.create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 3600, 2);
        vm.stopPrank();

        
        vm.startPrank(address(attacker));
        vm.expectRevert(bytes("only the owner can end a survey early"));
        vm.stopPrank();

        attacker.attack();
    }
}