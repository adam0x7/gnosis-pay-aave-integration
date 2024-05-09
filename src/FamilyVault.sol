// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract FamilyVault is ERC4626 {

    IERC20 wstETH = IERC20(0x6C76971f98945AE98dD7d4DFcA8711ebea946eA6);
    IERC20 eure = IERC20(0xcB444e90D8198415266c6a2724b7900fb12FC56E);

    uint256 currPayPeriod;


    uint256 public constant TWO_WEEKS = 1209600;
    address owners; //safe address
    uint256 riskTolerance;

    address[] public gpAccounts; //family accounts
    mapping(address => uint256) public accountsToAllowances;


    constructor(address _owner,
                address[] _gpAccounts,
                uint256 _riskTolerance) ERC4626(wstETH) ERC20("wstETH Family Shares", "wFS"){
        owner = _owner;
        for(i = 0; i < gpAccounts.length; i++) {
            gpAccounts.push(_gpAccounts[i]);
        }
        riskTolerance = _riskTolerance;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function setAllowance(address calldata account, uint256 allowance) public {
        require(allowance > 0);
        accountsToAllowances[account] = allowance;
    }

    function disperseAllowance(uint256 lastTimeStamp, address account) public {
        require(isTwoWeeksPassed(lastTimeStamp));
        eure.transferFrom(address(this), account, accountsToAllowances[address]);
    }

    function isTwoWeeksPassed(uint256 lastTimestamp) public view returns (bool) {
        return (block.timestamp >= pastTimestamp + TWO_WEEKS);
    }

    function getLoan() public {
        currPayPeriod = block.timestamp;
    }

    //yield functions
    function swapEUReForDAI() {
        //happens with curve
    }

    function addLiquidityToBalancer() {
        //add liquidity position to balancer, and remove liquidity
    }

}
