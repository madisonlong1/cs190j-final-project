// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

import {Survey} from "../src/Survey.sol";
import {SmartSurvey} from "../src/SurveyContract.sol";

contract PollTest is Test {
    Poll public poll;
    Attacker public attacker;

    address alice = address(0x10);
    address bob = address(0x11);
    address charlie = address(0x13);

    function setUp() public {
        poll = new Poll();
        attacker = new Attacker(poll);

        deal(address(poll), 0 ether);
        deal(address(attacker), 10 ether);

        deal(alice, 100 ether);
        deal(bob, 100 ether);
        deal(charlie, 0 ether);
    }

    function test_attack() public {

        vm.startPrank(alice);
        poll.deposit{value: 100 ether}();
        poll.vote(0);
        vm.stopPrank();

        vm.startPrank(bob);
        poll.deposit{value: 100 ether}();
        poll.vote(1);
        vm.stopPrank();

        attacker.attack();

        vm.warp(block.timestamp+1);
        assertEq(poll.winner(), 2, "Winner is not Charlie(2)");
    }

}

