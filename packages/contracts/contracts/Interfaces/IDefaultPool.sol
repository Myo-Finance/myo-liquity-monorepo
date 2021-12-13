// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./IPool.sol";


interface IDefaultPool is IPool {
    // --- Events ---
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    // event DefaultPoolLUSDDebtUpdated(uint _LUSDDebt);
    // event DefaultPoolETHBalanceUpdated(uint _ETH);
    event DefaultPoolCollateralTokenAddressChanged(address _collateralTokenAddress);

    // --- Functions ---
    function sendCollateralToActivePool(uint _amount) external;
}
