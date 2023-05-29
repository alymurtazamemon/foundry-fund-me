// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../script/DeployFundMe.s.sol";
import "../../src/FundMe.sol";
import "../../script/HelperConfig.s.sol";
import "forge-std/console.sol";
import "forge-std/StdCheats.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    HelperConfig helperConfig;
    address constant USER = address(1);
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant SEND_VALUE = 0.1 ether;

    function setUp() public {
        // * deploy the fund me contract.
        DeployFundMe deploy = new DeployFundMe();
        // * retrive the instances for later use.
        (fundMe, helperConfig) = deploy.run();

        // * fund the user
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function test_SetAggregatorAddressCorrectly() external {
        address priceFeedAddress = address(fundMe.getPriceFeed());
        address response = helperConfig.activeNetworkConfig();

        assertEq(response, priceFeedAddress);
    }

    function test_RevertIf_UserDoesNotSendEnoughETH() external {
        vm.expectRevert(bytes("You need to spend more ETH!"));
        fundMe.fund();
    }

    function test_UserCanFund() external {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        address funder = fundMe.getFunder(0);

        assertEq(amountFunded, SEND_VALUE);
        assertEq(funder, USER);
    }

    modifier isFunded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function test_RevertIf_WithdrawByOtherThanOwner() external {
        vm.expectRevert(FundMe__NotOwner.selector);
        fundMe.withdraw();
    }

    function test_OwnerCanWithdrawWhenFundedBySingleUser() external isFunded {
        uint256 contractBalanceBeforeWithdraw = address(fundMe).balance;
        uint256 ownerBalanceBeforeWithdraw = address(fundMe.getOwner()).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 contractBalanceAfterWithdraw = address(fundMe).balance;
        uint256 ownerBalanceAfterWithdraw = address(fundMe.getOwner()).balance;

        assertEq(contractBalanceAfterWithdraw, 0);
        assertEq(
            ownerBalanceAfterWithdraw,
            contractBalanceBeforeWithdraw + ownerBalanceBeforeWithdraw
        );
    }

    function test_OwnerCanWithdrawWhenFundedByMultipleUser() external {
        uint8 numberOfFunders = 3;

        for (uint160 i = 1; i <= numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 contractBalanceBeforeWithdraw = address(fundMe).balance;
        uint256 ownerBalanceBeforeWithdraw = address(fundMe.getOwner()).balance;

        assertEq(contractBalanceBeforeWithdraw, numberOfFunders * SEND_VALUE);

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 contractBalanceAfterWithdraw = address(fundMe).balance;
        uint256 ownerBalanceAfterWithdraw = address(fundMe.getOwner()).balance;

        assertEq(contractBalanceAfterWithdraw, 0);
        assertEq(
            ownerBalanceAfterWithdraw,
            contractBalanceBeforeWithdraw + ownerBalanceBeforeWithdraw
        );

        // * funders array should be clean.
        vm.expectRevert();
        fundMe.getFunder(0);

        // * address to amount funded mapping should also be clean.
        for (uint160 i = 1; i <= numberOfFunders; i++) {
            uint256 funded = fundMe.getAddressToAmountFunded(address(i));

            assertEq(funded, 0);
        }
    }
}
