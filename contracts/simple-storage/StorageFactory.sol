// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SimpleStorage.sol";

contract StorageFactory {
    SimpleStorage[] public simpleStorageArray;

    function createSimpleStorageContract() public {
        SimpleStorage simpleStorage = new SimpleStorage();
        simpleStorageArray.push(simpleStorage);
    }

    function sfStore(uint256 sStorageIndex, uint256 sStorageNumber) public {
        // address
        // ABI - Application Binary Interface
        simpleStorageArray[sStorageIndex].setFavNumber(sStorageNumber);
    }

    function sfGet(uint256 sfStorageIndex) public view returns(uint256){
        return simpleStorageArray[sfStorageIndex].retrieve();
    }
}