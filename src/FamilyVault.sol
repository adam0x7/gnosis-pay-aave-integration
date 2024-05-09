// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "solmate/src/tokens/ERC4626.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";

contract FamilyVault is ERC4626 {

    ERC20 wstETH = 0x6C76971f98945AE98dD7d4DFcA8711ebea946eA6;
    address owner; //safe address


    constructor(address _owner) ERC4626(wstETH, "wstETH Family Shares", "wFS") {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _; 
    }
}
