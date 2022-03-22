const Chance = artifacts.require("Chance");

module.exports = async function (deployer) {
  await deployer.deploy(Chance);
  const chance = await Chance.deployed();

  console.log('Deployed Chance', chance.address);
};
