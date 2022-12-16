//SPDX-License-Identifier:MIT
pragma solidity >=0.4.0 <0.9.0;
contract AssetTracker {
    bytes32 abc;
    function getName(bytes32 _abc) public returns(bytes32) {
        abc=_abc;
        return abc;
    }
}