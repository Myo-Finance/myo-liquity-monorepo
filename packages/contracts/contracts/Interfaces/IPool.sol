// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "./IERC20Pool.sol";

// Common interface for the Pools.
interface IPool is IERC20Pool {
    
    // --- Events ---
    
    // event ETHBalanceUpdated(uint _newBalance);
    event LUSDBalanceUpdated(uint _newBalance);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event StabilityPoolAddressChanged(address _newStabilityPoolAddress);
    // event EtherSent(address _to, uint _amount);

    // --- Functions ---
    
    // function getETH() external view returns (uint);

    function getLUSDDebt() external view returns (uint);

    function increaseLUSDDebt(uint _amount) external;

    function decreaseLUSDDebt(uint _amount) external;
}
