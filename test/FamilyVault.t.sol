// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {FamilyVault} from "../src/FamilyVault.sol";
import {IPool} from "aave-v3-core/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

import "forge-std/console.sol";

contract FamilyVaultTest is Test {

    FamilyVault vault;
    address gnosisPool = 0xb50201558B00496A145fE76f7424749556E326D8;

    IERC20 public wstETH = IERC20(0x6C76971f98945AE98dD7d4DFcA8711ebea946eA6);
    IERC20 public eure = IERC20(0xcB444e90D8198415266c6a2724b7900fb12FC56E);

    address owner = address(0x1);

    address[] accounts;

    uint256 riskTolerance = 5;



   function setUp() public {
       addAccount(address(0x1));
       addAccount(address(0x2));
       addAccount(address(0x3));
       addAccount(address(0x4));
       vault = new FamilyVault(address(this), accounts, 5, gnosisPool);

       deal(address(wstETH), address(this), 100);

       wstETH.approve(address(vault), 90);
       IERC4626(address(vault)).deposit(90, address(this));
   }

    function addAccount(address account) public {
        accounts.push(account);
    }

    function testVaultDeposit() public {
        deal(address(wstETH), address(this), 100);
        uint256 balanceBefore = wstETH.balanceOf(address(this));

        wstETH.approve(address(vault), 10);
        IERC4626(address(vault)).deposit(10, address(this));

        uint256 balanceAfter = wstETH.balanceOf(address(this));
        assertLt(balanceAfter, balanceBefore);
    }

//    function testSetAllowance() public {
//        // Setting up a dummy allowance
//        uint256 allowanceAmount = 1000 ether;
//        address recipient = accounts[0];
//
//        // Ensuring the function is called by the contract, acting as owner
//        vault.setAllowance(recipient, allowanceAmount);
//
//        // Check if the allowance is set correctly
//        uint256 setAllowance = vault.accountsToAllowances(recipient);
//        assertEq(setAllowance, allowanceAmount, "Allowance amount should be correctly set");
//
//        // Ensure event is emitted
//        vm.expectEmit(true, true, true, true);
//        vault.setAllowance(recipient, allowanceAmount);
//    }
//
//    function testDisperseAllowance() public {
//        address recipient = accounts[0];
//        uint256 allowanceAmount = 1000 ether;
//        uint256 lastTimeStamp = block.timestamp - 2 weeks - 1; // Ensure the last timestamp is more than two weeks ago
//
//        // Set an allowance first
//        vault.setAllowance(recipient, allowanceAmount);
//
//        // Mocking the passing of two weeks
//        vm.warp(block.timestamp + 2 weeks + 1);
//
//        // Disperse the allowance
//        vault.disperseAllowance(lastTimeStamp, recipient);
//
//        // Check if the amount has been transferred (assuming EURE has been provided to the contract)
//        assertEq(eure.balanceOf(recipient), allowanceAmount, "Allowance should be dispersed to the recipient");
//
//        // Ensure event is emitted
//        vm.expectEmit(true, true, true, true);
//        vault.disperseAllowance(lastTimeStamp, recipient);
//    }
//
//    function testIsTwoWeeksPassed() public {
//        uint256 currentTime = block.timestamp;
//        uint256 pastTime = currentTime - 2 weeks - 1; // More than two weeks ago
//        uint256 futureTime = currentTime - 1 days; // Less than two weeks ago
//
//        // Test a timestamp more than two weeks ago
//        bool resultPast = vault.isTwoWeeksPassed(pastTime);
//        assertTrue(resultPast, "Should return true as more than two weeks have passed");
//
//        // Test a timestamp less than two weeks ago
//        bool resultFuture = vault.isTwoWeeksPassed(futureTime);
//        assertFalse(resultFuture, "Should return false as less than two weeks have passed");
//    }

//
    function testGetLoan() public {
        uint256 supplyAmount = 15;
        vm.deal(address(vault), 1 ether);
        vm.prank(address(vault));
        wstETH.approve(gnosisPool, supplyAmount);

        vault.supplyTokensAndSetCollateral(supplyAmount);

        vm.prank(address(vault));
        (uint256 collateral, uint256 factor, uint256 borrow) = vault.checkBorrowConditions(address(wstETH));
        console.log("COLLAT", collateral);
        console.log("FACTOR", factor);
        console.log("BORROW", borrow);

        uint256 borrowAmount = 1;
        bool success = vault.getLoan(borrowAmount);

        // Assert: Verify the outcomes of the function call
        assertTrue(success, "Loan taking should succeed");
        assertGt(IERC20(vault.eure()).balanceOf(address(vault)), 0, "Should have EURE tokens after borrowing");
    }
//
//    function testAllowanceDisbursement() public {
//        // Arrange
//        uint256 allowanceAmount = 1000 ether; // Set a test allowance amount
//        address recipient = accounts[0]; // Use the first account in gpAccounts as the recipient
//        vault.setAllowance(recipient, allowanceAmount); // Set the initial allowance
//
//        // Simulate taking out a loan and ensuring there is enough EURE in the vault
//        vault.getLoan();
//        assertGt(IERC20(vault.eure()).balanceOf(address(vault)), allowanceAmount, "Vault should have enough EURE after the loan");
//
//        // Act & Assert: First disbursement
//        uint256 lastTimeStamp = block.timestamp; // Record the timestamp for the first disbursement
//        vault.disperseAllowance(lastTimeStamp, recipient);
//        assertEq(IERC20(vault.eure()).balanceOf(recipient), allowanceAmount, "Recipient should receive the first allowance");
//
//        // Simulate time passing more than two weeks for the next disbursement
//        vm.warp(block.timestamp + 2 weeks + 1); // Move time forward by two weeks and one second
//
//        // Act & Assert: Second disbursement
//        vault.disperseAllowance(lastTimeStamp, recipient);
//        assertEq(IERC20(vault.eure()).balanceOf(recipient), 2 * allowanceAmount, "Recipient should receive the second allowance");
//    }

}
