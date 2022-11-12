require("@nomicfoundation/hardhat-toolbox");
require('solidity-coverage');
require('dotenv').config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    hardhat: {
       forking: {
      url:process.env.AVALANCHE_MAINNET,
    }
      },
    
    fuji: {
      url: process.env.AVALANCHE_TESTNET,
      accounts: [process.env.AVALANCHE_ACCOUNT1],
  },
  bnbtestnet: {
    url: process.env.BNB_TESTNET,
    accounts: [process.env.BNB_ACCOUNT1],
},
    goerli: {
      url: process.env.GOERLI,
      accounts: [process.env.GOERLI_ACCOUNT1]
    }
  },
  etherscan:{
    apiKey:process.env.AVALANCHE_APIKEY 
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  }
};
