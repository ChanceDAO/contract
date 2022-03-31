// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./base/VRFv2Consumer.sol";

contract ChanceDrop is Ownable {

    address VRF_ADDR;
    address public DROP_MINTER;

    function setVRF(address _addr) public onlyOwner {
        VRF_ADDR = _addr;
    }

    function get_rand(uint256 start, uint256 end, uint256 _seed) private pure returns(uint256) {
        return start + _seed%(end - start + 1);
    }

    function setDropOwner(address _addr) public onlyOwner {
        DROP_MINTER = _addr;
    }

    function drop_winner_token_id(uint256 round, uint256 end, uint256 lastEnd) public view returns (uint256){
        require(msg.sender == DROP_MINTER, "Permission Denied");
        uint256 start = round * 100 + 1;
        if (lastEnd <= start) {
            start = lastEnd;
        }
        if (end == start) {
            return 0;
        }
        require(end > start, "Wrong Drop Condition");

        // test seed
        // uint256 _seed = uint256(keccak256(abi.encode(block.difficulty, block.timestamp)));
        uint256 _seed = VRFv2Consumer(VRF_ADDR).getSeed(round%24);
        require(_seed !=0 , "Seed Not Ready");

        uint256 winner_in_round = get_rand(1, 10, _seed);
        uint256 winner_id;
        if (winner_in_round > 1){
            // drop winner in this round
            winner_id = get_rand(start, end, _seed);
        } else {
            // drop winner in history round
            if (start <= 1){
                winner_id = 1;
            } else {
                winner_id = get_rand(1, start - 1, _seed);
            }
        }
        return winner_id;
    }

}

