// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;


import {DLNY} from "../DLNY.sol";
import {Distributor, GasLogger} from "../Distributor.sol";
import {CheatCodes} from"./CheatCodes.sol"; //0x7109709ECfa91a80626fF3989D68f67F5b1DD12D

import "ds-test/test.sol";

contract worker is DSTest, GasLogger {
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address deployer;
    DLNY token;
    Distributor distrib;

    constructor() {
        deployer = address(this);
    }

    function setUp() public {
        distrib = new Distributor();
        token = new DLNY(address(distrib));
        distrib.setToken(address(token));
        distrib.addLogger(address(this));
        setDistributor(address(distrib));
    }

    function testSetup() public {
        assertEq(token.name(), "DLNY Token");
        assertEq(token.symbol(), unicode"🌍");
        assertEq(token.decimals(), uint8(18));
        assertEq(token.distributor(), address(distrib));
        assertEq(distrib.dlny(), address(token));
    }

    uint256[] public junkData;    

    function usefulFunction(uint256 iterations) public trackGas {
        for (uint256 i =0; i<iterations; i++) {
            junkData.push(uint256(keccak256(abi.encodePacked(i, block.timestamp))));
        }
    }

    function testGasTracking() public {       

        usefulFunction(10);

        emit log_uint(distrib.pendingTokens(msg.sender)); //should be more than zero

        cheats.prank(msg.sender);
        distrib.claimTokens();

        emit log_uint(token.balanceOf(msg.sender));

        cheats.stopPrank();

    }


}