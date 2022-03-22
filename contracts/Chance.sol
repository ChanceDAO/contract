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

    event inviteLog(address indexed _addrMint, address _addrInvite, uint256 amount);
    event dropLog(uint256 round, uint256 winner, uint256 jackpot);

    address public COMMUNITY_ADDR = 0x0000000000000000000000000000000000000001;
    address public DEVELOP_ADDR = 0x0000000000000000000000000000000000000002;
    address public BLACKHOLE_ADDR = 0x0000000000000000000000000000000000000000;
    address _ChanceInvite;
    address DROP_ADDR;
    
    mapping(address => uint256) public accountMap;

    struct WINNER {
        uint256 _winnerID;
        uint256 _jackpot;
        bool _withdraw;
        uint256 _timestamp;
    }
    mapping(uint256 => WINNER) public winnerMap;

    uint256 public round;
    uint256 public jackpot;
    uint256 public winnerTTL;
    uint256 public lastEnd;
    string public baseTokenURI;

    constructor() ERC721("ChanceWIN", "WIN") {
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

    function setChanceInvite(address addr) public onlyOwner {
        _ChanceInvite = addr;
    }

    function setWinnerTTL(uint256 _t) public onlyOwner {
        winnerTTL = _t;
    }

    uint256 private _mintPrice;

    function mintPrice() public view returns (uint256) {
        return _mintPrice;
    }

    function setMintPrice(uint256 price) public onlyOwner {
        _mintPrice = price;
    }

    function deposit(uint256 amount) payable public {
        require(msg.value == amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function allotAmount(uint256 amount) private {
       // msg.sender transfer to community addr _mintPrice * 0.15;
       // msg.sender transfer to develop team addr _mintPrice * 0.05;
       // msg.sender deposit _mintPrice * 0.8;
       uint256 community_amount = amount * 15 / 100;
       uint256 develop_amount = amount * 5 / 100;
       accountMap[COMMUNITY_ADDR] += community_amount;
       accountMap[DEVELOP_ADDR] += develop_amount;
       jackpot += amount - community_amount - develop_amount;
    }

    function setDropContract(address addr) public onlyOwner {
        DROP_ADDR = addr;
    }

    function dropChanceWinner() public onlyOwner {
        uint256 winner_id = ChanceDrop(DROP_ADDR).drop_winner_token_id(round, _tokenIds.current(), lastEnd);

        WINNER memory winner;
        winner._jackpot = jackpot;
        winner._winnerID = winner_id;
        winner._timestamp = block.timestamp;
        winnerMap[round] = winner;
        emit dropLog(round, winner_id, jackpot);

        jackpot = 0;
        round += 1;
        lastEnd = _tokenIds.current();
    }

    function mintWIN(string memory _inviteCode) public payable returns (uint256) {
        require(_tokenIds.current() <= round * 100 + 100, "round join max");
        uint amount = _mintPrice;
        deposit(_mintPrice);

        address inviteAddr = ChanceInvite(_ChanceInvite).inviteParty(msg.sender, _inviteCode);
        if (inviteAddr != BLACKHOLE_ADDR) {
            amount = amount * 10 / 100;
            accountMap[inviteAddr] += amount;
        }

        allotAmount(amount);

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(msg.sender, tokenId);

        return tokenId;
    }

    function batchMintWIN(string memory _inviteCode, uint256 _count) public payable {
        require(_tokenIds.current() + _count <= round * 100 + 100, "round join max"); 
        uint amount = _mintPrice * _count;
        deposit(amount);

        address inviteAddr = ChanceInvite(_ChanceInvite).inviteParty(msg.sender, _inviteCode);
        if (inviteAddr != BLACKHOLE_ADDR) {
            amount = amount * 10 / 100;
            accountMap[inviteAddr] += amount;
            emit inviteLog(msg.sender, inviteAddr, amount);
        }

        allotAmount(amount);
        
        for (uint i = 0; i < _count; i++) {
            _tokenIds.increment();
            uint256 tokenId = _tokenIds.current();
            _safeMint(msg.sender, tokenId);
        }
    }

    function checkAmount(address _addr) public view returns (uint256) {
        return accountMap[_addr];
    }

    function checkWinID(uint256 _round) public view returns (uint256[2] memory){
        return [winnerMap[_round]._winnerID, winnerMap[_round]._jackpot];
    }

    function checkWithdraw(uint256 _round) public view returns (bool){
        return winnerMap[_round]._withdraw;
    }

    function withdrawAmount(address payable _to) public nonReentrant {
        if (msg.sender != DEVELOP_ADDR || msg.sender != COMMUNITY_ADDR) {
            uint256 _iCount = ChanceInvite(_ChanceInvite).getInviteCount(msg.sender);
            require(_iCount >= 10, "Invite at least 10");
        }
        uint256 amount = accountMap[msg.sender];
        uint contract_amount = address(this).balance;
        require(amount <= contract_amount, "Not enough balance");
        (bool success, ) = _to.call{value: amount}("");
        accountMap[msg.sender] = 0;
        require(success, "Failed to send Ether");
    }

    function withdrawByWinner(uint256 _round, address payable _to) public nonReentrant {
        require(winnerMap[_round]._winnerID != 0, "not drop this round" );
        require(winnerMap[_round]._withdraw == false, "already withdrew" );
        require(block.timestamp - winnerMap[_round]._timestamp <= winnerTTL, "withdraw time expired" );
        require(ownerOf(winnerMap[_round]._winnerID) == msg.sender, "not win");
        uint256 amount = winnerMap[_round]._jackpot;
        require(amount <= address(this).balance, "not enough balance");
        winnerMap[_round]._withdraw = true;
        (bool success, ) = _to.call{value: amount}("");
        require(success, "Failed to send Ether");
    }
}
