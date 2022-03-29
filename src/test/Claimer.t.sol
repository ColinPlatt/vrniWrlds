// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import "ds-test/test.sol";

import {vrni} from "../vrni.sol";
import {Claimer} from "../Claimer.sol";
import {PhaseManager} from "../PhaseManager.sol";
import {CheatCodes} from"./CheatCodes.sol"; //0x7109709ECfa91a80626fF3989D68f67F5b1DD12D


contract ClaimerSetup is DSTest {
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    address[] public airDropAddr;
    uint256[] public airDropAmt;

    
    vrni token;
    Claimer claimer;
    PhaseManager manager;
    address deployer;

    constructor() {
        deployer = address(this);
        airDropAddr.push(address(0xBEEF));
        airDropAddr.push(address(0x1337));
        airDropAmt.push(1);
        airDropAmt.push(2);

    }

    receive() external payable {}

    event Response(bool success, bytes data);

    function setUp() public {
        token = new vrni();
        manager = new PhaseManager();
        claimer = new Claimer(address(token), address(manager));
    }

    function testInvariantMetadata() public {
        assertEq(token.name(), "vrni NFT");
        assertEq(token.symbol(), "vrni");
        assertEq(claimer._deployer(), deployer);
    }

    function testSettingAirdrop() public logs_gas {
        token.setClaimer(address(claimer));
        claimer.setFreeMintList(airDropAddr, airDropAmt);
        manager.changePhase();

        cheats.prank(address(0xBEEF));
        claimer.claimFreeVoronoi();
        
        cheats.prank(address(0x1337));
        claimer.claimFreeVoronoi(2);

    }

    function testClaiming() public logs_gas {
        token.setClaimer(address(claimer));
        manager.changePhase();
        
        (bool success, bytes memory data) = address(claimer).call{value: 0.042069 ether}(
            abi.encodeWithSignature("claimVoronoi()")
        );
        emit Response(success, data);
        assertEq(token.balanceOf(deployer), 1);

        (uint16 x, uint16 y) = token.getCentre(0);
        emit log_uint(x);
        emit log_uint(y);

        (bool success1, bytes memory data1) = address(claimer).call{value: 0.42069 ether}(
            abi.encodeWithSignature("claimVoronoi(uint256)",10)
        );
        emit Response(success1, data1);
        assertEq(token.balanceOf(deployer), 11);

        cheats.prank(deployer);
        claimer.withdrawETH();
        claimer.renounceDeployerPermissions();

    }

}