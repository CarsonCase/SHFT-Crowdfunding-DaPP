//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {CrowdFund, TransferLock, RefundNotAvailable, FailedRaise, AlreadyComplete, NothingToClaim, Tokenomics} from "../contracts/CrowdFund.sol";

contract CrowdFundTest is Test {
    mapping(string=>address) public users;
    CrowdFund public crowdFund;
    uint endTime;
    uint goal;

    Tokenomics testTokenomics;
    function setUp() public {
        testTokenomics = Tokenomics({
            team: 1 ether,
            liquidity: 4 ether,
            marketing: 2 ether,
            investors: 2 ether,
            crowdFund: 1 ether
        });
        createUser("Owner");
        createUser("User1");
        createUser("User2");
        createUser("Attacker");
        vm.prank(users["Owner"]);

        endTime = block.timestamp + 1 days;
        goal = 1 ether;
        crowdFund = new CrowdFund(endTime, goal, testTokenomics);
    }

    function test_Tokenomics() public {
        (uint team, uint liquidity, uint marketing, uint investors, uint crowdfunds) = crowdFund.tokenomics();
        uint sum = team + liquidity + marketing + investors + crowdfunds;
        assertEq(sum, crowdFund.totalSupply());
    }

    function testFail_doubleClaimAttack() public{
        address user = users["Attacker"];
        address victim = users["User1"];
        uint quarterGoal = goal/4;
        vm.deal(victim, quarterGoal);
        vm.deal(user, quarterGoal);

        vm.prank(user);
        payable(address(crowdFund)).call{value:quarterGoal}("");

        vm.prank(victim);
        payable(address(crowdFund)).call{value:quarterGoal}("");

        vm.warp(endTime);

        // try and claim 2x to get victim's cash
        vm.prank(user);
        crowdFund.claim();

        vm.prank(user);
        crowdFund.claim();

    }

    function testFail_transferBeforeFund() public {
        address user = users["User1"];
        vm.deal(user, goal);
        vm.prank(user);
        payable(address(crowdFund)).call{value:goal}("");
        vm.warp(endTime);
        // should fund here to work
        vm.prank(user);
        crowdFund.transfer(users["User2"], goal);
    }

    function testFail_LiquidityAddUnauthorized() public{
        address user = users["User1"];

        vm.warp(endTime);
        vm.prank(user);
        crowdFund.fund(); 
    }

    function testFail_claimEarly() public{
        address user = users["User1"];
        vm.deal(user, goal/2);
        vm.prank(user);
        payable(address(crowdFund)).call{value:goal/2}("");

        // Expect a failure if not enough time has passed
        vm.warp(endTime-1);
        vm.prank(user);
        crowdFund.claim();
    }

    function testFail_LiquidityAddEarly() public{
        address user = users["Owner"];

        // Expect a failure if no time has passed or not enough time has passed
        vm.prank(user);
        crowdFund.fund(); 

        vm.warp(endTime-1);
        vm.prank(user);
        crowdFund.fund(); 
    }

    function testFail_receiveAfterTime() external{
        address user = users["User1"];

        vm.warp(endTime);

        vm.deal(user, goal);
        vm.prank(user);
        // expect a failure after time is up
        (bool success, ) = payable(address(crowdFund)).call{value:goal}("");
        if(!success) {
            revert();
        }
    }

    function testFail_doubleFund() external{
        address user = users["Owner"];

        vm.warp(endTime);
        vm.prank(user);
        crowdFund.fund();

        vm.prank(user);
        crowdFund.fund();
    }

    function test_happypath(uint depositSize) public {
        /// todo-test with many users not only one
        address user = users["User1"];
        // deposit ETH
        vm.deal(user, depositSize);
        vm.prank(user);

        if (depositSize > goal - payable(crowdFund).balance){
            vm.expectRevert();
            payable(address(crowdFund)).call{value:depositSize}("");
            return;
        }
        payable(address(crowdFund)).call{value:depositSize}("");

        // Expect back same amount of tokens
        uint returned = crowdFund.balanceOf(user);
        assertEq(returned,depositSize);

        // Jump forward to the time limit
        vm.warp(endTime);

        if(goal > depositSize){
            // if goal > depositSize, we failed and cannot transfer tokens, but can claim

            vm.prank(users["Owner"]);
            vm.expectRevert(FailedRaise.selector);
            crowdFund.fund();

            vm.prank(user);
            vm.expectRevert(TransferLock.selector);
            crowdFund.transfer(users["User2"], depositSize);
            if(depositSize != 0){
                vm.prank(user);
                uint claimed = crowdFund.claim();
                assertEq(claimed,depositSize);
            }else{
                vm.prank(user);
                vm.expectRevert(NothingToClaim.selector);
                uint claimed = crowdFund.claim();
            }
        }else{
            // if goal <= depositSize, we succeeded and tokens can be transferred but cannot be claimed

            vm.prank(user);
            vm.expectRevert(RefundNotAvailable.selector);
            crowdFund.claim();

            vm.prank(users["Owner"]);
            crowdFund.fund();

            vm.prank(user);
            crowdFund.transfer(users["User2"], depositSize);
            assertEq(crowdFund.balanceOf(user),0);
            assertEq(crowdFund.balanceOf(users["User2"]),depositSize);

            vm.prank(user);
            vm.expectRevert(AlreadyComplete.selector);
            crowdFund.claim();
        }
    }

    function createUser(string memory str) public{
        users[str]=(address(bytes20(bytes(str))));
    }
}
