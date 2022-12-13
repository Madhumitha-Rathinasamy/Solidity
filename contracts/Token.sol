// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract Token is Initializable, ERC20Upgradeable{

    uint8 decimals_;

     function initialize(string memory name, string memory symbol, uint256 totalSupply, uint8 _decimals) public initializer {
        __ERC20_init_unchained(name, symbol);
        _mint(msg.sender, totalSupply);
        decimals_ = _decimals;
    }

     function decimals() public view override returns (uint8) {
        return decimals_;
    }
}