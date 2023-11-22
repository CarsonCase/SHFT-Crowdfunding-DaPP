module.exports = async ({getNamedAccounts, deployments}) => {

    const currentTimestampInSeconds = Math.round(Date.now() / 1000);
    const unlockTime = currentTimestampInSeconds + 60;
  
    const fundraiseGoal = hre.ethers.parseEther("1");
  
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();
    const tokenomics = {
      "team": hre.ethers.parseEther("1"),
      "liquidity": hre.ethers.parseEther("4"),
      "marketing": hre.ethers.parseEther("2"),
      "investors": hre.ethers.parseEther("2"),
      "crowdFund": hre.ethers.parseEther("1")
    }
    await deploy('CrowdFund', {
      from: deployer,
      args: [unlockTime, fundraiseGoal, tokenomics],
      log: true,
    });
    
  };
  module.exports.tags = ['MyContract'];