//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
    1. Users can stake Ether by sending a transaction to the contract.
    2. The contract records the staking time for each user.
    3. Implement a reward mechanism where users earn rewards based on the duration of their stake.
    4. Rewards are proportional to the length of time the Ether is staked.
    5. Users can withdraw both their staked Ether and the earned rewards after the staking period ends.
    6. Ensure the contract is secure, with careful handling of users' funds and accurate reward calculations.
*/

contract EtherStaking {
    address public owner;
    uint256 public rewardRatePerSecond; //can be adjusted by the owner
    uint256 public initialContractBalance; //e nsure rewards don't exceed available funds

    // store staking information in struct
    struct Stake {
        uint256 amount; // Amount of Ether staked
        uint256 startTime; // when the staking started
        uint256 unlockTime; // when the staked Ether can be withdrawn
        bool isWithdrawn; // check if the stake is withdrawn
    }

    // dictionary store stakes by user address
    mapping(address => Stake) public stakes;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    event StakeDeposited(
        address indexed user,
        uint256 amount,
        uint256 unlockTime
    );

    modifier nonZeroAddress(address _address) {
        require(_address != address(0), "Zero address detected!");
        _;
    }

    constructor(uint256 _initialRewardRate) payable {
        owner = msg.sender;
        rewardRatePerSecond = _initialRewardRate;
        initialContractBalance = address(this).balance;
    }

    // Function to stake Ether
    function stakeEther(
        uint256 _days
    ) external payable nonZeroAddress(msg.sender) {
        require(msg.value > 0, "Cannot stake 0 Ether");
        require(_days > 0, "Staking period must be at least 1 day");

        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount == 0, "Existing stake found. Withdraw first.");

        uint256 unlockTime = block.timestamp + (_days * 1 days);

        userStake.amount = msg.value;
        userStake.startTime = block.timestamp;
        userStake.unlockTime = unlockTime;
        userStake.isWithdrawn = false;

        calculateReward(msg.sender, _days);

        emit StakeDeposited(msg.sender, msg.value, unlockTime);
    }
}
