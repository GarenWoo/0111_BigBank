// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const ownableContract = await hre.ethers.getContractFactory("Ownable");
  const ownable = await ownableContract.deploy();
  await ownable.waitForDeployment();
  const ownableAddr = ownable.target;
  console.log("Ownable contract has been deployed to: " + ownableAddr);

  const bigbankContract = await hre.ethers.getContractFactory("BigBank");
  const bigbank = await bigbankContract.deploy(ownableAddr);
  await bigbank.waitForDeployment();
  const bigbankAddr = bigbank.target;
  console.log("BigBank contract has been deployed to: " + bigbankAddr);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
