// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IToken {
    function initialize (
        string memory name, 
        string memory symbol, 
        uint256 totalSupply,
        uint8 decimals
    ) external;

}