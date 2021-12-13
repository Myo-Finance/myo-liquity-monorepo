// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../DefaultPool.sol";

contract DefaultPoolTester is DefaultPool {
    
    function unprotectedIncreasePAIDebt(uint _amount) external {
        PAIDebt  = PAIDebt.add(_amount);
    }

    function unprotectedPayable() external payable {
        // ETH = ETH.add(msg.value);
    }
}
