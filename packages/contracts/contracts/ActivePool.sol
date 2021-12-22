// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import './Interfaces/IActivePool.sol';
import "./Dependencies/SafeMath.sol";
import "./Dependencies/Ownable.sol";
import "./Dependencies/CheckContract.sol";
import "./Dependencies/console.sol";
import "./Dependencies/ERC20Pool.sol";

/*
 * The Active Pool holds the ETH collateral and LUSD debt (but not LUSD tokens) for all active troves.
 *
 * When a trove is liquidated, it's ETH and LUSD debt are transferred from the Active Pool, to either the
 * Stability Pool, the Default Pool, or both, depending on the liquidation conditions.
 *
 */
contract ActivePool is Ownable, CheckContract, ERC20Pool, IActivePool {
    using SafeMath for uint256;

    string constant public NAME = "ActivePool";

    address public borrowerOperationsAddress;
    address public troveManagerAddress;
    address public stabilityPoolAddress;
    address public defaultPoolAddress;
    uint256 internal ERC20Coll;  // deposited ERC20 tracker
    uint256 internal LUSDDebt;

    // --- Events ---

    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolLUSDDebtUpdated(uint _LUSDDebt);

    // --- Contract setters ---

    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _stabilityPoolAddress,
        address _defaultPoolAddress,
        address _erc20CollateralTokenAddress
    )
        external
        onlyOwner
    {
        checkContract(_borrowerOperationsAddress);
        checkContract(_troveManagerAddress);
        checkContract(_stabilityPoolAddress);
        checkContract(_defaultPoolAddress);
        checkContract(_erc20CollateralTokenAddress);

        borrowerOperationsAddress = _borrowerOperationsAddress;
        troveManagerAddress = _troveManagerAddress;
        stabilityPoolAddress = _stabilityPoolAddress;
        defaultPoolAddress = _defaultPoolAddress;

        _setERC20TokenAddress(_erc20CollateralTokenAddress);

        emit BorrowerOperationsAddressChanged(_borrowerOperationsAddress);
        emit TroveManagerAddressChanged(_troveManagerAddress);
        emit StabilityPoolAddressChanged(_stabilityPoolAddress);
        emit DefaultPoolAddressChanged(_defaultPoolAddress);

    }

    // --- Getters for public variables. Required by IPool interface ---

    /*
    * Returns the ERC20Coll state variable.
    * Not necessarily equal to the the contract's raw ERC20 balance - it can be forcibly sent to contracts. */
    function getERC20Coll() external view override returns (uint) {
        return ERC20Coll;
    }

    function getLUSDDebt() external view override returns (uint) {
        return LUSDDebt;
    }

    // --- Pool functionality ---

    function receiveERC20(address sender, uint _amount) 
        external
        override
        returns (bool)
    {
        _requireCallerIsBorrowerOperationsOrDefaultPool();

        console.log(sender);
        console.log(msg.sender);
        console.log(_amount);

        emit ActivePoolERC20BalanceUpdated(_amount);

        ERC20Coll = ERC20Coll.add(_amount);
        bool success = IERC20(erc20TokenAddress).transferFrom(sender, address(this), _amount);
        require(success, "ActivePool: receiving ERC20 failed");

        return success; 
    }

    function sendERC20(address _receiver, uint _amount) 
        external 
        override 
    { 
        _requireCallerIsBOorTroveMorSP();
        require(ERC20Coll > 0, "ActivePool: No enough collateral");

        ERC20Coll = ERC20Coll.sub(_amount);
        emit ActivePoolERC20BalanceUpdated(ERC20Coll);
        emit ERC20Sent(_receiver, _amount);

        bool success = IERC20(erc20TokenAddress).transfer(_receiver, _amount);
        require(success, "ActivePool: sending ERC20 failed");
    }


    // function sendETH(address _account, uint _amount) external override {
    //     _requireCallerIsBOorTroveMorSP();
    //     ETH = ETH.sub(_amount);
    //     emit ActivePoolETHBalanceUpdated(ETH);
    //     emit EtherSent(_account, _amount);

    //     (bool success, ) = _account.call{ value: _amount }("");
    //     require(success, "ActivePool: sending ETH failed");
    // }

    function increaseLUSDDebt(uint _amount) external override {
        _requireCallerIsBOorTroveM();
        LUSDDebt  = LUSDDebt.add(_amount);
        ActivePoolLUSDDebtUpdated(LUSDDebt);
    }

    function decreaseLUSDDebt(uint _amount) external override {
        _requireCallerIsBOorTroveMorSP();
        LUSDDebt = LUSDDebt.sub(_amount);
        ActivePoolLUSDDebtUpdated(LUSDDebt);
    }

    // --- 'require' functions ---

    function _requireCallerIsBorrowerOperationsOrDefaultPool() internal view {
        require(
            msg.sender == borrowerOperationsAddress ||
            msg.sender == defaultPoolAddress,
            "ActivePool: Caller is neither BO nor Default Pool");
    }

    function _requireCallerIsBOorTroveMorSP() internal view {
        require(
            msg.sender == borrowerOperationsAddress ||
            msg.sender == troveManagerAddress ||
            msg.sender == stabilityPoolAddress,
            "ActivePool: Caller is neither BorrowerOperations nor TroveManager nor StabilityPool");
    }

    function _requireCallerIsBOorTroveM() internal view {
        require(
            msg.sender == borrowerOperationsAddress ||
            msg.sender == troveManagerAddress,
            "ActivePool: Caller is neither BorrowerOperations nor TroveManager");
    }

    // --- Fallback function ---

    // receive() external payable {
    //     _requireCallerIsBorrowerOperationsOrDefaultPool();
    //     ETH = ETH.add(msg.value);
    //     emit ActivePoolETHBalanceUpdated(ETH);
    // }
}
