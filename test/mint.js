const { assert } = require("chai");

const Chance = artifacts.require("Chance");
const ChanceDrop = artifacts.require("ChanceDrop");
const ChanceInvite = artifacts.require("ChanceInvite");

contract("test chance mint", async accounts => {
    let chance;
    let chance_invite;
    let chance_drop;
    const acc0 = accounts[0];
    const acc1 = accounts[1];
    const acc2 = accounts[2];
    const acc3 = accounts[3];
    before(async function() {
      chance = await Chance.deployed();
      chance_invite = await ChanceInvite.deployed();
      chance_drop = await ChanceDrop.deployed();
      await chance.setChanceInvite(chance_invite.address);
      await chance.setDropMinter(chance_drop.address);
    });
    it("should mint nft to account", async () => {
      await chance.setMintPrice(web3.utils.toWei("0.01", "ether"));
      var inviteCode = "";
      let token1 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
      assert.equal(token1.logs[0].args.tokenId.toString(), '1');
      let token2 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
      let token3 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
      let token4 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
      let token5 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
    
      let token6 = await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether'), from:acc1});
      let token7 = await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether'), from:acc1});
      let token8 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether'), from:acc2});
      let token9 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether'), from:acc2});
      let token10 = await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether'), from:acc3});
      
      assert.equal(token10.logs[0].args.tokenId.toString(), '10');
      var balance = await chance.getBalance();
      balance = web3.utils.fromWei(balance.toString(), "ether");
      // mint 10 times 10 *0.01 = 0.1
      assert.equal('0.1', balance);

      // let community_addr = "0x0000000000000000000000000000000000000001";
      // let develop_addr = "0x0000000000000000000000000000000000000002";
      // let community_amount = await chance.checkAmount(community_addr);
      // let develop_amount = await chance.checkAmount(develop_addr);
      // balance = web3.utils.fromWei(community_amount.toString(), "ether");
      // balance = web3.utils.fromWei(develop_amount.toString(), "ether");

      // var jp = await chance.jackpot.call();
      //   jp.toString();

      // await chance.dropChanceWinner();

      // var win_list = await chance.checkWinID(0);
      //win nft id win_list[0].toString()
      //win jackpot win_list[1].toString()
      // balance = web3.utils.fromWei(win_list[1].toString(), "ether");

      // var is_wirhdraw = await chance.checkWithdraw(0);
      // assert.equal(is_wirhdraw, false);
      
      // await chance.withdrawByWinner(0, acc0);
      // get error with reason: 'withdraw time expired'

      // var ttl = 60*60*24*30;
      // await chance.setWinnerTTL(ttl);
      // ttl = await chance.getWinnerTTL();

      // await chance.withdrawByWinner(0, acc0);
      // await chance.withdrawByWinner(0, acc1, {from:acc1});
      // await chance.withdrawByWinner(0, acc2, {from:acc2});
      // await chance.withdrawByWinner(0, acc3, {from:acc3});

      // is_wirhdraw = await chance.checkWithdraw(0);
      // assert.equal(is_wirhdraw, true);

      // var round = await chance.round.call();
      // assert.equal(round.toString(), '1');


      // inviteCode = "chanceAcc2";
      // await chance.setInviteCode(inviteCode, {from:acc2});
      // code = await chance.getInviteCode(acc2);
      // var inviteAmount = await chance.checkAmount(acc2);
      // assert.equal(inviteAmount.toString(), '0');

      // await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
      // inviteAmount = await chance.checkAmount(acc2);
      // balance = web3.utils.fromWei(inviteAmount.toString(), "ether");
      // // assert.notEqual(inviteAmount.toString(), '0');
      // assert.equal(web3.utils.fromWei(inviteAmount.toString(), "ether"), '0.001');

      // await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
      // inviteAmount = await chance.checkAmount(acc2);
      // // still 0.01 because TTL has not set 
      // assert.equal(web3.utils.fromWei(inviteAmount.toString(), "ether"), '0.001');

      // await chance.setWinnerTTL(60*60*24*30);
      // await chance.mintWIN(inviteCode, {value: web3.utils.toWei("0.01", 'ether')});
      // inviteAmount = await chance.checkAmount(acc2);
      // assert.equal(web3.utils.fromWei(inviteAmount.toString(), "ether"), '0.002');

      // var invite_ttl = await chance_invite.getInviteTTL();
      // assert.equal(invite_ttl.toString(), '0');
      // await chance_invite.setInviteTTL(60*60*24*30);
      // assert.equal(invite_ttl.toString(), '2592000');

    });
  });