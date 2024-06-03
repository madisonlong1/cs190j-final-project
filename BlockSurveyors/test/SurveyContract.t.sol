// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {Survey} from "../src/Survey.sol";
import {SmartSurvey} from "../src/SurveyContract.sol";

contract SmartSurveyTest is Test {

    SmartSurvey public master; //master contract
        
    address alice = address(0x10);
    address bob = address(0x20);
    address charlie = address(0x13);
    string[] public option;

    function setUp() public {
        master = new SmartSurvey();
        address alice = address(0x10);
        address bob = address(0x20);
        deal(alice, 5 ether);
        deal(bob, 5 ether);
    }

    function test_registerUser() public {
        //register user
        vm.startPrank(alice);
        master.registerUser("Alice", 1234);
        vm.stopPrank();
        //assertEq(address(master).users[0x10].username, "Alice", "Alice is not registered");
    }

    function test_create_survey() public {
        //unregistered user call create()
        vm.startPrank(bob);       
        option.push("yes");
        option.push("no");
        master.create_survey{value: 5}("BobTest", "did you pass?", option, 5, 3);
        //vm.expectRevert("User is not registered");             
        vm.stopPrank();

        //registered user call create()
        vm.startPrank(alice);
        master.registerUser("Alice", 1234);
        master.create_survey{value: 5}("AliceTest", "did you pass?", option, 5, 3);
        vm.stopPrank();

        
        //assertEq(maste, 2, "Winner is not Charlie(2)");
        //assertEq(master.users(address(0x10)), "Alice", "User is not registered");
    }

    // function test_attack() public {


    // }
    //create smartSurvey
    //create suvey
    //view survey

    

    
    // Poll public poll;
    // Attacker public attacker;

    // address alice = address(0x10);
    // address bob = address(0x11);
    // address charlie = address(0x13);

    // function setUp() public {
    //     poll = new Poll();
    //     attacker = new Attacker(poll);

    //     deal(address(poll), 0 ether);
    //     deal(address(attacker), 10 ether);

    //     deal(alice, 100 ether);
    //     deal(bob, 100 ether);
    //     deal(charlie, 0 ether);
    // }

    // function test_attack() public {

    //     vm.startPrank(alice);
    //     poll.deposit{value: 100 ether}();
    //     poll.vote(0);
    //     vm.stopPrank();

    //     vm.startPrank(bob);
    //     poll.deposit{value: 100 ether}();
    //     poll.vote(1);
    //     vm.stopPrank();

    //     attacker.attack();

    //     vm.warp(block.timestamp+1);
    //     assertEq(poll.winner(), 2, "Winner is not Charlie(2)");
    // }

}

