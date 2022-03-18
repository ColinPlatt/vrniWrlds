// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;


import {PhaseManager} from "../PhaseManager.sol";
import {CheatCodes} from"./CheatCodes.sol"; //0x7109709ECfa91a80626fF3989D68f67F5b1DD12D

import "ds-test/test.sol";

contract PhaseTest is DSTest {   
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address deployer;
    PhaseManager manager;

    enum Phase { Unstarted, Minting, Initialization, Gameplay }

    constructor() {
        deployer = address(this);
    }

    function setUp() public logs_gas {
        manager = new PhaseManager();
    }

    function testStates() public {

        cheats.prank(deployer);

        assertEq(uint(Phase.Unstarted), uint(manager.currentPhase()));

        manager.changePhase();
        assertEq(uint(Phase.Minting), uint(manager.currentPhase()));

        manager.changePhase();
        assertEq(uint(Phase.Initialization), uint(manager.currentPhase()));

        manager.changePhase();
        assertEq(uint(Phase.Gameplay), uint(manager.currentPhase()));

    }

    function testFailNonauthorizedStateChange() public {

        cheats.prank(address(0xBEEF));

        manager.changePhase();

    }


}