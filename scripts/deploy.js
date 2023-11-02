// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");



async function main() {
  console.log("\n###############  load contract .... ###############");
  const ShadowToken = await hre.ethers.getContractFactory("ShadowToken");
  const Link = await hre.ethers.getContractFactory("LinkV2");
  const Factory = await hre.ethers.getContractFactory("FactoryV2");
  const FactoryProxy = await hre.ethers.getContractFactory("FactoryProxyV2");

  console.log("\n===============  deploy  ShadowToken ============");
  const st = await ShadowToken.deploy();

  console.log("\n===============  deploy  Link ==============");
  const link = await Link.deploy();

  console.log("\n=============== deploy  Factory  ===============");
  const factory = await Factory.deploy();

  console.log("\n=============== deploy  FactoryProxy  ===============");
  const factoryProxy = await FactoryProxy.deploy(factory.address);

  console.log(`
  ----------------------------------------------------
  deployed contracts address
  shadow: ${st.address}
  link: ${link.address}
  factory: ${factory.address}
  factoryProxy: ${factoryProxy.address}
  ----------------------------------------------------
  `
  )


  console.log("\n############### contract setting ####################");
  console.log("\n=============== shadowToken set owner ===============");
  await st.transferOwnership(factoryProxy.address);

  console.log("\n=============== factory initialize  ===============");
  await Factory.attach(factoryProxy.address).initialize(1, 1825, link.address, st.address);


/*
  console.log("\n############## verify contracts  ###############");
  console.log("\n========== verify shadowToken  ===================");
  await hre.run("verify:verify", {address: st.address ,constructorArguments: []});

  console.log("\n========== verify link  ===================");
  await hre.run("verify:verify", {address: link.address ,constructorArguments: []});

  console.log("\n========== verify factory  ===================");
  await hre.run("verify:verify", {address: factory.address ,constructorArguments: []});
  */
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
