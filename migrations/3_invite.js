const ChanceInvite = artifacts.require("ChanceInvite");

module.exports = async function (deployer) {
  await deployer.deploy(ChanceInvite);
  const invite = await ChanceInvite.deployed();

  console.log('Deployed ChanceInvite', invite.address);
};
