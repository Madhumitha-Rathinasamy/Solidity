// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Token is ERC20, AccessControl, Ownable, Pausable{

 uint8 decimals_;
 bytes32 private constant Admin = 0xa729ef4e25027bc652fc8b5c4d1d902947361fa7c8e7b4905e877823f27331b3;


     constructor(string memory name, string memory symbol, uint256 totalSupply, uint8 _decimals) ERC20(name, symbol){
        _mint(msg.sender, totalSupply);
        decimals_ = _decimals;
        _grantRole(Admin, msg.sender);
        _setRoleAdmin(Admin, Admin);
    }

     function decimals() public view override returns (uint8) {
        return decimals_;
    }

      /**
     * @dev Pause `contract` - pause events.
     *
     * See {ERC20Pausable-_pause}.
     */
    function pauseContract() external virtual onlyOwner {
        _pause();
    }

    /**
     * @dev UnPause `contract` - unpause events.
     *
     * See {ERC20Pausable-_unpause}.
     */
    function unPauseContract() external virtual onlyOwner {
        _unpause();
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     */

    function mint(uint256 amount) external onlyRole(Admin){
        _mint(msg.sender, amount);
    }

}