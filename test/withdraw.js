const { assert } = require("chai");

const Chance = artifacts.require("Chance");
const ChanceInvite = artifacts.require("ChanceInvite");

contract("test chance withdraw", async accounts => {
    let chance;
    let chance_invite;
    const acc0 = accounts[0];
    const acc1 = accounts[1];
    const acc2 = accounts[2];
    const acc3 = accounts[3];
    const acc4 = accounts[4];
    const acc5 = accounts[5];
    before(async function() {
      chance = await Chance.deployed();
      chance_invite = await ChanceInvite.deployed();
      await chance.setChanceInvite(chance_invite.address);
    });
    it("should withdraw by win nft hold account", async () => {
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
        
        await chance.withdrawByWinner(0, win_addr.toString(), {from:win_addr});
  
        is_wirhdraw = await chance.checkWithdraw(0);
        assert.equal(is_wirhdraw, true);
  
        var round = await chance.round.call();
        assert.equal(round.toString(), '1');

        await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether')});
        await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether')});
        await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether'), from:acc1});
        await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether'), from:acc1});
        await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether'), from:acc2});
        await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether'), from:acc2});
        await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether'), from:acc3});
        await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether'), from:acc3});

        await chance.dropChanceWinner(); 
        win_list = await chance.checkWinID(round); 
        let win_nft1 = win_list[0].toString();
        let win_addr1 = await chance.ownerOf(win_nft1);

        var is_wirhdraw1 = await chance.checkWithdraw(round);
        assert.equal(is_wirhdraw1, false); 

        await chance.withdrawByWinner(round, win_addr1.toString(), {from:win_addr1});
        is_wirhdraw1 = await chance.checkWithdraw(round);
        assert.equal(is_wirhdraw1, true);
    });
    it("should withdraw by community address", async () => {
      let community_addr = acc4;
      let develop_addr = acc5;

      await chance.setCommunityAddr(community_addr);
      await chance.setDevelopAddr(develop_addr);

      let _community_addr = await chance.getCommunityAddr();
      let _develop_addr = await chance.getDevelopAddr();
      assert.equal(_community_addr, community_addr);
      assert.equal(_develop_addr, develop_addr);

      var community_amount = await chance.checkAmount(community_addr);
      var develop_amount = await chance.checkAmount(develop_addr);
      assert.equal(web3.utils.fromWei(community_amount.toString(), "ether"), '0');
      assert.equal(web3.utils.fromWei(develop_amount.toString(), "ether"), '0');

      await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether')});
      await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether')}); 
      await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether')});
      await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether')}); 
      await chance.mintWIN("", {value: web3.utils.toWei("0.01", 'ether')}); 

      community_amount = await chance.checkAmount(community_addr);
      develop_amount = await chance.checkAmount(develop_addr);
      assert.notEqual(web3.utils.fromWei(community_amount.toString(), "ether"), '0');
      assert.notEqual(web3.utils.fromWei(develop_amount.toString(), "ether"), '0');

      await chance.withdrawByCommunity(community_addr, {from: acc4});
      await chance.withdrawByCommunity(develop_addr, {from: acc5});

      community_amount = await chance.checkAmount(community_addr);
      develop_amount = await chance.checkAmount(develop_addr);
      assert.equal(web3.utils.fromWei(community_amount.toString(), "ether"), '0');
      assert.equal(web3.utils.fromWei(develop_amount.toString(), "ether"), '0');
    });
  });