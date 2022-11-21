// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


contract Migration is Initializable, UUPSUpgradeable,OwnableUpgradeable {

    IERC20Upgradeable jmmToken;
    IERC20Upgradeable madToken;
     /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

     function initialize() public initializer {
        jmmToken = IERC20Upgradeable(0x8A3F677B7f738811d9951A848002731085f469fe);
        madToken = IERC20Upgradeable(0xe6aa5F899388612913B30dc3252DDA48D013B86f);
     }

      function _authorizeUpgrade(address) internal override onlyOwner {}

     function tokenTransfer(uint256 amount) external {
        require(msg.sender != address(0),"Zero Address");
        require(madToken.balanceOf(msg.sender) >= amount,"Insufficient fund");
        uint256 jmmAmount = 10 * amount;
        // madToken.transfer(address(this), amount);
        uint256 value = madToken.balanceOf(msg.sender);
        value -= amount;
        uint256 value1 = madToken.balanceOf(address(this));
        value1 += amount;
        jmmToken.transfer(address(msg.sender), jmmAmount);
     } 
}