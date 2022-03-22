const ChanceDrop = artifacts.require("ChanceDrop");

module.exports = async function (deployer) {
  await deployer.deploy(ChanceDrop);
  const chance_drop = await ChanceDrop.deployed();

  console.log('Deployed ChanceDrop', chance_drop.address);
};
