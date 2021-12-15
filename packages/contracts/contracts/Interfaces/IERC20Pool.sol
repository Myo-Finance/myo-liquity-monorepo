// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

// Common interface for the Pools.
interface IERC20Pool {
    
    // --- Events ---
    
    event ERC20BalanceUpdated(uint _newBalance);
    event ERC20TokenAddressChanged(address _newERC20TokenAddress);
    event ERC20Sent(address _to, uint _amount);

    // --- Functions ---

    function setERC20TokenAddress(address _erc20TokenAddress) external;
    function getERC20TokenAddress() external view returns (address); 
    function getERC20TokenBalance() external view returns (uint);
}
