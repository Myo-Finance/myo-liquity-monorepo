// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import './Interfaces/IDefaultPool.sol';
import "./Dependencies/SafeMath.sol";
import "./Dependencies/Ownable.sol";
import "./Dependencies/CheckContract.sol";
import "./Dependencies/console.sol";
import "./Dependencies/IERC20.sol";
import "./Dependencies/ERC20Pool.sol";

/*
 * The Default Pool holds the ETH and LUSD debt (but not LUSD tokens) from liquidations that have been redistributed
 * to active troves but not yet "applied", i.e. not yet recorded on a recipient active trove's struct.
 *
 * When a trove makes an operation that applies its pending ETH and LUSD debt, its pending ETH and LUSD debt is moved
 * from the Default Pool to the Active Pool.
 */
contract DefaultPool is Ownable, CheckContract, ERC20Pool,  IDefaultPool {
    using SafeMath for uint256;

    string constant public NAME = "DefaultPool";

    address public troveManagerAddress;
    address public activePoolAddress;
    uint256 internal ERC20Coll;  // deposited ERC20 tracker
    uint256 internal LUSDDebt;  // debt

    // --- Dependency setters ---

    function setAddresses(
        address _troveManagerAddress,
        address _activePoolAddress,
        address _erc20CollateralTokenAddress
    )
        external
        onlyOwner
    {
        checkContract(_troveManagerAddress);
        checkContract(_activePoolAddress);
        checkContract(_erc20CollateralTokenAddress);

        troveManagerAddress = _troveManagerAddress;
        activePoolAddress = _activePoolAddress;

        _setERC20TokenAddress(_erc20CollateralTokenAddress);

        emit TroveManagerAddressChanged(_troveManagerAddress);
        emit ActivePoolAddressChanged(_activePoolAddress);

        _renounceOwnership();
    }

    // --- Getters for public variables. Required by IPool interface ---

    /*
    * Returns the ERC20Coll state variable.
    * Not necessarily equal to the the contract's raw ERC20 balance - it can be forcibly sent to contracts. */
    function getERC20Coll() external view override returns (uint) {
        return ERC20Coll;
    }

    /*
    * Returns the ETH state variable.
    *
    * Not necessarily equal to the the contract's raw ETH balance - ether can be forcibly sent to contracts.
    */
    // function getETH() external view override returns (uint) {
    //     return ETH;
    // }

    function getLUSDDebt() external view override returns (uint) {
        return LUSDDebt;
    }

    // --- Pool functionality ---


    function receiveERC20(uint _amount) 
        external 
        override 
        returns (bool)
    { 
        _requireCallerIsActivePool();     

        ERC20Coll = ERC20Coll.add(_amount);
        emit DefaultPoolERC20BalanceUpdated(ERC20Coll);

        bool success = IERC20(erc20TokenAddress).transferFrom(msg.sender, address(this), _amount);
        require(success, "DefaultPool: receive ERC20 Collateral Failed");
    }

    function sendERC20ToActivePool(uint _amount) external override { 
        _requireCallerIsTroveManager();
        address activePool = activePoolAddress; // cache to save an SLOAD

        ERC20Coll = ERC20Coll.sub(_amount);
        emit DefaultPoolERC20BalanceUpdated(ERC20Coll);

        emit ERC20Sent(activePool, _amount);

        bool success = IERC20(erc20TokenAddress).transfer(activePool, _amount);
        require(success, "DefaultPool: sending ERC20 failed");
    }

    // function sendETHToActivePool(uint _amount) external override {
    //     _requireCallerIsTroveManager();
    //     address activePool = activePoolAddress; // cache to save an SLOAD
    //     ETH = ETH.sub(_amount);
    //     emit DefaultPoolETHBalanceUpdated(ETH);
    //     emit EtherSent(activePool, _amount);

    //     (bool success, ) = activePool.call{ value: _amount }("");
    //     require(success, "DefaultPool: sending ETH failed");
    // }

    function increaseLUSDDebt(uint _amount) external override {
        _requireCallerIsTroveManager();
        LUSDDebt = LUSDDebt.add(_amount);
        emit DefaultPoolLUSDDebtUpdated(LUSDDebt);
    }

    function decreaseLUSDDebt(uint _amount) external override {
        _requireCallerIsTroveManager();
        LUSDDebt = LUSDDebt.sub(_amount);
        emit DefaultPoolLUSDDebtUpdated(LUSDDebt);
    }

    // --- 'require' functions ---

    function _requireCallerIsActivePool() internal view {
        require(msg.sender == activePoolAddress, "DefaultPool: Caller is not the ActivePool");
    }

    function _requireCallerIsTroveManager() internal view {
        require(msg.sender == troveManagerAddress, "DefaultPool: Caller is not the TroveManager");
    }

    // --- Fallback function ---

    // receive() external payable {
    //     _requireCallerIsActivePool();
    //     ETH = ETH.add(msg.value);
    //     emit DefaultPoolETHBalanceUpdated(ETH);
    // }
}
