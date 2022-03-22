const { assert } = require("chai");

const Chance = artifacts.require("Chance");
const ChanceInvite = artifacts.require("ChanceInvite");

contract("test chance drop win nft", async accounts => {
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
    it("should drop win", async () => {
      await chance.setMintPrice(web3.utils.toWei("0.01", "ether"));
      var inviteCode = "";
      let token1 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
      var code = await chance_invite.getInviteCode(acc0);
      // default = '10000001'
      assert.equal(code, '10000001');

      let token2 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
      let token3 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
      let token4 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
      let token5 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
      let token6 = await chance.mintWIN(code, {value: web3.utils.toWei("0.01", 'ether'), from:acc1});
      let token7 = await chance.mintWIN(code, {value: web3.utils.toWei("0.01", 'ether'), from:acc1});
      let token8 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether'), from:acc2});
      let token9 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether'), from:acc2});
      let token10 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether'), from:acc3});
      
      var balance = await chance.getBalance();
      balance = web3.utils.fromWei(balance.toString(), "ether");
      // mint 10 times 10 *0.01 = 0.1
      assert.equal('0.1', balance);

      var jp = await chance.jackpot.call();
      assert.notEqual(jp.toString(), '0');

      await chance.dropChanceWinner();

      var win_list = await chance.checkWinID(0);
      //win nft id win_list[0].toString()
      //win jackpot win_list[1].toString()
      let win_nft = win_list[0].toString();
      jackpot = web3.utils.fromWei(win_list[1].toString(), "ether");
      let win_addr = await chance.ownerOf(win_nft);

      var is_wirhdraw = await chance.checkWithdraw(0);
      assert.equal(is_wirhdraw, false);
      
      var ttl = 60*60*24*30;
      await chance.setWinnerTTL(ttl);
      ttl = await chance.getWinnerTTL();
      
      await chance.withdrawByWinner(0, win_addr.toString());

      is_wirhdraw = await chance.checkWithdraw(0);
      assert.equal(is_wirhdraw, true);

      var round = await chance.round.call();
      assert.equal(round.toString(), '1');

    });
  });