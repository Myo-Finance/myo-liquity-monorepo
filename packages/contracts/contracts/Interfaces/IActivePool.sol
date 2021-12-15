// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./IPool.sol";


interface IActivePool is IPool {
    // --- Events ---
    event BorrowerOperationsAddressChanged(address _newBorrowerOperationsAddress);
    event TroveManagerAddressChanged(address _newTroveManagerAddress);
    event ActivePoolLUSDDebtUpdated(uint _LUSDDebt);
    // event ActivePoolETHBalanceUpdated(uint _ETH);
    event ActivePoolERC20BalanceUpdated(uint _amount);

    // --- Functions ---
    // function sendETH(address _account, uint _amount) external;

    function sendERC20(address _account, uint _amount) external; 
}
