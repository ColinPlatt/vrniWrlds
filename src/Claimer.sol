// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import "solmate/utils/ReentrancyGuard.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {BytesLib} from "solidity-bytes-utils/BytesLib.sol";

interface IVrniMinimal {
    function claim(address _to, uint256 _id, uint16[2] memory _xy) external;

}

interface IPhaseManager {

    enum Phase { Unstarted, Minting, Initialization, Gameplay }

    function currentPhase() external view returns (Phase);

}


// This contract manages the claiming of vrni NFTs
contract Claimer is ReentrancyGuard {

    IVrniMinimal private voronoiNFT;
    IPhaseManager private phaseManager;

    address public _deployer;

    uint256 constant MAX_SUPPLY = 10_000; // maximum number of Voronoi IDs that can be minted
    uint256 constant CLAIM_PRICE = 0.042069 ether; // standard claim price  !!Need to decide if it will be a free mint!!
    mapping(address => uint256) public freeMints; // allow Enso holders to mint for free

    uint16 constant HEIGHT = 4040; //3840 with 100 border
    uint16 constant WIDTH = 2360; // 2160 with 100 border

    uint256 public nextId;

    constructor(address _voronoiNFT, address _phaseManager){
        _deployer = msg.sender;
        voronoiNFT = IVrniMinimal(_voronoiNFT);
        phaseManager = IPhaseManager(_phaseManager);
    }

    modifier onlyDeployer {
        require(_deployer == msg.sender, "NOT_PERMITTED");
        _;
    }

    modifier mintingPhase {
        require (phaseManager.currentPhase() == IPhaseManager.Phase.Minting, "NOT_MINTING_PHASE");
        _;
    }

    // NFT contract address can be set, and if needed reset later as long as the deployer permissions are not burnt
    function setVoronoiNFT(address _voronoiNFT) public onlyDeployer {
        voronoiNFT = IVrniMinimal(_voronoiNFT);
    }

    // This burns the ability for the deployer to update this contract further or to withdraw ETH from the contract
    function renounceDeployerPermissions() public onlyDeployer {
        withdrawETH();
        _deployer = address(0);
    }

    // manage the free mint list for Enso holders, can only be done before claiming begins
    function setFreeMintList(address[] memory mintList, uint256[] memory mintAmounts) public onlyDeployer {
        require (phaseManager.currentPhase() == IPhaseManager.Phase.Unstarted, "NOT_PERMITTED");
        require(mintList.length == mintAmounts.length, "LISTS_UNEQUAL");
        for(uint256 i=0; i<mintList.length; i++) {
            freeMints[mintList[i]] = mintAmounts[i];
        }
    }

    function withdrawETH() public onlyDeployer {
        payable(_deployer).transfer(address(this).balance);
    }

    // handle the claims for paid Voronoi
    function claimVoronoi() external payable mintingPhase {
        require (nextId < MAX_SUPPLY, "CLAIM_ERROR");
        require (msg.value >= CLAIM_PRICE, "INSUFFICENT_PAYMENT");

        uint256 id = nextId;
        nextId++;

        voronoiNFT.claim(msg.sender, id, _assignCoordinates(id));
    }

    function claimVoronoi(uint256 amountClaiming) external payable mintingPhase {
        require (amountClaiming > 0 && (nextId+amountClaiming) < MAX_SUPPLY, "CLAIM_ERROR");
        require ((msg.value*amountClaiming) >= CLAIM_PRICE, "INSUFFICENT_PAYMENT");

        uint256 id;

        for(uint256 i = 0; i< amountClaiming; i++) {
            id = nextId;
            nextId++;
            voronoiNFT.claim(msg.sender, id, _assignCoordinates(id));
        }

    }
    // handle the free claims for Voronoi
    function claimFreeVoronoi() external mintingPhase {
        require (nextId < MAX_SUPPLY, "CLAIM_ERROR");
        require (freeMints[msg.sender] > 0, "INSUFFICIENT_CLAIMS");
        freeMints[msg.sender]--;

        uint256 id = nextId;
        nextId++;

        voronoiNFT.claim(msg.sender, id, _assignCoordinates(id));
    }

    function claimFreeVoronoi(uint256 amountClaiming) external mintingPhase {
        require (amountClaiming > 0 && (nextId+amountClaiming) < MAX_SUPPLY, "CLAIM_ERROR");
        require (freeMints[msg.sender] >= amountClaiming, "INSUFFICIENT_CLAIMS");
        
        freeMints[msg.sender] -= amountClaiming;

        uint256 id;

        for(uint256 i = 0; i< amountClaiming; i++) {
            id = nextId;
            nextId++;
            voronoiNFT.claim(msg.sender, id, _assignCoordinates(id));
        }
    }

    function _assignCoordinates(uint256 _id) internal view returns (uint16[2] memory _xy) {

        bytes32 SEED = keccak256(
                                abi.encodePacked(
                                                Strings.toString(_id),
                                                block.timestamp,
                                                block.coinbase
                                                )
                                );

        _xy[0] = BytesLib.toUint16(abi.encodePacked((bytes16(SEED) << 112)),0) % (WIDTH-101) + 100;
        _xy[1] = BytesLib.toUint16(abi.encodePacked((bytes16(SEED << 128) << 112)),0) % (HEIGHT-101) + 100;

    }

}