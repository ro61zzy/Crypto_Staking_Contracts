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
}
