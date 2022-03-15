// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

interface IPhaseManager {

    enum Phase { Unstarted, Minting, Initialization, Gameplay }

    function currentPhase() external view returns (Phase);

}

// The PhaseManager contract allows all vrniWrlds contracts that rely on a global state of the project to call for the latest state.

contract PhaseManager is IPhaseManager {
    
    address public deployer;
    Phase public activePhase;

    constructor(){
        deployer = msg.sender;
    }

    modifier onlyDeployer() {
        require(deployer == msg.sender, "PhaseManager: NOT_AUTHORISED");
        _;
    }

    function currentPhase() public view returns (Phase) {
        return activePhase;
    }

    function changePhase() public onlyDeployer {
        activePhase = Phase(uint(activePhase) + 1);
    }

}