const {ethers} = require("hardhat");

async function main() {

  const deployer = await ethers.getSigners();
  const organizer = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";
  console.log("Address of deployer is :",deployer.address);
  
  const NFTVault = await ethers.getContractFactory("NFTVault");
  const nftvault = await NFTVault.deploy(organizer);

  await nftvault.deployed();

  console.log("Address of deployed contract is :",nftvault.address);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
