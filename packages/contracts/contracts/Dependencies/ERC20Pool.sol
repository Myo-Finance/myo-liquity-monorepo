// SPDX-License-Identifier: MIT

pragma solidity 0.6.11;

import "../Dependencies/Ownable.sol";
import "../Dependencies/IERC20.sol";
import "../Interfaces/IERC20Pool.sol";

contract ERC20Pool is IERC20Pool, Ownable {

    address public erc20TokenAddress; 

    // Setter and Gettters 
    function setERC20TokenAddress(address _newTokenAddress) 
        external
        override
        onlyOwner
    {
        _setERC20TokenAddress(_newTokenAddress);
    }

    function getERC20TokenAddress() 
        override
        external 
        view 
        returns (address) 
    {
        return erc20TokenAddress;
    } 

    function getERC20TokenBalance() 
        override
        public 
        view 
        returns (uint)
    {
        return IERC20(erc20TokenAddress).balanceOf(address(this));
    }


    function _setERC20TokenAddress(address _newTokenAddress) internal {
        erc20TokenAddress = _newTokenAddress;
        emit ERC20TokenAddressChanged(_newTokenAddress);
    }

}

