const { assert } = require("chai");

const Chance = artifacts.require("Chance");
const ChanceInvite = artifacts.require("ChanceInvite");

contract("test chance invite", async accounts => {
    let chance;
    let chance_invite;
    const acc0 = accounts[0];
    const acc1 = accounts[1];
    const acc2 = accounts[2];
    const acc3 = accounts[3];
    before(async function() {
      chance = await Chance.deployed();
      chance_invite = await ChanceInvite.deployed();
      await chance.setChanceInvite(chance_invite.address);
    });
    it("should invite work", async () => {
        var inviteCode = "";
        var code = await chance_invite.getInviteCode(acc0);
        assert.equal(code, '');

        inviteCode = "chance";
        await chance_invite.setInviteCode(inviteCode, {from:acc1});
        code = await chance_invite.getInviteCode(acc1);
        assert.equal(code, inviteCode);

        await chance.setMintPrice(web3.utils.toWei("0.01", "ether"));
        await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether'), from:acc2});
        code = await chance_invite.getInviteCode(acc2);
        assert.equal(code, '10000001');

        inviteAmount = await chance.checkAmount(acc1);
        assert.equal(web3.utils.fromWei(inviteAmount.toString(), "ether"), '0.001');

        var invite_ttl = await chance_invite.getInviteTTL();
        assert.equal(invite_ttl.toString(), '0');
        await chance_invite.setInviteTTL(60*60*24*30);
        invite_ttl = await chance_invite.getInviteTTL();
        assert.equal(invite_ttl.toString(), '2592000');
        
        await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether'), from:acc2});
        inviteAmount = await chance.checkAmount(acc1);
        // console.log(inviteAmount)
        assert.equal(web3.utils.fromWei(inviteAmount.toString(), "ether"), '0.002');

    });
});