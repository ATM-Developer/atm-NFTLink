// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");



async function main() {
 /* const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  const unlockTime = currentTimestampInSeconds + ONE_YEAR_IN_SECS;

  const lockedAmount = hre.ethers.utils.parseEther("1");

  const Lock = await hre.ethers.getContractFactory("Lock");
  const lock = await Lock.deploy(unlockTime, { value: lockedAmount });

  await lock.deployed();

  console.log(
    `Lock with 1 ETH and unlock timestamp ${unlockTime} deployed to ${lock.address}`
  );*/
  console.log("\n###############  load contract .... ###############");
  const ShadowToken = await hre.ethers.getContractFactory("ShadowToken");
  const Link = await hre.ethers.getContractFactory("LinkV2");
  const Factory = await hre.ethers.getContractFactory("factoryV2");

  console.log("\n###############  deploy  ShadowToken ###############");
  const st = await ShadowToken.deploy();
  console.log(`\n############### deploy success ShadowToken=${st.address}`);

  console.log("\n###############  deploy  Link   ###############");
  const link = await Link.deploy();
  console.log(`\n############### deploy success link=${link.address}`);

  console.log("\n###############  deploy  Factory  ###############");
  const factory = await Factory.deploy();
  console.log(`\n############### deploy success link=${factory.address}`);

  console.log("\n############### shadowToken set owner #############");
  await st.transferOwnership(factory.address);

  console.log("\n############## factory initialize  ###############");
  await factory.initialize(1,1825, link.address, st.address);
}


/*
0xfB0ADc74e93d07adA6a0a6B99b24c827F196964a     st
0xa997d67Cb629Cd26D9bc954593e92c3E97a232cC     link
0xb4909F064d8582756142f92EB945A5C84A5316f7     faCTORY
*/


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
