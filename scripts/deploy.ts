import { ethers } from "hardhat";

async function main() {
  function generateRandomUint16(): number {
    return Math.floor(Math.random() * 2 ** 16);
  }

  const nftCount = 50;
  const seed = generateRandomUint16();

  const Nft = await ethers.getContractFactory("Nft");
  const nft = await Nft.deploy(nftCount, seed);

  await nft.deployed();

  console.log(`Nft deployed to ${nft.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
