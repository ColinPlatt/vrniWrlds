// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "solmate/tokens/ERC20.sol";

contract DLNY is ERC20 {

    address public distributor;

    constructor(
        address _distributor
        ) ERC20("DLNY Token", unicode"🌍", 18) {
            distributor = _distributor;
        }

    modifier onlyDistributor() {
        require(msg.sender == distributor, "NOT_PERMITTED");
        _;
    }

    function mint(address to, uint256 amount) public onlyDistributor {
        _mint(to, amount);
    }

}