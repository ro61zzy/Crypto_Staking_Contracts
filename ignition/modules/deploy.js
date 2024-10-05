const { ethers } = require("hardhat");

async function main() {
// Deploy the NFT Marketplace contract
// const ERC20Staking = await ethers.deployContract("ERC20Staking"); 
// await ERC20Staking.waitForDeployment();

// console.log("ERC20Staking Contract Deployed at: " + ERC20Staking.target);

// Deploy the NFT  contract
const EtherStaking = await ethers.deployContract("EtherStaking"); 
await EtherStaking.waitForDeployment();

console.log("EtherStaking Contract Deployed at: " + EtherStaking.target); 


}

// Execute the deployment script
main().catch((error) => {
  console.error(error);
  process.exitCode = 1; // Exit with failure code
});
