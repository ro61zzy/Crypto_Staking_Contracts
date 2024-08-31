// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ERC20Staking {
    IERC20 public stakingToken; // token to be staked
    address public owner; // deployer/owner address
    uint256 public rewardRatePerSecond; //adjustable by the owner

     struct Stake {
        uint256 amount;        // Amount of tokens staked
        uint256 startTime;     // when the staking started
        uint256 unlockTime;    // when the staked tokens can be withdrawn
        bool isWithdrawn;      // if the stake is withdrawn
    }

     
    mapping(address => Stake) public stakes; //store stakes by user address

   
    mapping(address => uint256) public rewardBalance;  //store calculated rewards

    // Events for actions
    event TokensStaked(address indexed user, uint256 amount, uint256 unlockTime);
    event StakeWithdrawn(address indexed user, uint256 amount, uint256 reward);
    event RewardRateUpdated(uint256 newRewardRate);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }
    modifier stakeLocked(address _user) {
        require(block.timestamp >= stakes[_user].unlockTime, "Staking period not yet over");
        _;
    }
    modifier nonZeroAddress(address _address) {
        require(_address != address(0), "Zero address detected!");
        _;
    }

    constructor(IERC20 _stakingToken, uint256 _initialRewardRate) {
        owner = msg.sender;
        stakingToken = _stakingToken;
        rewardRatePerSecond = _initialRewardRate;
    }

    // Function to stake ERC20 tokens
    function stakeTokens(uint256 _amount, uint256 _days) external nonZeroAddress(msg.sender) {
        require(_amount > 0, "Cannot stake 0 tokens");
        require(_days > 0, "Staking period must be at least 1 day");

        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount == 0, "Existing stake found. Withdraw first.");

        uint256 unlockTime = block.timestamp + (_days * 1 days);

        // Transfer tokens from the user to the contract
        require(stakingToken.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");

        userStake.amount = _amount;
        userStake.startTime = block.timestamp;
        userStake.unlockTime = unlockTime;
        userStake.isWithdrawn = false;

      calculateReward(msg.sender, _days);

        emit TokensStaked(msg.sender, _amount, unlockTime);
    }

  // Function to calculate rewards
    function calculateReward(address _user, uint256 _days) internal {
        uint256 stakedAmount = stakes[_user].amount;
        uint256 reward = (stakedAmount * _days * rewardRatePerSecond) / 1 ether;

        rewardBalance[_user] += reward;
    }

    // Function to view current staked balance
    function viewStakedBalance() external view returns (uint256) {
        return stakes[msg.sender].amount;
    }

    // Function to view calculated rewards
    function viewRewards() external view returns (uint256) {
        return rewardBalance[msg.sender];
    }

     // Function to withdraw staked tokens and rewards
    function withdrawStake() external stakeLocked(msg.sender) nonZeroAddress(msg.sender) {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No active stake found");
        require(!userStake.isWithdrawn, "Stake already withdrawn");

        uint256 reward = rewardBalance[msg.sender];
        uint256 totalAmount = userStake.amount + reward;

        userStake.isWithdrawn = true;
        rewardBalance[msg.sender] = 0;

        // Transfer the staked tokens and rewards back to the user
        require(stakingToken.transfer(msg.sender, userStake.amount), "Token transfer failed");
        (bool sent, ) = msg.sender.call{value: reward}("");
        require(sent, "Reward withdrawal failed");

        emit StakeWithdrawn(msg.sender, userStake.amount, reward);
    }

    // Function to update the reward rate (only owner can call)
    function setRewardRate(uint256 _newRate) external onlyOwner {
        rewardRatePerSecond = _newRate;
        emit RewardRateUpdated(_newRate);
    }

}
