require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-foundry");
require('hardhat-deploy');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    hardhat: {
      saveDeployments: true
      //accounts: ["0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"]
    },
    localhost:{
      url: "http://127.0.0.1:8545/",
      saveDeployments: true,
      default: true,
    }
  },
  namedAccounts: {
    deployer: 0
  }
};
