// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IDataManager {
    function returnURI(uint256 _tokenID) external view returns(string memory);
}