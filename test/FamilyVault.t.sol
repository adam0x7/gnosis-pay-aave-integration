// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/src/Test.sol";t
import {FamilyVault} from "../src/FamilyVault.sol";
import {IPool} from "aave-v3-core/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";

contract FamilyVault is Test {

    //testing here
    // testing supplying some eth to aave
    //taking a loan in usdc on a stable rate
    //simulate sending out the different allowances to family members

    FamilyVault vault;
    IPool pool;
    IPoolAddressesProvider addressProvider = IPoolAddressesProvider(0x36616cf17557639614c1cdDb356b1B83fc0B2132);


    address owner = address(0x1);

    address[] accounts = [0x2,0x3,0x4,0x5];

    uint256 riskTolerance = 5;

    address poolOwner;



   function setUp() {
       //make sure to deal out to the necessary actors in the contract
       vault = FamilyVault(address(this), accounts, 5, pool);

       //set up the aave stuff. the pool and the provider

       //setup the vault

   }

    function testSupply() public {

    }

    function testLoanTaking() {

    }

    function testAllowanceDisbursement() {

    }
}
