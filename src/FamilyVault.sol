// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IPool} from "aave-v3-core/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";

contract FamilyVault is ERC4626 {

    IERC20 wstETH = IERC20(0x6C76971f98945AE98dD7d4DFcA8711ebea946eA6);
    IERC20 eure = IERC20(0xcB444e90D8198415266c6a2724b7900fb12FC56E);
    IPoolAddressesProvider poolProvider;
    IPool aavePool;
    uint256 currPayPeriod;


    uint256 public constant TWO_WEEKS = 1209600;
    address owner; //safe address
    uint256 riskTolerance;

    address[] public gpAccounts; //family accounts
    mapping(address => uint256) public accountsToAllowances;


    constructor(address _owner,
                address[] memory _gpAccounts,
                uint256 _riskTolerance,
                uint256 _aaveMarketId,
                address _aaveOwner) ERC4626(wstETH) ERC20("wstETH Family Shares", "wFS"){
        owner = _owner;
        for(uint256 i = 0; i < gpAccounts.length; i++) {
            gpAccounts.push(_gpAccounts[i]);
        }
        riskTolerance = _riskTolerance;
        poolProvider = IPoolAddressesProvider(_aaveMarketId, _aaveOwner);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function setAllowance(address account, uint256 allowance) public {
        require(allowance > 0);
        accountsToAllowances[account] = allowance;
    }

    function disperseAllowance(uint256 lastTimeStamp, address account) public onlyOwner {
        require(isTwoWeeksPassed(lastTimeStamp));
        eure.transferFrom(address(this), account, accountsToAllowances[account]); // needs to be refactored to delay module for the safe account
    }

    function isTwoWeeksPassed(uint256 lastTimestamp) public view returns (bool) {
        return (block.timestamp >= lastTimestamp + TWO_WEEKS);
    }

    function getLoan() internal onlyOwner returns(bool) {
        currPayPeriod = block.timestamp;
        aavePool.supply(address(wstETH), wstETH.balanceOf(address(this)) - 1, address(this), 0);
        //how to calculate how much to borrow based off of weth??
        uint256 balanceBefore = eure.balanceOf(address(this));
        aavePool.borrow(address(eure), 10, 1, 0, address(this));

        return eure.balanceOf(address(this)) > balanceBefore;
    }

//    //yield functions
//    function swapEUReForDAI() {
//        //happens with curve
//    }
//
//    function addLiquidityToBalancer() {
//        //add liquidity position to balancer, and remove liquidity
//    }

}
