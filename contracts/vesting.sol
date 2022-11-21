/**
* receive()
* payable
* fallback()
must needed to create beacon proxy
 */

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract vesting is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    PausableUpgradeable
{
    uint256 public startTime;
    uint256 public endTime;
    mapping(address => uint256) public endTimeOfUser;
    mapping(address => uint256) public balanceOfToken;
    address _token;
    IERC20Upgradeable token;
    uint256 public timeInterval;
    uint256 public endTimeSet;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {} // mapping(address =>mapping(address => uint256)) balanceOfUsers;

    function initialize() public initializer {
        startTime = block.timestamp;
        endTimeSet = 360 seconds;
        endTime = startTime + endTimeSet;
        endTimeOfUser[msg.sender] = endTime;
        _token = 0x8A3F677B7f738811d9951A848002731085f469fe;
        token = IERC20Upgradeable(_token);
        timeInterval = 60;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    // receive native currency to the contract
    receive() external payable {}

    // to check time is completed or not
    modifier mEndTime() {
        require(block.timestamp > endTime, "Transaction failed");
        _;
    }

    /**
     *@dev we are sending the token to the user
     * requirement: We need to check the sale is completed or not, so we are checking end time
     */
    function getToken() external mEndTime {
        uint256 second = block.timestamp - endTimeOfUser[msg.sender];
        uint256 timeFactor = (second / timeInterval); // 2
        endTimeOfUser[msg.sender] += second;
        require(timeFactor > 0,"minium time required");
        if (balanceOfToken[msg.sender] >= timeFactor) {  
            balanceOfToken[msg.sender] -= timeFactor;
            token.transfer(msg.sender, timeFactor);
        } else {
            token.transfer(msg.sender, balanceOfToken[msg.sender]);
            balanceOfToken[msg.sender] = 0;
        }
    }

    /**
     *@dev allocate the token for the user
     */
    function sendEth() external payable time {
        uint256 numOfToken = msg.value * 1000;
        balanceOfToken[msg.sender] += numOfToken;
    }

    /* *
     *@dev updating the intervals time
     *@params end time
     */

    function updateTimeInterval(uint256 time_) public {
        timeInterval = time_;
    }

    function updateEndTime(uint256 time_) public {
        endTimeSet = time_;
    }

    //we are check the sale time

    modifier time() {
        require(
            startTime <= block.timestamp && endTime >= block.timestamp,
            "Sales time is not started"
        );
        _;
    }

//get the value of contract balance
    function contractBalance() external view returns(uint256){
        return token.balanceOf(address(this));
    }

//get the balance of msg.sender
    function balanceOfUser() external view returns(uint256){
        return balanceOfToken[msg.sender];
    }

    fallback() external payable{}
}
