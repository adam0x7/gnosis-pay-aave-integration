// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/src/Test.sol";t
import {FamilyVault} from "../src/FamilyVault.sol";
import {IPool} from "aave-v3-core/contracts/interfaces/IPool.sol";

contract FamilyVault is Test {

    //testing here
    // testing supplying some eth to aave
    //taking a loan in usdc on a stable rate
    //simulate sending out the different allowances to family members

    FamilyVault vault;
    IPool pool;

    address owner = address(0x1);

    address[] accounts = [0x2,0x3,0x4,0x5];

    uint256 riskTolerance = 5;

    address poolOwner;

   function setUp() {

   }

    function testSupply() public {

    }

    function testLoanTaking() {

    }

    function testAllowanceDisbursement() {
        
    }
}
