// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

// Common interface for the Pools.
interface IPool {
    
    // --- Events ---
    
    event ETHBalanceUpdated(uint _newBalance);
    event PAIBalanceUpdated(uint _newBalance);
    event ActivePoolAddressChanged(address _newActivePoolAddress);
    event DefaultPoolAddressChanged(address _newDefaultPoolAddress);
    event StabilityPoolAddressChanged(address _newStabilityPoolAddress);
    event CollateralSent(address _to, uint _amount);

    // --- Functions ---
    
    function getCollateral() external view returns (uint);

    function getPAIDebt() external view returns (uint);

    function increasePAIDebt(uint _amount) external;

    function decreasePAIDebt(uint _amount) external;
}
