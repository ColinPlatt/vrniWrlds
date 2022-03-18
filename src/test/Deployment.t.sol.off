// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;


import {DeploymentManager} from "../DeploymentManager.sol";
import {CheatCodes} from"./CheatCodes.sol"; //0x7109709ECfa91a80626fF3989D68f67F5b1DD12D

import "ds-test/test.sol";

contract DeploymentTest is DSTest {   
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address _deployer;
    DeploymentManager manager;

    constructor() {
        _deployer = address(this);
    }

    function setUp() public logs_gas {
        manager = new DeploymentManager();
    }

    function testPhase() public {
        manager.togglePhase();
        emit log_uint(uint(manager.viewPhase()));
    }
}