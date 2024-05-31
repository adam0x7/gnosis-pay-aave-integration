// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IPool} from "aave-v3-core/contracts/interfaces/IPool.sol";
import {IPoolAddressesProvider} from "aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";

contract FamilyVault is ERC4626 {

    // Custom errors
    error OnlyOwner();
    error InvalidAllowance();
    error AllowanceAlreadySet();
    error TwoWeeksNotPassed();
    error LoanFailed();

    // Custom events
    event AllowanceSet(address indexed account, uint256 allowance);
    event AllowanceDispersed(address indexed account, uint256 amount);
    event LoanTaken(uint256 amount);

    IERC20 public wstETH = IERC20(0x6C76971f98945AE98dD7d4DFcA8711ebea946eA6);
    IERC20 public eure = IERC20(0xcB444e90D8198415266c6a2724b7900fb12FC56E);

    IPoolAddressesProvider poolProvider;
    IPool aavePool;
    uint256 currPayPeriod;

    uint256 public constant TWO_WEEKS = 1209600;
    address owner; // Safe address
    uint256 riskTolerance;

    address[] public gpAccounts; // Family accounts
    mapping(address => uint256) public accountsToAllowances;

    /**
     * @param _owner The address of the owner (safe address).
     * @param _gpAccounts An array of family account addresses.
     * @param _riskTolerance The risk tolerance level.
     * @param _aaveOwner The Aave owner address.
     */
    constructor(
        address _owner,
        address[] memory _gpAccounts,
        uint256 _riskTolerance,
        address _pool
    ) ERC4626(wstETH) ERC20("wstETH Family Shares", "wFS") {
        owner = _owner;
        for (uint256 i = 0; i < _gpAccounts.length; i++) {
            gpAccounts.push(_gpAccounts[i]);
        }
        riskTolerance = _riskTolerance;
        aavePool = IPool(_pool);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    /**
     * @notice Sets the allowance for a given account.
     * @param account The account address.
     * @param allowance The allowance amount.
     */
    function setAllowance(address account, uint256 allowance) public onlyOwner {
        if (allowance <= 0) revert InvalidAllowance();
        if (accountsToAllowances[account] > 0) revert AllowanceAlreadySet();
        accountsToAllowances[account] = allowance;
        emit AllowanceSet(account, allowance);
    }

    /**
     * @notice Disperses the allowance to the specified account if two weeks have passed.
     * @param lastTimeStamp The last timestamp when allowance was dispersed.
     * @param account The account address to disperse allowance to.
     */
    function disperseAllowance(uint256 lastTimeStamp, address account) public onlyOwner {
        if (!isTwoWeeksPassed(lastTimeStamp)) revert TwoWeeksNotPassed();
        uint256 amount = accountsToAllowances[account];
        eure.transferFrom(address(this), account, amount); // Needs to be refactored to delay module for the safe account
        emit AllowanceDispersed(account, amount);
    }

    /**
     * @notice Checks if two weeks have passed since the given timestamp.
     * @param lastTimestamp The last timestamp to check against.
     * @return bool True if two weeks have passed, false otherwise.
     */
    function isTwoWeeksPassed(uint256 lastTimestamp) public view returns (bool) {
        return (block.timestamp >= lastTimestamp + TWO_WEEKS);
    }

    /**
     * @notice Takes a loan from Aave using the wstETH collateral.
     * @return bool True if the loan was successfully taken, false otherwise.
     */

    function supplyTokens(uint256 _amount) internal onlyOwner  {
        aavePool.supply(address(wstETH), wstETH.balanceOf(address(this)) - _amount, address(this), 0);
    }
    function getLoan() internal onlyOwner returns (bool) {
        currPayPeriod = block.timestamp;


        // How to calculate how much to borrow based off of wstETH??
        uint256 balanceBefore = eure.balanceOf(address(this));
        aavePool.borrow(address(eure), 10, 1, 0, address(this));

        bool success = eure.balanceOf(address(this)) > balanceBefore;
        if (!success) revert LoanFailed();

        emit LoanTaken(eure.balanceOf(address(this)) - balanceBefore);
        return success;
    }

    //TODO add loan repayment based on eth price going above a certain price. set limit order to cover the loan

    // yield functions
    // function swapEUReForDAI() {
    //     // happens with curve
    // }

    // function addLiquidityToBalancer() {
    //     // add liquidity position to balancer, and remove liquidity
    // }
}
