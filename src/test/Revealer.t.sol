// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import "ds-test/test.sol";

import {vrni} from "../vrni.sol";
import {Claimer} from "../Claimer.sol";
import {PhaseManager} from "../PhaseManager.sol";
import {CheatCodes} from"./CheatCodes.sol"; //0x7109709ECfa91a80626fF3989D68f67F5b1DD12D


contract RevealerTest is DSTest {
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    
    vrni token;
    Claimer claimer;
    PhaseManager manager;
    address deployer;

    constructor() {
        deployer = address(this);

    }

    receive() external payable {}

    event Response(bool success, bytes data);

    function setUp() public {
        token = new vrni();
        manager = new PhaseManager();
        claimer = new Claimer(address(token), address(manager));
    }

    function testRevealing() public logs_gas {
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

        token.setDataManager(deployer);

        uint gasBefore = gasleft();

        token.revealData(0, revealData());

        emit log_uint(gasBefore - gasleft());

        (uint16 x2, uint16 y2) = token.getCentre(0);
        emit log_uint(x2);
        emit log_uint(y2);

        vrni.CellData memory testCD = token.getRawCellData(0);


        emit log_bytes(abi.encode(testCD));
        emit log_bytes32(keccak256(abi.encode(testCD)));

    }

    function revealData() internal pure returns (vrni.CellData memory testData) {

        vrni.CellViewData memory testViewData;
        vrni.CellMetaData memory testMetaData;

        testViewData = vrni.CellViewData({
            colourRGB: bytes3(0xFFAADD), 
            viewBoxX: uint16(100),
            viewBoxY: uint16(200),
            viewBoxWidth:uint16(101),
            viewBoxHeight: uint16(202)
        });

        testMetaData = vrni.CellMetaData({
            population: uint16(300),
            altitude: uint16(301),
            climate: uint8(1),
            resources: uint8(2),
            language: uint8(3),
            development: uint8(4),
            industry: uint8(5),
            taxRate: uint8(6),
            government: uint8(7)
        });

        
        testData = vrni.CellData({
            cellXYCoordinates: address(0xdead),
            centreX: uint16(401),
            centreY: uint16(402),
            cellViewdata: testViewData,
            cellPathdata: address(0xbeef),
            cellMetadata: testMetaData
        });

    }

}

