const {ethers} = require("hardhat");

async function main() {
    const payer = "0xE014c24271730F97A23C4E61b9c135B653E147C5";
    const UnipayV1=await ethers.getContractFactory("UniPayV1");
    const unipayV1=await UnipayV1.deploy(payer);
    await unipayV1.deployed();
    console.log("Deployed Address at :",unipayV1.address);
} //0xb5955fac9A774295335CEAC1ec565DeeCdb696E2
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });