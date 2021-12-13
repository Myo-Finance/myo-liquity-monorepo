// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./IPool.sol";

interface IActivePool is IPool {
    // --- Events ---
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolPAIDebtUpdated(uint _PAIDebt);
    event ActivePoolCollateralBalanceUpdated(uint _amount);
    event CollateralTokenAddressChanged(address _collateralTokenAddress);

    // --- Functions ---
    function sendCollateral(address _account, uint _amount) external;
}