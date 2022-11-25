// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Locker is Initializable, UUPSUpgradeable, OwnableUpgradeable {

     struct LockerInfo{
      address user;
      IERC20Upgradeable token;
      uint256 amount;
      uint256 startTime;
      uint256 timePeriod;
    }

    LockerInfo[] public lockerInfo;
    uint256 feePercentage;

    mapping(address=>mapping(IERC20Upgradeable=>bool))existingToken;
    mapping(uint256=> mapping(address=>LockerInfo)) linfo;
    event TimePeriod(uint256 endTime);
    event Withdraw(address indexed from, address indexed to, uint256 amount);
    event LockerDetails(uint256 lockerId, address owner, IERC20Upgradeable token, uint256 amount, uint256 startTime, uint256 timePeriod);

     /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

       function initialize() public initializer {
       }

      function _authorizeUpgrade(address) internal override onlyOwner {}

      /* *
        @dev to get total deposit amount
        @param pool id
       */

      // to get the current block timestamp 
      function currentBlockTime() external view returns(uint256){
         return block.timestamp;
      }

      /* *
      * @dev user can extend the duration
      * @param lockerId and update _time duration
       */
      function updateTimeDuration(uint256 _lid, uint256 _timePeriod) external{
         LockerInfo storage locker = lockerInfo[_lid];
         require(locker.user == msg.sender,"Only user can modify");
         require(_timePeriod >= locker.timePeriod,"End time should be grater than the current time");
         locker.timePeriod = _timePeriod;
         emit TimePeriod(_timePeriod);
      }

      /* *
      * @dev user can add their token
      * @param user need to pass amount, time period and token details
       */

      function addLockerInfo(
         IERC20Upgradeable _token,
         uint256 _amount,
         uint256 _timePeriod) external {
          require(!existingToken[msg.sender][_token],"User has the same token");
           lockerInfo.push(
               LockerInfo({
                  user : msg.sender,
                  token : _token,
                  amount : _amount,
                  startTime : block.timestamp,
                  timePeriod : _timePeriod
               })
            );
            require(_amount > 0, "Amount should be greater than the 0");
            existingToken[msg.sender][_token] = true;
            uint256 lockerId = lockerInfo.length - 1;
            transferToken(lockerId, _amount);
            emit LockerDetails(lockerId, msg.sender, _token, _amount, block.timestamp, _timePeriod);
         }

         function transferToken(uint256 _lid, uint256 _amount) internal{
            bool transferStatus = lockerInfo[_lid].token.transferFrom(msg.sender, address(this), _amount);
            if(transferStatus){
               uint256 balanceOfUser = lockerInfo[_lid].token.balanceOf(msg.sender);
               balanceOfUser -= _amount;
            }
         }

         /* *
         * @dev calculating the tax fee from the user to the owner
         * @param locker id
          */
      function calculateFee(uint256 _lid) 
        internal
        returns (uint256)
    {
        LockerInfo storage locker = lockerInfo[_lid];
        uint256 balances = locker.amount;
              uint256 timeDifference = block.timestamp - locker.startTime;
                uint256 feeDuration = timeDifference / 60;
                uint256 fee = ((balances * feeDuration * feePercentage) / (1 * 10 * 2));
                locker.token.transfer(address(this), fee);
                locker.amount -= fee;
                return fee;
    }

    /* *
    * @dev user can withdraw some token after some period of time
    * @param locker id, percentage of amount and duration
     */
      function splitToken(uint256 _lid, uint256 _percentage, uint256 duration) external {
         LockerInfo storage locker = lockerInfo[_lid];
         uint256 _amount = locker.amount;
         require(_amount > 0,"Amount must be more than 0");
         require(duration >= block.timestamp,"Time duration is not completed");
         uint256 calculation = ((_amount * _percentage) / 100);
         locker.token.transfer(msg.sender, calculation);
      }

      //1000 * 2= 2000/100 20

      /* *
      * @dev user can increase their token
      * @param locker id and amount need to add
       */

      function increaseToken(uint256 _lid, uint256 _amount) external {
         LockerInfo storage locker = lockerInfo[_lid];
         require(locker.token.balanceOf(msg.sender) >= _amount);
         calculateFee(_lid);
         locker.amount += _amount;
      }

      /* *
      * @dev user can withdraw token after the period of time
      * @param locker id
       */

      function withDrawToken(uint256 _lid) external{
         LockerInfo storage locker = lockerInfo[_lid];
        require(block.timestamp >= locker.timePeriod,"Your time period is not completed yet");
        calculateFee(_lid);
        uint256 _amount = locker.amount;
        locker.token.transfer(msg.sender, _amount);
        emit Withdraw(address(this), msg.sender, _amount);

      }

      /* *
      * @dev only owner of the token can transfer the ownership of the token
      * @param locker id and new user address
       */

      function TransferTokenOwner(uint256 _lid, address newUser) external{
         LockerInfo storage locker = lockerInfo[_lid];
         require(locker.user == msg.sender, "Only user can change the user");
         locker.user = newUser;
      }
}