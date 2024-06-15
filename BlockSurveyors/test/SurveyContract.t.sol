// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {SmartSurvey} from "../src/SurveyContract.sol";

import {SelfDestructAttacker} from "./Attacker1.sol";
import {overflowAttacker} from "./Attacker2.sol";
import {reentrancyAttacker} from "./Attacker3.sol";
import {reentrancyAttacker2} from "./Attacker4.sol";
import {reentrancyAttacker3} from "./Attacker5.sol";
import {wrongAccessEndByOwner} from "./Attacker6.sol";
import {underflowAttacker} from "./Attacker7.sol";
import {passwordAttacker} from "./Attacker8.sol";
import {voteDenialofService} from "./Attacker9.sol";
import {endDenialofService} from "./Attacker10.sol";

contract SmartSurveyTest is Test {
    SmartSurvey public surveyContract;
    uint startTime;
    address alice = address(0x10);
    address bob = address(0x20);
    address charlie = address(0x30);
    address unregister = address(0x40);

    function setUp() public {
        startTime = block.timestamp;
        surveyContract = new SmartSurvey();

        deal(alice, 10 ether);
        deal(bob, 10 ether);
        deal(charlie, 10 ether);
        deal(unregister, 10 ether);

        // Register alice
        vm.startPrank(alice);
        surveyContract.registerUser("alice", 1234);
        vm.stopPrank();

        // Register bob
        vm.startPrank(bob);
        surveyContract.registerUser("bob", 5678);
        vm.stopPrank();

        // Register charlie
        vm.startPrank(charlie);
        surveyContract.registerUser("charlie1", 9876);
        vm.stopPrank();

        //unregistered user
        vm.startPrank(unregister);
        vm.stopPrank();
    }

    //////////////////////////////////////////////////////////////// FUNCTIONAL TESTS BELOW THIS LINE
    
    // test if the register user works properly
    function test_registerUser() public {

        // Retrieve user data //use the getUser function to get the user data
        (address userAddress, string memory username, uint256 password) = surveyContract.getUser(alice);
        //all information should be the same as the user input when register
        assertEq(userAddress, alice);
        assertEq(username, "alice");
        assertEq(password, 1234);      

        // Retrieve user data //use the getUser function to get the user data
        (userAddress, username, password) = surveyContract.getUser(bob);
        //all information should be the same as the user input when register
        assertEq(userAddress, bob);
        assertEq(username, "bob");
        assertEq(password, 5678);

        (userAddress, username, password) = surveyContract.getUser(charlie);
        //all information should be the same as the user input when register
        assertEq(userAddress, charlie);
        assertEq(username, "charlie1");
        assertEq(password, 9876);
    }

    //checks if create survey create a survey and put it in the survey list
    function test_createSurvey() public {
        string[] memory options = new string[](2);
        options[0] = "Option 1";
        options[1] = "Option 2";

        vm.startPrank(alice); //alice will create survey 1 ans we will test if it actually worked
        surveyContract.create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 3600, 2,1234);
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
        ) = surveyContract.getSurvey("Survey 1"); //get the full survey data

        //now we check if the survey data is correct, it should be the same as the user input
        assertEq(owner, alice);
        assertEq(surveyName, "Survey 1");
        assertEq(question, "What is your favorite color?");
        assertEq(surveyOptions[0], "Option 1");
        assertEq(surveyOptions[1], "Option 2");
        assertEq(answers.length, 2);
        assertEq(numAllowedResponses, 2);
        assertEq(ethReward, 1 ether); //
    }

    //test the vote function 
    function test_vote() public {
        string[] memory options = new string[](3);
        options[0] = "red";
        options[1] = "blue";
        options[2] = "green";

        vm.startPrank(alice);
        //alice create a survey
        surveyContract.create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 3600, 4,1234);
        surveyContract.vote("Survey 1", 1);
        vm.stopPrank();
        //Alice votes for blue

        vm.startPrank(bob);
        surveyContract.vote("Survey 1", 1);
        vm.stopPrank();
        //Bob votes for blue

        vm.startPrank(charlie);
        surveyContract.vote("Survey 1", 2);
        vm.stopPrank();
        //Charlie votes for green

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

        //check whether they vote for the correct survey
        assertEq(owner, alice);
        assertEq(surveyName, "Survey 1");
        assertEq(question, "What is your favorite color?");
        assertEq(surveyOptions[0], "red");
        assertEq(surveyOptions[1], "blue");
        assertEq(surveyOptions[2], "green");
        assertEq(answers[0], 0);
        assertEq(answers[1],2); //check there are 2 votes for blue (alice and bob)
        assertEq(answers[2],1); //check there is 1 vote for green (charlie)

    }

    //test whehter it sends the reward correctly when a survey ends
    function test_Endnow() public {
        string[] memory options = new string[](2);
        options[0] = "no";
        options[1] = "yes";
        deal(charlie, 10 ether); //charlie will be paid for his participation
        vm.startPrank(charlie);
        surveyContract.create_survey{value: 10 ether}("Survey 2", "Do you support more funding for local schools?", options, 100000, 2,9876);
        surveyContract.vote("Survey 2", 1);
        vm.stopPrank();

        vm.startPrank(alice);
        //alice vote for 1
        surveyContract.vote("Survey 2", 1);
        vm.stopPrank();

        vm.startPrank(charlie);
        //charlie vote for 2
        surveyContract.endByOwner("Survey 2");
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert(bytes("Survey is closed")); 
        //bob vote for 1
        surveyContract.vote("Survey 2", 1);
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
        ) = surveyContract.getSurvey("Survey 2");

        assertEq(endTime <= block.timestamp, true); // ensure the survey has ended
        assertEq(answers[0], 0);
        assertEq(answers[1], 2); //we have ensured only 2 votes were cast because the survey ended
        assertEq(ethReward, 0 ether); //check the reward has been paid out
        uint256 bal = address(surveyContract).balance;
        assertEq(bal, 0); //check the contract has no balance
        uint256 balCharlie = charlie.balance;
        uint256 balAlice = alice.balance;
        assertEq(balCharlie, 5 ether); //check charlie has been paid for his particpation (5ether)
        assertEq(balAlice, 15 ether); //check alice has been paid for her particpation (5ether plus the 10 she already had)
    }

    //test if we can make a survey with no reward
    function test_no_reward() public {
        string[] memory options = new string[](2);
        options[0] = "dog";
        options[1] = "cat";

        vm.startPrank(alice);
        vm.expectRevert(bytes("Reward must be greater than 0")); //we expect a revert because the survey 
                                                                 //is being called with missing paramertrs (the eth payment)
        surveyContract.create_survey("Survey 1", "Are you a Dog person, or a Cat person?", options, 10, 12,1234);
        vm.stopPrank();
    }

    //test view survey
    function test_view_survey() public {
        string[] memory options = new string[](3);
        options[0] = "red";
        options[1] = "blue";
        options[2] = "green";

        vm.startPrank(alice);
        surveyContract.create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 1, 4,1234);
        vm.stopPrank();

        vm.startPrank(charlie);
        (
            string memory surveyName,
            string memory question,
            string[] memory surveyOptions,
            uint256[] memory answers,
            uint256 numAllowedResponses,
            uint256 startTime,
            uint256 endTime,
            uint256 ethReward
        ) = surveyContract.viewSurvey("Survey 1"); // retrieve the survey info
        vm.stopPrank();

        //check whether it correctly retrieve the information we just entered
        assertEq(keccak256(abi.encodePacked(surveyName)) == keccak256(abi.encodePacked("Survey 1")), true); 
        assertEq(keccak256(abi.encodePacked(question)) == keccak256(abi.encodePacked("What is your favorite color?")), true);
        assertEq(keccak256(abi.encodePacked(surveyOptions[0])) == keccak256(abi.encodePacked("red")), true);
        assertEq(keccak256(abi.encodePacked(surveyOptions[1])) == keccak256(abi.encodePacked("blue")), true);
        assertEq(keccak256(abi.encodePacked(surveyOptions[2])) == keccak256(abi.encodePacked("green")), true);
        assertEq(ethReward, 1 ether);

    }

    //test whether it automatically ends when voting for a survey that is expired
    function test_vote_autoEnd() public {
        string[] memory options = new string[](3);
        options[0] = "red";
        options[1] = "blue";
        options[2] = "green";

        vm.startPrank(alice);
        surveyContract.create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 1, 4,1234);
        vm.stopPrank();

        vm.startPrank(bob);
        surveyContract.vote("Survey 1", 1);
        vm.stopPrank();

        vm.warp(startTime + 1 days);//make the survey expired

        vm.startPrank(charlie);
        surveyContract.vote("Survey 1", 1);
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
        assertEq(answers[1], 1); //we have ensured only 2 votes were cast because the survey ended
        assertEq(ethReward, 0 ether); //check the reward has been paid out
        uint256 bal = address(surveyContract).balance;
        assertEq(bal, 0); //check the contract has no balance
        uint256 balBob = bob.balance;
        uint256 balAlice = alice.balance;
        assertEq(balAlice, 9 ether); //it should have 9 because alice use 1 ether to create a contract
        assertEq(balBob, 11 ether);// it should have 11 because bob receive 1 ether as reward
    }
    
    //test whether it automatically ends when viewing a survey that is expired 
    function test_view_autoEnd() public {
        string[] memory options = new string[](3);
        options[0] = "red";
        options[1] = "blue";
        options[2] = "green";

        vm.startPrank(alice);
        surveyContract.create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 1, 4,1234);
        vm.stopPrank();

        vm.startPrank(bob);
        surveyContract.vote("Survey 1", 1);
        vm.stopPrank();

        vm.warp(startTime + 1 days);
        //vm.expectRevert(bytes("Survey is expired"));

        vm.startPrank(charlie);
        surveyContract.viewSurvey("Survey 1");
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
        assertEq(answers[1], 1); //we have ensured only 2 votes were cast because the survey ended
        assertEq(ethReward, 0 ether); //check the reward has been paid out
        uint256 bal = address(surveyContract).balance;
        assertEq(bal, 0); //check the contract has no balance
        uint256 balBob = bob.balance;
        uint256 balAlice = alice.balance;
        assertEq(balAlice, 9 ether); //it should have 9 because alice use 1 ether to create a contract
        assertEq(balBob, 11 ether);// it should have 11 because bob receive 1 ether as reward
    }

    //test whether two surveys with the same name correctly generate an error
    function test_same_survey() public {
        string[] memory options = new string[](3);
        options[0] = "red";
        options[1] = "blue";
        options[2] = "green";

        //alice creates survey 1
        vm.startPrank(alice);
        surveyContract.create_survey{value: 10 ether}("Survey 1", "What is your favorite color?", options, 1, 4,1234);
        vm.stopPrank();

        vm.expectRevert(bytes("Survey with the same name already exist")); //expect to get an error
                                                                           // when they have the same name

        //bob also creates survey 1
        vm.startPrank(bob);
        surveyContract.create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 1, 4,5678);
        vm.stopPrank();
    }

    //not registered user can't create
    function test_not_registered_user_cannot_create() public {
        string[] memory options = new string[](3);
        options[0] = "red";
        options[1] = "blue";
        options[2] = "green";
        
        //expecte to get error when unregistered user tries to create a survey
        vm.expectRevert(bytes("User not registered"));

        vm.startPrank(unregister); //unregister user tries to create
        surveyContract.create_survey{value: 10 ether}("Survey 1", "What is your favorite color?", options, 1, 4,1234);
        vm.stopPrank();
    }

    //registered user with wrong password can't create
    function test_registered_user_wrong_password() public {
        string[] memory options = new string[](3);
        options[0] = "red";
        options[1] = "blue";
        options[2] = "green";

        vm.expectRevert(bytes("Wrong password"));//expect an error when enter a wrong password

        vm.startPrank(alice);//alice create a survey but enter the wrong password
        surveyContract.create_survey{value: 10 ether}("Survey 1", "What is your favorite color?", options, 1, 4,114514);
        vm.stopPrank();
    }

    //////////////////////////////////////////////////////////////// PENETRATION TESTS BELOW THIS LINE

    function test_selfDestruct() public{

        //setup the survey
        string[] memory options = new string[](2); 
        options[0] = "no";
        options[1] = "yes";
        vm.startPrank(alice);
        surveyContract.create_survey{value: 5 ether}("Local School Poll", "Do you support more funding for local schools?", options, 12, 2,1234);
        vm.stopPrank();

        //make an attacker and use it
        SelfDestructAttacker attackerSD = new SelfDestructAttacker(surveyContract); // make an attacker
        address attackerAddr = address(attackerSD); //get attackers address
       
        deal(attackerAddr, 1 ether); //pay the attacker
        vm.startPrank(attackerAddr);
        attackerSD.attack();
        vm.stopPrank();
        uint256 balance = address(surveyContract).balance;
        require(balance > 10, "The contract did not lose any ether"); //the attacker was unable rob us
       
    }

    
    function test_overflowAttacker() public {
        overflowAttacker attacker = new overflowAttacker(surveyContract);
        deal(address(attacker), 10 ether);
        //attacker will attempt to create a survey with a start time that is in the past, this action will be reverted
        vm.startPrank(address(attacker));
        vm.expectRevert();
        vm.stopPrank();

        attacker.attack();
    }

    function testReentrancyAttack() public {
        // This test sees the attacker contract register itself, create a survey, vote on the survey, and then end the survey early
        // The attacker contract will then attempt to re-enter the survey contract and claim the reward repeatedly 
        // this will steal from the master contracts "bank"
      
        //the master contract will store 50 ether from alice
        vm.startPrank(alice);
        deal(alice, 50 ether);
        string[] memory options = new string[](2); 
        options[0] = "no";
        options[1] = "yes";
        surveyContract.create_survey{value: 50 ether}("Local School Poll", "Do you support more funding for local schools?", options, 10, 3,1234);
        vm.stopPrank();

        // Deploy the reentrancy attacker contract
        reentrancyAttacker attacker = new reentrancyAttacker(surveyContract, "BlockChainClass");
        deal(address(attacker), 100 ether); //pay the attacker so it can preform the attack and attempt to repeatedly withdraw the reward
        vm.startPrank(address(attacker));
        vm.expectRevert();
        attacker.attack{value: 100 ether}();// attacker will attempt to repeatedly withdraw the reward from the survey contract
        vm.stopPrank();

        //Check the contract's balance and state
        uint256 balance = address(surveyContract).balance;
        uint256 attackerBalance = address(attacker).balance;
        assertEq(balance, 50 ether, "Balance should be 50 ether after attempted reentrancy attack"); // the contract should still have 50 ether from alice as her poll is not over
        assertEq(100 ether, address(attacker).balance, "attacker gets 100 ether"); 
    }    

   function testReentrancyAttack_endAuto() public {
        vm.startPrank(alice);
        deal(alice, 50 ether);
        string[] memory options = new string[](2); 
        options[0] = "no";
        options[1] = "yes";
        surveyContract.create_survey{value: 50 ether}("Local School Poll", "Do you support more funding for local schools?", options, 10, 3,1234);
        vm.stopPrank();

        vm.warp(startTime + 1 days);
        
        // Deploy the reentrancy attacker contract
        reentrancyAttacker2 attacker = new reentrancyAttacker2(surveyContract, "BlockChainClass");
        deal(address(attacker), 100 ether); //pay the attacker so it can preform the attack and attempt to repeatedly withdraw the reward
        vm.startPrank(address(attacker));
        vm.expectRevert();
        attacker.attack{value: 100 ether}();// attacker will attempt to repeatedly withdraw the reward from the survey contract
        vm.stopPrank();

        //Check the contract's balance and state
        uint256 balance = address(surveyContract).balance;
        uint256 attackerBalance = address(attacker).balance;
        assertEq(balance, 50 ether, "Balance should be 50 ether after attempted reentrancy attack"); // the contract should still have 50 ether from alice as her poll is not over
        assertEq(100 ether, address(attacker).balance, "attacker gets 100 ether"); 
    }   

    function testReentrancyAttack_endNow() public {
        vm.startPrank(alice);
        deal(alice, 50 ether);
        string[] memory options = new string[](2); 
        options[0] = "no";
        options[1] = "yes";
        surveyContract.create_survey{value: 50 ether}("Local School Poll", "Do you support more funding for local schools?", options, 10, 3,1234);
        vm.stopPrank();
        
        vm.warp(startTime + 1 days);

        // Deploy the reentrancy attacker contract
        reentrancyAttacker3 attacker = new reentrancyAttacker3(surveyContract, "BlockChainClass");
        deal(address(attacker), 100 ether); //pay the attacker so it can preform the attack and attempt to repeatedly withdraw the reward
        vm.startPrank(address(attacker));
        vm.expectRevert();
        attacker.attack{value: 100 ether}();// attacker will attempt to repeatedly withdraw the reward from the survey contract
        vm.stopPrank();

        //Check the contract's balance and state
        uint256 balance = address(surveyContract).balance;
        uint256 attackerBalance = address(attacker).balance;
        assertEq(balance, 50 ether, "Balance should be 50 ether after attempted reentrancy attack"); // the contract should still have 50 ether from alice as her poll is not over
        assertEq(100 ether, address(attacker).balance, "attacker gets 100 ether"); 
    }   

    function test_underflow_attacker() public {
        underflowAttacker attacker = new underflowAttacker(surveyContract);
        deal(address(attacker), 10 ether);
        //attacker will attempt to create a survey underflow num, this action will be reverted
        vm.startPrank(address(attacker));
        vm.expectRevert();
        vm.stopPrank();

        attacker.attack();
    }


    function test_password_attack() public {
        
        string[] memory options = new string[](2); 
        options[0] = "no";
        options[1] = "yes";

        passwordAttacker passwordAttack = new passwordAttacker(surveyContract); // make an attacker
        deal(address(passwordAttack), 10 ether);

        vm.startPrank(address(passwordAttack));
        vm.expectRevert("User not registered");
        vm.stopPrank();

        passwordAttack.attack();
    }


    function test_wrongAccessEndNow() public {
        string[] memory options = new string[](2);
        wrongAccessEndByOwner attacker_wrongAccessEndNow = new wrongAccessEndByOwner(surveyContract);
        deal(address(attacker_wrongAccessEndNow), 10 ether);

        vm.startPrank(alice);
        surveyContract.create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 3600, 2, 1234);
        vm.stopPrank();
        
        vm.startPrank(address(attacker_wrongAccessEndNow));
        vm.expectRevert(bytes("only the owner can end a survey early"));
        vm.stopPrank();

        attacker_wrongAccessEndNow.attack();
    }


    function test_voteDenialofService() public {
        string[] memory options = new string[](2);
        voteDenialofService attacker_voteDenialofService = new voteDenialofService(surveyContract);
        deal(address(attacker_voteDenialofService), 10 ether);

        vm.startPrank(alice);
        surveyContract.create_survey{value: 4 ether}("Survey 1", "What is your favorite color?", options, 3600, 2, 1234);
        vm.stopPrank();

        vm.startPrank(address(attacker_voteDenialofService));
        vm.expectRevert(bytes("User has already voted"));
        vm.stopPrank();

        attacker_voteDenialofService.attack();

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


    function test_endDenialofService() public {
        string[] memory options = new string[](2);
        endDenialofService attacker_endDenialofService = new endDenialofService(surveyContract);
        deal(address(attacker_endDenialofService), 10 ether);

        vm.startPrank(alice);
        surveyContract.create_survey{value: 1 ether}("Survey 1", "What is your favorite color?", options, 3600, 2, 1234);
        surveyContract.vote("Survey 1", 1);
        vm.stopPrank();

        vm.startPrank(address(attacker_endDenialofService));
        vm.expectRevert(bytes("only the owner can end a survey early"));
        vm.stopPrank();

        attacker_endDenialofService.attack();

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
