// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol"; //import game contract
import {Test, console, stdError} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {attackByEndNow} from "../src/Attacker4.sol";
import {voteDenialofService} from "../src/Attacker5.sol";
import {endDenialofService} from "../src/Attacker6.sol";


contract AttackerTest is Test {
    SmartSurvey public surveyContract;
    attackByEndNow public attacker4;
    voteDenialofService public attacker5;
    endDenialofService public attacker6;
    
    address alice = address(0x10);
    address bob = address(0x20);
    
    function setUp() public {      
        surveyContract = new SmartSurvey();
        attacker4 = new attackByEndNow(surveyContract);
        attacker5 = new voteDenialofService(surveyContract);
        attacker6 = new endDenialofService(surveyContract);

        deal(address(attacker4), 10 ether);
        deal(address(attacker5), 10 ether);
        deal(address(attacker6), 10 ether);
        deal(alice, 10 ether); 
        deal(bob, 10 ether);
    }

    function test_attacker4() public {
        string[] memory options = new string[](2);

        // Register alice
        vm.startPrank(alice);
        surveyContract.registerUser("alice", 1234);
        vm.stopPrank();


        vm.startPrank(alice);
        surveyContract.create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 3600, 2, 1234);
        vm.stopPrank();

        
        vm.startPrank(address(attacker4));
        vm.expectRevert(bytes("only the owner can end a survey early"));
        vm.stopPrank();

        attacker4.attack();
    }

    function test_attacker5() public {
        string[] memory options = new string[](2);

        // Register alice
        vm.startPrank(alice);
        surveyContract.registerUser("alice", 1234);
        vm.stopPrank();

        vm.startPrank(alice);
        surveyContract.create_survey{value: 4 ether}("Survey 1", "What is your favorite color?", options, 3600, 2, 1234);
        vm.stopPrank();

        vm.startPrank(address(attacker5));
        vm.expectRevert(bytes("User has already voted"));
        vm.stopPrank();

        attacker5.attack();

        vm.startPrank(bob);
        surveyContract.vote("Survey 1", 0);
        vm.stopPrank();

        vm.startPrank(alice);
        surveyContract.vote("Survey 1", 0);
        surveyContract.endByOwner("Survey 1");
        vm.stopPrank();

        
        (
            address owner,
            string memory surveyName,
            string memory question,
            string[] memory surveyOptions,
            uint256[] memory answers,
            uint256 numAllowedResponses,
            uint256 startTime,
            uint256 endTime,
            uint256 ethReward
        ) = surveyContract.getSurvey("Survey 1");

        assertEq(endTime <= block.timestamp, true); // ensure the survey has ended
        assertEq(answers[0], 2);
        assertEq(answers[1], 0); 
        assertEq(ethReward, 0 ether); //check the reward has been paid out
        uint256 bal = address(surveyContract).balance;
        assertEq(bal, 0); //check the contract has no balance
        uint256 balBob = bob.balance;
        uint256 balAlice = alice.balance;
        assertEq(balBob, 12 ether); //check bob has been paid for his particpation 
        assertEq(balAlice, 8 ether); //check alice has been paid for her particpation 
    }

    function test_attacker6() public {
        string[] memory options = new string[](2);

        vm.startPrank(alice);
        surveyContract.registerUser("alice", 1234);
        vm.stopPrank();

        vm.startPrank(alice);
        surveyContract.create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 3600, 2, 1234);
        surveyContract.vote("Survey 1", 1);
        vm.stopPrank();

        vm.startPrank(address(attacker6));
        vm.expectRevert(bytes("only the owner can end a survey early"));
        vm.stopPrank();

        attacker6.attack();

        vm.startPrank(alice);
        surveyContract.endByOwner("Survey 1");
        vm.stopPrank();

        (
            address owner,
            string memory surveyName,
            string memory question,
            string[] memory surveyOptions,
            uint256[] memory answers,
            uint256 numAllowedResponses,
            uint256 startTime,
            uint256 endTime,
            uint256 ethReward
        ) = surveyContract.getSurvey("Survey 1");

        assertEq(endTime <= block.timestamp, true); // ensure the survey has ended
        assertEq(answers[0], 0);
        assertEq(answers[1], 1); 
        assertEq(ethReward, 0 ether); //check the reward has been paid out
        uint256 bal = address(surveyContract).balance;
        assertEq(bal, 0); //check the contract has no balance
        uint256 balAlice = alice.balance;
        assertEq(balAlice, 10 ether); //check alice has been paid
    }
}