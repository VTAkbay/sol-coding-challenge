import { BigNumber } from "ethers";
import { Nft } from "../typechain-types/contracts";
import { ethers } from "hardhat";
import { expect } from "chai";

interface Attributes {
  backgroundColor: number;
  backgroundEffect: number;
  wings: number;
  skinColor: number;
  skinPattern: number;
  body: number;
  mouth: number;
  eyes: number;
  hat: number;
  pet: number;
  accessory: number;
  border: number;
}

function generateRandomUint16(): number {
  return Math.floor(Math.random() * 2 ** 16);
}

let nft: Nft;
const nftCount = 50;
const seed = generateRandomUint16();

const firstSigner = ethers.provider.getSigner(0);
const firstSignerAddress = firstSigner.getAddress();

const secondSigner = ethers.provider.getSigner(1);
const secondSignerAddress = secondSigner.getAddress();

function calcGenom(nftId: number) {
  const encodedData = ethers.utils.defaultAbiCoder.encode(
    ["uint256", "uint16"],
    [seed, nftId]
  );
  const hash = ethers.utils.keccak256(encodedData);
  const bytes = ethers.utils.arrayify(hash);
  const bytes9 = bytes.slice(0, 9);
  const genom = ethers.BigNumber.from(bytes9);
  return genom;
}

function expectedGenomAttributes(nftId: number): Attributes {
  // First calculating genome packed value
  const genome: BigNumber = calcGenom(nftId);
  // Then return attributes from calculated value
  return {
    backgroundColor: genome.and(63).mod(61).toNumber(),
    backgroundEffect: genome.shr(6).and(63).mod(61).toNumber(),
    wings: genome.shr(12).and(15).mod(11).toNumber(),
    skinColor: genome.shr(16).and(63).mod(41).toNumber(),
    skinPattern: genome.shr(22).and(15).mod(11).toNumber(),
    body: genome.shr(26).and(127).mod(101).toNumber(),
    mouth: genome.shr(33).and(63).mod(51).toNumber(),
    eyes: genome.shr(39).and(63).mod(61).toNumber(),
    hat: genome.shr(45).and(127).mod(101).toNumber(),
    pet: genome.shr(52).and(15).mod(11).toNumber(),
    accessory: genome.shr(56).and(31).mod(26).toNumber(),
    border: genome.shr(61).and(31).mod(31).toNumber(),
  };
}

describe("viewGenomeAttributes()", () => {
  before(async function () {
    const Nft = await ethers.getContractFactory("Nft");
    nft = await Nft.deploy("Phoenix", "Phx", nftCount, seed);
    await nft.deployed();
  });

  it("Should return correct attributes", async function () {
    for (let i = 0; i < nftCount; i++) {
      const attributes = expectedGenomAttributes(i);

      // Attributes should be correct and within the range
      await nft.viewGenomeAttributes(i).then((res) => {
        expect(res.backgroundColor)
          .to.be.within(0, 60)
          .to.be.equal(attributes.backgroundColor);
        expect(res.backgroundEffect)
          .to.be.within(0, 60)
          .to.equal(attributes.backgroundEffect);
        expect(res.wings).to.be.within(0, 10).to.equal(attributes.wings);
        expect(res.skinColor)
          .to.be.within(0, 40)
          .to.equal(attributes.skinColor);
        expect(res.skinPattern)
          .to.be.within(0, 10)
          .to.equal(attributes.skinPattern);
        expect(res.body).to.be.within(0, 100).to.equal(attributes.body);
        expect(res.mouth).to.be.within(0, 50).to.equal(attributes.mouth);
        expect(res.eyes).to.be.within(0, 60).to.equal(attributes.eyes);
        expect(res.hat).to.be.within(0, 100).to.equal(attributes.hat);
        expect(res.pet).to.be.within(0, 10).to.equal(attributes.pet);
        expect(res.accessory)
          .to.be.within(0, 25)
          .to.equal(attributes.accessory);
        expect(res.border).to.be.within(0, 30).to.equal(attributes.border);
      });
    }
  });

  it("Shoud revert when nftId is not valid", async function () {
    await expect(nft.viewGenomeAttributes(nftCount + 1)).revertedWith(
      "Not valid nftId!"
    );
  });
});

describe("ownerOf()", () => {
  beforeEach(async function () {
    const Nft = await ethers.getContractFactory("Nft");
    nft = await Nft.deploy("Phoenix", "Phx", nftCount, seed);
    await nft.deployed();
  });

  it(`Should be AddresZero owner of tokens`, async function () {
    for (let i = 0; i < nftCount; i++) {
      expect(await nft.ownerOf(i)).to.be.equal(ethers.constants.AddressZero);
    }
  });
});

describe("balanceOf()", () => {
  beforeEach(async function () {
    const Nft = await ethers.getContractFactory("Nft");
    nft = await Nft.deploy("Phoenix", "Phx", nftCount, seed);
    await nft.deployed();
  });

  it(`Should give balance of amount token for address`, async function () {
    expect(await nft.balanceOf(firstSignerAddress)).to.be.equal(0);

    for (let i = 0; i < nftCount; i++) {
      await nft.transfer(firstSignerAddress, i);
      expect(await nft.ownerOf(i)).to.be.equal(await firstSignerAddress);
    }

    expect(await nft.balanceOf(firstSignerAddress)).to.be.equal(nftCount);
  });
});

describe("transfer()", () => {
  beforeEach(async function () {
    const Nft = await ethers.getContractFactory("Nft");
    nft = await Nft.deploy("Phoenix", "Phx", nftCount, seed);
    await nft.deployed();
  });

  it("Should not transfer fresh token except owner", async function () {
    for (let i = 0; i < nftCount; i++) {
      await nft.transfer(firstSignerAddress, i);
      expect(await nft.ownerOf(i)).to.be.equal(await firstSignerAddress);
    }
  });

  it("Should transfer token", async function () {
    for (let i = 0; i < nftCount; i++) {
      await nft.transfer(firstSignerAddress, i);
      expect(await nft.ownerOf(i)).to.be.equal(await firstSignerAddress);
    }

    for (let i = 0; i < nftCount; i++) {
      await nft.transfer(secondSignerAddress, i);
      expect(await nft.ownerOf(i)).to.be.equal(await secondSignerAddress);
    }
  });

  it("Should revert ownerOf if not valid tokenId", async function () {
    await expect(nft.ownerOf(nftCount + 1)).revertedWith("not valid tokenId");
  });
});
