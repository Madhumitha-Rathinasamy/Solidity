// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "./IToken.sol";

contract FactoryToken {
    address public implementation;
    event CreatedERC20(address token, address sender);

    constructor(address _implementation){
        implementation = _implementation;
    }

    function createToken(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 totalSupply, 
        uint8 _decimals
    ) external {
        address token = ClonesUpgradeable.clone(implementation);
        IToken(token).initialize(tokenName, tokenSymbol, totalSupply, _decimals);
        emit CreatedERC20(token, msg.sender);
    }
}