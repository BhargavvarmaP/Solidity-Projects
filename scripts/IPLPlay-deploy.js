const {ethers} = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    const Organizer =  "0x84F0eefe32AaCc1a250AD56699E51A947bC351e0";
    const IPLPlay=await ethers.getContractFactory("IPLPlay");
    const iplplay=await IPLPlay.deploy(Organizer);
    await iplplay.deployed();
    console.log("Deployed Address at :",iplplay.address);
}
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });