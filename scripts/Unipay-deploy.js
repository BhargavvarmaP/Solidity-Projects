const {ethers} = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    const payer =  "0x84F0eefe32AaCc1a250AD56699E51A947bC351e0";
    const Unipay=await ethers.getContractFactory("UniPay");
    const unipay=await Unipay.deploy(payer);
    await unipay.deployed();
    console.log("Deployed Address at :",unipay.address);
}
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });