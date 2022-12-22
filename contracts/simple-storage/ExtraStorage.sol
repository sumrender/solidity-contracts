// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SimpleStorage.sol";

contract ExtraStorage is SimpleStorage {
    // + 5
    // to override a function
    // virtual keyword should be on method of base class
    // and override keyword should be on new method of derived class
    function setFavNumber(uint256 num) public override {
        favNumber = num + 5;
    }

}
