// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

import "./PhaseManager.sol";
import "./Distributor.sol";
import "./DLNY.sol";

// This contract acts as a global manager for state and launches each individual contract

contract DeploymentManager {

    PhaseManager public phaseManager;
    Distributor public distributor;
    DLNY public dlny;

    constructor(){
        phaseManager = new PhaseManager();
        distributor = new Distributor();
        dlny = new DLNY(address(distributor));
    }

    function togglePhase() external {
        phaseManager.changePhase();
    }

    function viewPhase() external view returns (uint){
        return uint(phaseManager.currentPhase());
    }



}

/*
Deployment Manager 
    1.  Phase Manager
        a. Phase Manager: changePhase -> Unstarted
    2.  vrni (NFT contract)
        a.
    3.  Claimer
        a. Phase Manager: changePhase -> Minting
        b. vrni: [minting ongoing]
            i. vrni - centreX, centreY, id owners set
    4.  Distributor
        a. 
    5.  DLNY
        a. authorise Distributor
    6.  Map Generator
        a. Map Generator: set seeding
        b. Distributor: add Map Generator trigger
    7.  Revealer
        a. Phase Manager: changePhase -> Initialization
        b. Distributor: add Revealer triggers
        c. Revealer: setMerkleRoot
        d. vrni: claimReveal
            i.    centreX (overwrites)  uint16
            ii.   centreY (overwrites)  uint16
            iii.  coordinatesXY         address SSTORE2
            iiii. altitude              uint16
            iv.   population            uint16
            v.    RGB                   bytes3
            vi.   viewBox               uint16[4]
            vii.  climate               uint8
            viii. resources             uint8
            ix.   language              uint8
            x.    development           uint8
        e. vrni: [claimReveal ongoing]
        f. Phase Manager: changePhase -> Gameplay
    8.  DataManager
        a. Upgrading (need a mechanism to handle pricing of upgrades)
        b.   
    9.  Reinvestor
        a. DLNY: authorise Reinvestor
    10. UriInterpreter
    11. Alliances
    */