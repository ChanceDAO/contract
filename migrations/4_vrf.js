const VRF = artifacts.require("VRFv2Consumer");


module.exports = async function (deployer) {
    await deployer.deploy(VRF);
    const vrf = await VRF.deployed();
  
    console.log('Deployed VRF', vrf.address);
  };