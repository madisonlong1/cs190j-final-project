pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol"; //import game contract
import {underflowAttacker} from "../src/Attacker7.sol";
import {Test, console, stdError} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

contract Attacker7Test is Test {
    SmartSurvey public surveyContract;
    underflowAttacker public attacker;
    // Remove the line that declares the 'attacker' variable
    address alice = address(0x10);


    function setUp() public {

        surveyContract = new SmartSurvey();
        attacker = new underflowAttacker(surveyContract);

        deal(address(attacker), 10 ether);
        deal(alice, 10 ether); 

    }

    function test_attacker7() public {

        vm.startPrank(alice);
        surveyContract.registerUser("alice", 1234);
        vm.stopPrank();

        string[] memory options = new string[](2); 
        options[0] = "no";
        options[1] = "yes";

        //alice will attempt to create a survey with a start time that is in the past, this action will be reverted
        vm.startPrank(alice);
        vm.expectRevert();
        uint256 overflow = type(uint256).min - 1 + block.timestamp;
        surveyContract.create_survey{value: 5 ether}("Local School Poll", "Do you support more funding for local schools?", options, overflow, 3);
        vm.stopPrank();

    }
}