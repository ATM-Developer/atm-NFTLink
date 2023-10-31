require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  defaultNetwork: "mainnet",
  networks: {
    mainnet: {
      url: "https://mainnet.infura.io/v3/948129eff38144a5af7c05b05239cba9",
      accounts: []
    },
    kovan: {
      url: "https://kovan.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: []
    },
    goerli: {
      url: "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: []
    }
  },
  etherscan: {
    apiKey: "4G2S76NN697YDSP2HRR78AAGEIDWAF9TGV"
  }
}