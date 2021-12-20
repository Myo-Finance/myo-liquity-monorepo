// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./IPool.sol";


interface IDefaultPool is IPool {
    // --- Events ---
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event DefaultPoolLUSDDebtUpdated(uint _LUSDDebt);
    event DefaultPoolERC20BalanceUpdated(uint _amount);

    // --- Functions ---
    // function sendETHToActivePool(uint _amount) external;

    function getERC20Coll() external view returns (uint);
    function receiveERC20(uint _amount) external returns (bool);
    function sendERC20ToActivePool(uint _amount) external;
}
