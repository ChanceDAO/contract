// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChanceInvite is Ownable {
    using Strings for string;

    mapping(address => string) public inviteCodeMap;
    mapping(string => address) public inviteAddrMap;
    struct INVITE {
        address _inviteAddr;
        uint256 _timestamp;
    }
    mapping(address => INVITE) public inviteRecordMap;
    mapping(address => uint256) public inviteCount;

    address public BLACKHOLE_ADDR = 0x0000000000000000000000000000000000000000;
    uint private randNonce = 10000000;
    uint256 public inviteTTL;

    function setInviteTTL(uint256 _t) public onlyOwner {
        inviteTTL = _t;
    }

    function getInviteTTL() public view returns (uint256) {
        return inviteTTL;
    }

    function getInviteCode(address _addr) public view returns (string memory) {
        return inviteCodeMap[_addr];
    }

    function getInviteAddr(string memory _i) public view returns (address) {
        return inviteAddrMap[_i];
    }

    function setInviteCode(string memory inviteCode) public {
        require(inviteAddrMap[inviteCode] == BLACKHOLE_ADDR, "invite code is used");
        require(bytes(inviteCodeMap[msg.sender]).length == 0, "invite code only set once");
        require(bytes(inviteCode).length < 128, "invite code too long");
        inviteCodeMap[msg.sender] = inviteCode;
        inviteAddrMap[inviteCode] = msg.sender;
    }

    function generateInviteCode(address _addr) private {
        randNonce++;
        string memory _i = Strings.toString(randNonce);
        inviteCodeMap[_addr] = _i;
        inviteAddrMap[_i] = _addr;
    }

    function getInviteCount(address _addr) public view returns (uint256){
        return inviteCount[_addr];
    }

    function inviteParty(address _addr, string memory _inviteCode) public returns (address) {
        // if (bytes(inviteCodeMap[_addr]).length == 0) {
        //     // if new addr
        //     // create addr invite code
        //     generateInviteCode(_addr);
        //     // set msg.sender ttl addr 30 days
        // }

        address inviteAddr = inviteAddrMap[_inviteCode];
        if (inviteAddr == _addr) {
            return BLACKHOLE_ADDR;
        }
        if (inviteAddr != BLACKHOLE_ADDR) {
            bool flag;
            // not in invite record, save
            if (inviteRecordMap[_addr]._timestamp == 0) {
                INVITE memory invite;
                invite._inviteAddr = inviteAddr;
                invite._timestamp = block.timestamp;
                inviteRecordMap[_addr] = invite;
                inviteCount[inviteAddr] += 1;
                flag = true;
            } else {
                if (block.timestamp - inviteRecordMap[_addr]._timestamp < inviteTTL) {
                    flag = true;
                }
            }
            if (flag == true) {
                inviteAddr = inviteRecordMap[_addr]._inviteAddr;
            }
            return inviteAddr;
        } else {
            return BLACKHOLE_ADDR;
        }
    }
}