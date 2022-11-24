// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Farming is Initializable, UUPSUpgradeable, OwnableUpgradeable {

     struct PoolInfo{
      IERC20Upgradeable lpToken;
      IERC20Upgradeable rewardToken;
      uint256 startTime;
      uint256 endTime;
      uint256 rewardInterval;
      uint256 rewardPercentage;
    }

    PoolInfo[] public poolInfo;

    struct UserInfo{
      uint256 amount;
      uint256 depositStartTime;
      bool isDeposited;
      bool hasDeposited;
    }

    mapping(uint256=> mapping(address=>UserInfo)) userInfo;
    mapping(uint256=> uint256) totalDepositeAmount;
    mapping(IERC20Upgradeable=>mapping(IERC20Upgradeable => bool)) hasPool;
    mapping(uint256=>uint256) totalDepositAmountInPool;
    mapping(uint256=>mapping(address=>uint256)) rewardsEarned;
    event DepositEndTime(uint256 endTime);
    event AddPool(IERC20Upgradeable lpToken, IERC20Upgradeable rewardToken, uint256 startTime, uint256 endTime, uint256 interval, uint256 rewardPercentage, uint256 poolId);
    event Rewards(address indexed from, address indexed to, uint256 reward);
    event WithdrawAll(address indexed from, uint256 PoolId, uint256 amount);
     /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

     function initialize() public initializer {
     }

      function _authorizeUpgrade(address) internal override onlyOwner {}

      /* *
        @dev to get total deposit amount
        @param pool id
       */
      function getTotalDepositAmount(uint256 _pid) external view returns(uint256) {
         return totalDepositAmountInPool[_pid];
      }

      // to get the pool length
      function poolLength() external view returns(uint256){
         return poolInfo.length;
      }

      // to get the current block timestamp 
      function currentBlockTime() external view returns(uint256){
         return block.timestamp;
      }

      function setDepositEndTime(uint256 _pid, uint256 _endTime) external{
         require(_endTime >= block.timestamp,"End time should be grater than the current time");
         poolInfo[_pid].endTime = _endTime;
         emit DepositEndTime(_endTime);
      }

      /* *
        @dev to get the amount deposited on a pool for a user
        @param pool id and user address
       */
      function getUserDepositTokenInPool(uint256 _pid, address userAddress) external view returns(uint256){
         return userInfo[_pid][userAddress].amount;
      }

      function addPool(
         IERC20Upgradeable _lpToken,
         IERC20Upgradeable _rewardToken,
         uint256 _startTime,
         uint256 _endTime,
         uint256 _timeInterval,
         uint256 _rewardPercentage) external {
            beforePoolAdd(_lpToken, _rewardToken, _startTime, _endTime, _rewardPercentage);
            poolInfo.push(
               PoolInfo({
                  lpToken : _lpToken,
                  rewardToken : _rewardToken,
                  startTime : _startTime,
                  endTime : _endTime,
                  rewardInterval : _timeInterval,
                  rewardPercentage : _rewardPercentage
               })
            );
            hasPool[_lpToken][_rewardToken] = true;
            uint256 poolId = poolInfo.length - 1;
            emit AddPool(_lpToken, _rewardToken, _startTime, _endTime, _timeInterval, _rewardPercentage, poolId);
         }

      function beforePoolAdd(
         IERC20Upgradeable lpToken,
         IERC20Upgradeable rewardToken,
         uint256 startTime,
         uint256 endTime,
         uint256 rewardPercentage
      ) internal view{
         require(startTime >= block.timestamp,"Start time should be greater than the current time");
         require(endTime >= startTime, "End time should be greater than the start time");
         require(rewardPercentage >= 0, "Reward percentage should be greater than 0");
         require(!hasPool[lpToken][rewardToken],"Pair is already exist");
      }

      function beforeDeposit(uint256 _pid, uint256 _amount) internal view {
         require(_pid <= poolInfo.length, "Deposit: Pool not exist");
         require(_amount > 0, "Amount should be greater than the 0");
         require(poolInfo[_pid].lpToken.balanceOf(msg.sender) >= _amount, "Insufficient fund");
         require(poolInfo[_pid].startTime <= block.timestamp,"Pool is not started yet");
         require(poolInfo[_pid].endTime >= block.timestamp,"Pool is ended");
      }

      function calculateReward(uint256 _pid, address _rewardAddress)
        public
        view
        returns (uint256, uint256)
    {
        UserInfo storage user = userInfo[_pid][_rewardAddress];
        PoolInfo storage pool = poolInfo[_pid];
        uint256 balances = user.amount;
        uint256 rewards = 0;
        uint256 timeDifferences;
        if (balances > 0) {
            if (poolInfo[_pid].endTime > 0) {
                if (block.timestamp > poolInfo[_pid].endTime) {
                    timeDifferences =
                        poolInfo[_pid].endTime -
                        user.depositStartTime;
                } else {
                    timeDifferences = block.timestamp - user.depositStartTime;
                }
            } else {
                timeDifferences = block.timestamp - user.depositStartTime;
            }
            uint256 timeFactor = timeDifferences /
                poolInfo[_pid].rewardInterval;

                uint256 _rewardRate = pool.rewardPercentage;

            rewards = ((user.amount * _rewardRate * timeFactor) /
                (1 * 10**4));
        }
        return (rewards, timeDifferences);
    }

      function claimMyReward(uint256 _pid) external {
         UserInfo storage user = userInfo[_pid][msg.sender];
         require(_pid <= poolInfo.length , "Withdraw: Pool not exist");
         require(block.timestamp > user.depositStartTime,"claim reward only after the interval");
         require(user.amount > 0,"Amount should greater than 0");
         (uint256 reward, uint256 timeDifference) = calculateReward(_pid, msg.sender);
         require(reward > 0, "Reward is 0");
         require(timeDifference / poolInfo[_pid].rewardInterval > 0, "claim reward only after the interval");
         require(poolInfo[_pid].rewardToken.balanceOf(address(this)) >= reward,"Not enough reward tokens");
         bool rewardSuccessStatus = sendRewardTo(_pid, reward, msg.sender);
         require(rewardSuccessStatus,"Transaction Failed");
         user.depositStartTime = block.timestamp;
      }

      function sendRewardTo(uint256 _pid, uint256 rewards, address _to) internal returns(bool){
         PoolInfo storage pool = poolInfo[_pid];
         require(_to != address(0),"Zero address");
         require(pool.rewardToken.balanceOf(address(this))>= rewards, "Insufficient Token");
         if(pool.lpToken == pool.rewardToken){
            if(pool.rewardToken.balanceOf(address(this)) - rewards < totalDepositAmountInPool[_pid]){
               rewards = 0;
            }
         }bool successStatus = false;
         if(rewards > 0){
            bool transferStatus = poolInfo[_pid].rewardToken.transfer(_to, rewards);
         require(transferStatus, "Transation Failed");
         uint256 reward = rewardsEarned[_pid][_to];
         reward += rewards;
         }
         if(userInfo[_pid][_to].amount == 0){
            userInfo[_pid][_to].isDeposited = false;
         }
         successStatus = true;
         emit Rewards(address(this), _to, rewards);
         return true;
      }

      function deposit(uint256 _pid, uint256 _amount) external {
         beforeDeposit(_pid, _amount);
         UserInfo storage user = userInfo[_pid][msg.sender];
         (uint256 reward,) = calculateReward(_pid, msg.sender);
         if(reward>0){
            uint256 rewardToken = poolInfo[_pid].rewardToken.balanceOf(address(this));
            require(rewardToken >= reward,"Insufficient reward");
            sendRewardTo(_pid, reward, msg.sender);
         }
            bool transferStatus = poolInfo[_pid].lpToken.transferFrom(msg.sender, address(this), _amount);
            if(transferStatus){
               user.amount += _amount;
               totalDepositAmountInPool[_pid] += _amount;
               user.depositStartTime = block.timestamp;
               user.hasDeposited = true;
               user.isDeposited = true;
         }
      }

      function withDrawAll(uint256 _pid) external{
         require(_pid <= poolInfo.length,"Pool not exits");
         PoolInfo storage pool = poolInfo[_pid];
         UserInfo storage user = userInfo[_pid][msg.sender];
        require(block.timestamp >= user.depositStartTime,"Reward interval");
        require(user.amount > 0, "Not enough reward balance");
        (uint256 reward, ) = calculateReward(_pid, msg.sender);
        if (reward > 0) {
            uint256 rewardTokens = poolInfo[_pid].rewardToken.balanceOf(address(this));
            require(rewardTokens > reward,"Insufficient reward");
            bool rewardSuccessStatus = sendRewardTo(_pid, reward, msg.sender);
            require(rewardSuccessStatus, "Claim Reward Failed");
        }
        uint256 amount = user.amount;
        user.amount = 0;
        user.isDeposited = false;
        pool.lpToken.transfer(address(msg.sender), amount);
        emit WithdrawAll(msg.sender, _pid, amount);
    }

    function withdrawRewardTokenFromPool(uint256 _pid, uint256 _amount) external onlyOwner {
      poolInfo[_pid].rewardToken.transfer(msg.sender, _amount);
    } 

    function withdrawLPToken(uint256 _pid, uint256 _amount) external {
        require(_pid <= poolInfo.length,"Pool not exits");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "Insufficient fund");
        if(pool.endTime > block.timestamp){
        (, uint256 transferableAmount) = withdrawFee(_amount);
        pool.lpToken.transfer(msg.sender, transferableAmount);
        }else{
         pool.lpToken.transfer(msg.sender, _amount);
        }
    }

    function withdrawFee(uint256 _amount) internal pure returns(uint256, uint256) {
      uint256 fee = _amount * 2 / 100;
      uint256 transferableAmount = _amount - fee;
      return (fee, transferableAmount);
    }

    function checkLpTokenBalance(uint256 _pid) external view returns(uint256){
      return poolInfo[_pid].lpToken.balanceOf(msg.sender);
    }
}