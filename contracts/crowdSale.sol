// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract crowdSale is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    PausableUpgradeable
{
    uint256 public numberOfTokenForEth;
    uint256 public startTime;
    uint256 public endTime;
    IERC20Upgradeable token;
    address addressOfToken;
    mapping(address => uint256) numOfTimes;
    mapping(address => uint256) balanceOfUser;
    uint256 tokenLimit;
    uint256 userLimit;

    event Transfer1(address from, address to, uint256 amount);

 /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() public initializer {
        numberOfTokenForEth = 10;
        startTime = block.timestamp;
        addressOfToken = 0x46d301481154a49D543047eB47f8BA4f8e746291;
        token = IERC20Upgradeable(addressOfToken);
        tokenLimit = 500;
        userLimit = 3;
        endTime = 1668587220;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    //receiving ether

    receive() external payable {}

    /* *
     * @dev owner can withdraw the ether from the contract
     * */

    function withdrawEth() public payable onlyOwner {
        uint256 ethValue = address(this).balance;
        if (ethValue > 0) {
            token.transfer(msg.sender, ethValue);
        }
    }

    /* *
     * @dev owner can withdraw the token from the contract
     * */
    function withdrawToken() public onlyOwner {
        uint256 tokenValue = token.balanceOf(address(this));
        if (tokenValue > 0) {
            token.transfer(msg.sender, tokenValue);
        }
    }

    /* *
     * @dev for changing the token
     * @Param newTokenAddress
     * */

    function updateTokenAddress(address newTokenAddress)
        external
        onlyOwner
        whenNotPaused
    {
        addressOfToken = newTokenAddress;
    }

    /**
     * @dev for changing the number of tokens for eth
     * @param numberOfToken
     **/

    function updateNumberOfTokenForEth(uint256 numberOfToken)
        external
        onlyOwner
        whenNotPaused
    {
        numberOfTokenForEth = numberOfToken;
    }

    /* *
     * @dev update the end time of the sale
     * @Requirement end time should be greater than the start time
     * @param newEndTime
     **/

    function updateEndTime(uint256 newEndTime)
        external
        onlyOwner
        whenNotPaused
    {
        require(newEndTime > startTime, "given time is already exceed");
        endTime = newEndTime;
    }

    /**
     * @dev updating token limit value and user transation limit
     * @param uTokenLimit, uUserLimit
     **/
    function updateTokenLimit(uint256 uTokenLimit, uint256 uUserLimit)
        external
        onlyOwner
        whenNotPaused
    {
        tokenLimit = uTokenLimit;
        userLimit = uUserLimit;
    }

    /**
     * @dev token to eth
     * @param numOfToken
     **/

    function tokenToEth(uint256 numOfToken)
        external
        payable
        time
        whenNotPaused
    {
        uint256 transferableAmount = numOfToken / numberOfTokenForEth;
        payable(msg.sender).transfer(transferableAmount);
        require(
            address(this).balance >= transferableAmount,
            "insufficient fund"
        );
        token.transfer(msg.sender, transferableAmount);
        emit Transfer1(address(this), msg.sender, transferableAmount);
    }

    /* *
     * @dev eth to token
     * @requirement need to check the balance of the contract
     * need to call checkNumberOfTimeUserCanTransfer, and pass params
     **/

    function ethToToken() external payable time whenNotPaused {
        uint256 numOfToken = msg.value * numberOfTokenForEth;
        require(
            token.balanceOf(address(this)) >= numOfToken,
            "insufficient fund"
        );
        checkNumberOfTimesUserCanTransfer();
        checkNumberOfToken(numOfToken);
        emit Transfer1(address(this), msg.sender, numOfToken);
    }

    /* *
     * @dev user can only transfer token for limited times
     * @param numOfToken
     **/

    function checkNumberOfTimesUserCanTransfer() internal {
        numOfTimes[msg.sender] += 1;
        require(
            numOfTimes[msg.sender] <= 3,
            "You can't trasfer more than 3 times"
        );
    }

    /* *
     * @dev user can only transfer limited tokens
     * @param numOfToken
     **/

    function checkNumberOfToken(uint256 numOfToken) internal {
        balanceOfUser[msg.sender] += numOfToken;
        require(
            balanceOfUser[msg.sender] <= tokenLimit * 10**18,
            "transation failed"
        );
        token.transfer(msg.sender, numOfToken);
    }

    // check the timing

    modifier time() {
        require(
            startTime <= block.timestamp && endTime >= block.timestamp,
            "Sales time is not started"
        );
        _;
    }
   // check the balance of eth from the contract 
    function balanceOfTheContract() external view returns(uint256){
      return address(this).balance;
    }
}
