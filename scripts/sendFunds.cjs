// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const contract = require('../deployments/localhost/CrowdFund.json');

async function main() {
  const [owner,  feeCollector, operator] = await ethers.getSigners();
  const receipt = await owner.sendTransaction({
    to: contract.address,
    value: ethers.parseEther("0.5"), // Sends exactly 1.0 ether
  });

  console.log("New Balance of Contract "+ contract.address +" :" + await ethers.provider.getBalance(contract.address));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
