const contract = require('../deployments/localhost/CrowdFund.json');

async function main() {
    const crowdFund = await ethers.getContractAt("CrowdFund", contract.address);
    const tokenomics = await crowdFund.getStruct();
    console.log(tokenomics);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
