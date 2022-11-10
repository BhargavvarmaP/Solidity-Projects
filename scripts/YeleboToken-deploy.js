const {ethers} = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    const YeleboToken=await ethers.getContractFactory("YeleboToken");
    const Yelebotoken=await YeleboToken.deploy();
    await Yelebotoken.deployed();
    console.log("Deployed Address at :",Yelebotoken.address);
}
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });