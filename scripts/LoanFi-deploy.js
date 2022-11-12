const {ethers} = require("hardhat");

async function main() {

  const deployer = await ethers.getSigners();
  const lender = "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199";
  const tokenaddress ="0x50A055fEfadBCcC70bAe668681BDC1e59368a4f7";

  const LoanFi = await ethers.getContractFactory("LoanFi");
  const Loanfi = await LoanFi.deploy(tokenaddress,lender);

  await Loanfi.deployed();

  console.log("Address of deployed contract is :",Loanfi.address);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
