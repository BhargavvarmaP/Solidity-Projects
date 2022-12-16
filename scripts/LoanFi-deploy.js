const {ethers} = require("hardhat");

async function main() {

  const deployer = await ethers.getSigners();
  const lender = "0xE014c24271730F97A23C4E61b9c135B653E147C5";

  const LoanFi = await ethers.getContractFactory("LoanFi");
  const Loanfi = await LoanFi.deploy(lender);

  await Loanfi.deployed();

  console.log("Address of deployed contract is :",Loanfi.address);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
