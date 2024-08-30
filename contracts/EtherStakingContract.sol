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
    uint256 public initialContractBalance;   //e nsure rewards don't exceed available funds


    
}