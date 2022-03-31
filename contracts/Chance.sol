// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ChanceInvite.sol";
import "./ChanceDrop.sol";

contract Chance is ERC721URIStorage, ERC721Enumerable, Ownable, ReentrancyGuard{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event mintLog(address _addrMint, uint256 _id, uint256 round, uint256 lastEnd);
    event inviteLog(address indexed _addrMint, address _addrInvite, uint256 amount);
    event dropLog(uint256 round, uint256 winner, uint256 jackpot);
    event withdrawLog(address indexed _Chance, address _addrWithdraw, uint256 amount);
    event winnerWithdrawLog(address indexed _Chance, address _addrWithdraw, uint256 amount);

    address public COMMUNITY_ADDR = 0x0000000000000000000000000000000000000001;
    address public DEVELOP_ADDR = 0x0000000000000000000000000000000000000002;
    address public BLACKHOLE_ADDR = 0x0000000000000000000000000000000000000000;
    address public _ChanceInvite;
    address public DROP_ADDR;
    
    mapping(address => uint256) public accountMap;

    struct WINNER {
        uint256 _winnerID;
        uint256 _jackpot;
        bool _withdraw;
        uint256 _timestamp;
    }
    mapping(uint256 => WINNER) public winnerMap;

    uint256 public round;
    uint256 public roundAmount;
    uint256 public jackpot;
    uint256 public winnerTTL;
    uint256 public lastEnd;
    string public baseTokenURI;

    constructor(address drop_addr, address invite_addr) ERC721("ChanceWIN", "WIN") {
        DROP_ADDR = drop_addr;
        _ChanceInvite = invite_addr;
    }

    function batchTransfer(address[] calldata addressList, uint256[] calldata tokenIds) public {
        for (uint i = 0; i < addressList.length; i++) {
            _transfer(msg.sender, addressList[i], tokenIds[i]);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal onlyOwner override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory uri) public virtual onlyOwner {
        baseTokenURI = uri;
    }

    function setCommunityAddr(address _addr) public onlyOwner {
        COMMUNITY_ADDR = _addr;
    }

    function setDevelopAddr(address _addr) public onlyOwner {
        DEVELOP_ADDR = _addr;
    }

    function setWinnerTTL(uint256 _t) public onlyOwner {
        winnerTTL = _t;
    }

    uint256 public _mintPrice;

    function setMintPrice(uint256 price) public onlyOwner {
        _mintPrice = price;
    }

    function deposit(uint256 amount) payable public {
        require(msg.value == amount);
    }

    function allotAmount(uint256 amount) private {
       uint256 community_amount = amount * 15 / 100;
       uint256 develop_amount = amount * 5 / 100;
       accountMap[COMMUNITY_ADDR] += community_amount;
       accountMap[DEVELOP_ADDR] += develop_amount;
       jackpot += amount - community_amount - develop_amount;
    }

    function dropChanceWinner(uint256 _timestamp) public onlyOwner {
        uint256 winner_id = ChanceDrop(DROP_ADDR).drop_winner_token_id(round, _tokenIds.current(), lastEnd);

        WINNER memory winner;
        winner._jackpot = jackpot;
        winner._winnerID = winner_id;
        winner._timestamp = _timestamp;
        winnerMap[round] = winner;
        emit dropLog(round, winner_id, jackpot);

        jackpot = 0;
        roundAmount = 0;
        round += 1;
        lastEnd = _tokenIds.current();
    }

    function mintWIN(string memory _inviteCode) public payable returns (uint256) {
        require(_tokenIds.current() <= round * 100 + 100, "round join max");
        uint amount = _mintPrice;
        deposit(_mintPrice);
        roundAmount += amount;

        address inviteAddr = ChanceInvite(_ChanceInvite).inviteParty(msg.sender, _inviteCode);
        if (inviteAddr != BLACKHOLE_ADDR) {
            amount = amount * 10 / 100;
            accountMap[inviteAddr] += amount;
            emit inviteLog(msg.sender, inviteAddr, amount);
        }

        allotAmount(amount);

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(msg.sender, tokenId);
        emit mintLog(msg.sender, tokenId, round, lastEnd);
        return tokenId;
    }

    function batchMintWIN(string memory _inviteCode, uint256 _count) public payable {
        require(_tokenIds.current() + _count <= round * 100 + 100, "roundJoinMax"); 
        uint amount = _mintPrice * _count;
        roundAmount += amount;
        deposit(amount);

        uint invite_amount = 0;
        address inviteAddr = ChanceInvite(_ChanceInvite).inviteParty(msg.sender, _inviteCode);
        if (inviteAddr != BLACKHOLE_ADDR) {
            invite_amount = amount * 10 / 100;
            accountMap[inviteAddr] += invite_amount;
            emit inviteLog(msg.sender, inviteAddr, invite_amount);
        }

        allotAmount(amount - invite_amount);
        
        for (uint i = 0; i < _count; i++) {
            _tokenIds.increment();
            uint256 tokenId = _tokenIds.current();
            _safeMint(msg.sender, tokenId);
            emit mintLog(msg.sender, tokenId, round, lastEnd);
        }
    }

    function withdrawAmount(address payable _to, uint256 _amount) public nonReentrant {
        if (msg.sender != DEVELOP_ADDR || msg.sender != COMMUNITY_ADDR) {
            uint256 _iCount = ChanceInvite(_ChanceInvite).getInviteCount(msg.sender);
            require(_iCount >= 10, "InviteAtLeast10");
        }
        uint256 amount = accountMap[msg.sender];
        require(amount <= address(this).balance, "NotEnoughBalance");
        require(_amount <= amount, "NotAllowedBalance");
        if (_amount == 0){
            _amount = amount;
        }
        (bool success, ) = _to.call{value: _amount}("");
        accountMap[msg.sender] -= _amount;
        require(success, "FailedToSendEther");
        emit withdrawLog(address(this), msg.sender, _amount);
    }

    function withdrawByWinner(uint256 _round, address payable _to) public nonReentrant {
        require(winnerMap[_round]._winnerID != 0, "NotDropThisRound" );
        require(winnerMap[_round]._withdraw == false, "AlreadyWithdrew" );
        require(block.timestamp - winnerMap[_round]._timestamp <= winnerTTL, "WithdrawTimeExpired" );
        require(ownerOf(winnerMap[_round]._winnerID) == msg.sender, "not win");
        uint256 amount = winnerMap[_round]._jackpot;
        require(amount <= address(this).balance, "NotEnoughBalance");
        winnerMap[_round]._withdraw = true;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "FailedToSendEther");
        emit winnerWithdrawLog(address(this), msg.sender, amount);
    }
}
