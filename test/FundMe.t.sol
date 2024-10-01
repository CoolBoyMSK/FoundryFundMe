// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import{FundMe} from "../src/FundMe.sol";
import{DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{

    FundMe fundMe;
    address alice = makeAddr("alice");
    uint256 number=1;
    uint256 constant STARTING_BALANCE = 10 ether;
    function setUp() external{
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309adc325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(alice, STARTING_BALANCE);
    }
    modifier funded() {
        vm.prank(alice);
        fundMe.fund{value: 0.1 ether}();
        assert(address(fundMe).balance > 0);
        _;

    }
    function testMinimumDollarIsFive() public{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    function testGetVersionIsCorrect() public{
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
    function testOwnerIsDeployer() public{
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testFundUpdatesFundDataStructure() public {
        vm.prank(alice);
        fundMe.fund{value: 0.1 ether}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(alice);
        assertEq(amountFunded, 0.1 ether);

    }
    function testAddsFunderToArrayOfFunders() public {
        vm.startPrank(alice);
        fundMe.fund{value: 0.1 ether}();
        vm.stopPrank();

        address funder = fundMe.getFunder(0);
        assertEq(funder, alice);

    }
    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();

    }

    function testWithdrawFromASingleFunder() public funded {
        uint256 startingFundMeBalance = address(fundMe).balance;

        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();

        vm.stopPrank();

        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance,endingOwnerBalance);

    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), 0.1 ether);
            fundMe.fund{value: 0.1 ether}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        assert((numberOfFunders + 1) * 0.1 ether == fundMe.getOwner().balance - startingOwnerBalance);

    }

}