/*pragma solidity ^0.8.24;

import {SmartSurvey} from "../src/SurveyContract.sol"; //import game contract
import {privateAttacker} from "../src/Attacker8.sol";
import {Test, console, stdError} from "forge-std/Test.sol";
import "forge-std/Vm.sol";

contract Attacker8Test is Test {
    SmartSurvey public surveyContract;
    privateAttacker public attacker;

    address alice = address(0x10);

    function setUp() public {

        surveyContract = new SmartSurvey();
        attacker = new privateAttacker(surveyContract);

        deal(address(attacker), 10 ether);
        deal(alice, 10 ether); 

    }

    function test_attacker8() public {
        
        vm.startPrank(alice);

        vm.expectRevert();
        
        
        vm.stopPrank();

    }
}
*/