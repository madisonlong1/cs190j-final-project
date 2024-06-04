// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {SmartSurvey} from "../src/SurveyContract.sol";

contract SmartSurveyTest is Test {
    SmartSurvey public surveyContract;

    address alice = address(0x10);
    address bob = address(0x20);

    function setUp() public {
        surveyContract = new SmartSurvey();

        deal(alice, 10 ether);
        deal(bob, 10 ether);

        // Register alice
        vm.startPrank(alice);
        surveyContract.registerUser("alice", 1234);
        vm.stopPrank();

        // Register bob
        vm.startPrank(bob);
        surveyContract.registerUser("bob", 5678);
        vm.stopPrank();
    }

    function test_registerUser() public {
        vm.startPrank(alice);
        surveyContract.registerUser("alice", 1234);
        vm.stopPrank();

        // Retrieve user data
        (address userAddress, string memory username, uint256 password) = surveyContract.getUser(alice);
        assertEq(userAddress, alice);
        assertEq(username, "alice");
        assertEq(password, 1234);

        vm.startPrank(bob);
        surveyContract.registerUser("bob", 5678);
        vm.stopPrank();

        // Retrieve user data
        (userAddress, username, password) = surveyContract.getUser(bob);
        assertEq(userAddress, bob);
        assertEq(username, "bob");
        assertEq(password, 5678);
    }

    function test_createSurvey() public {
        string[] memory options = new string[](2);
        options[0] = "Option 1";
        options[1] = "Option 2";

        vm.startPrank(alice);
        surveyContract.createSurvey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 3600, 2);
        vm.stopPrank();

        // Retrieve survey data
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

        assertEq(owner, alice);
        assertEq(surveyName, "Survey 1");
        assertEq(question, "What is your favorite color?");
        assertEq(surveyOptions[0], "Option 1");
        assertEq(surveyOptions[1], "Option 2");
        assertEq(answers.length, 2);
        assertEq(numAllowedResponses, 2);
        assertEq(ethReward, 1 ether);
    }
}
