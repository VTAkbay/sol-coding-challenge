import "@nomicfoundation/hardhat-toolbox";

import { HardhatUserConfig } from "hardhat/config";
import dotenv from "dotenv";

dotenv.config();

const CMC_API_KEY = process.env.CMC_API_KEY;

if (!CMC_API_KEY) {
  throw new Error("Missing CMC_API_KEY environment");
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        // Toggles whether the optimizer is on or off.
        // It's good to keep it off for development
        // and turn on for when getting ready to launch.
        enabled: true,
        // The number of runs specifies roughly how often
        // the deployed code will be executed across the
        // life-time of the contract.
        runs: 300,
      },
    },
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    noColors: true,
    coinmarketcap: CMC_API_KEY,
    token: "ETH",
  },
};

export default config;
