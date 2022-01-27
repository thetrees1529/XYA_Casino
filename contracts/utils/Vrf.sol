//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Vrf {
    function _vrf(uint blockNumber) internal view returns (bytes32 result) {
        uint[1] memory bn;
        bn[0] = blockNumber;
        assembly {
            let memPtr := mload(0x40)
            if iszero(staticcall(not(0), 0xff, bn, 0x20, memPtr, 0x20)) {
                invalid()
            }
            result := mload(memPtr)
        }
    } 
}