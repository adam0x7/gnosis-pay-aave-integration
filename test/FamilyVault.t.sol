// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {FamilyVault} from "../src/FamilyVault.sol";
import {IPool} from "aave-v3-core/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract FamilyVaultTest is Test {

    //testing here
    // testing supplying some eth to aave
    //taking a loan in usdc on a stable rate
    //simulate sending out the different allowances to family members

    FamilyVault vault;
    address gnosisPool = 0xb50201558B00496A145fE76f7424749556E326D8;

    IERC20 public wstETH = IERC20(0x6C76971f98945AE98dD7d4DFcA8711ebea946eA6);
    IERC20 public eure = IERC20(0xcB444e90D8198415266c6a2724b7900fb12FC56E);

    address owner = address(0x1);

    address[] accounts = [0x2,0x3,0x4,0x5];

    uint256 riskTolerance = 5;

    address poolOwner;



   function setUp() public {
       vault = new FamilyVault(address(this), accounts, 5, pool);
   }

    function testSupply() public {
        uint256 balanceBefore = wstETH.balanceOf(address(this));
        vault.totalSupply(10);
        uint256 balanceAfter = wstETH.balanceOf(address(this));
        assertLt(balanceBefore,balanceAfter);
    }

    function testSetAllowance() public {
        // Setting up a dummy allowance
        uint256 allowanceAmount = 1000 ether;
        address recipient = accounts[0];

        // Ensuring the function is called by the contract, acting as owner
        vault.setAllowance(recipient, allowanceAmount);

        // Check if the allowance is set correctly
        uint256 setAllowance = vault.accountsToAllowances(recipient);
        assertEq(setAllowance, allowanceAmount, "Allowance amount should be correctly set");

        // Ensure event is emitted
        vm.expectEmit(true, true, true, true);
        emit AllowanceSet(recipient, allowanceAmount);
        vault.setAllowance(recipient, allowanceAmount);
    }

    function testDisperseAllowance() public {
        address recipient = accounts[0];
        uint256 allowanceAmount = 1000 ether;
        uint256 lastTimeStamp = block.timestamp - 2 weeks - 1; // Ensure the last timestamp is more than two weeks ago

        // Set an allowance first
        vault.setAllowance(recipient, allowanceAmount);

        // Mocking the passing of two weeks
        vm.warp(block.timestamp + 2 weeks + 1);

        // Disperse the allowance
        vault.disperseAllowance(lastTimeStamp, recipient);

        // Check if the amount has been transferred (assuming EURE has been provided to the contract)
        assertEq(eure.balanceOf(recipient), allowanceAmt, "Allowance should be dispersed to the recipient");

        // Ensure event is emitted
        vm.expectEmit(true, true, true, true);
        emit AllowanceDispersed(recipient, allowanceAmount);
        vault.disperseAllowance(lastTimeStamp, recipient);
    }

    function testIsTwoWeeksPassed() public {
        uint256 currentTime = block.timestamp;
        uint256 pastTime = currentTime - 2 weeks - 1; // More than two weeks ago
        uint256 futureTime = currentTime - 1 days; // Less than two weeks ago

        // Test a timestamp more than two weeks ago
        bool resultPast = vault.isTwoWeeksPassed(pastTime);
        assertTrue(resultPast, "Should return true as more than two weeks have passed");

        // Test a timestamp less than two weeks ago
        bool resultFuture = vault.isTwoWeeksPassed(futureTime);
        assertFalse(resultFuture, "Should return false as less than two weeks have passed");
    }


    function testGetLoan() public {
        // Arrange: Prepare any state required before invoking the method
        // Assuming we have already supplied the tokens in the setup or another test
        vault.supplyTokens(50 ether);

        // Act: Call the method we're testing
        bool success = vault.getLoan();

        // Assert: Verify the outcomes of the function call
        assertTrue(success, "Loan taking should succeed");
        assertGt(IERC20(vault.eure()).balanceOf(address(vault)), 0, "Should have EURE tokens after borrowing");
    }

    function testAllowanceDisbursement() public {
        // Arrange
        uint256 allowanceAmount = 1000 ether; // Set a test allowance amount
        address recipient = gpAccounts[0]; // Use the first account in gpAccounts as the recipient
        vault.setAllowance(recipient, allowanceAmount); // Set the initial allowance

        // Simulate taking out a loan and ensuring there is enough EURE in the vault
        vault.getLoan();
        assertGt(IERC20(vault.eure()).balanceOf(address(vault)), allowanceAmount, "Vault should have enough EURE after the loan");

        // Act & Assert: First disbursement
        uint256 lastTimeStamp = block.timestamp; // Record the timestamp for the first disbursement
        vault.disperseAllowance(lastTimeStamp, recipient);
        assertEq(IERC20(vault.eure()).balanceOf(recipient), allowanceAmount, "Recipient should receive the first allowance");

        // Simulate time passing more than two weeks for the next disbursement
        vm.warp(block.timestamp + 2 weeks + 1); // Move time forward by two weeks and one second

        // Act & Assert: Second disbursement
        vault.disperseAllowance(lastTimeStamp, recipient);
        assertEq(IERC20(vault.eure()).balanceOf(recipient), 2 * allowanceAmount, "Recipient should receive the second allowance");
    }

}
