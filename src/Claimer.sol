// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import "solmate/utils/ReentrancyGuard.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

interface IVrniMinimal {
    function claim(address _to, uint256 _id, bytes32 _seed) external;

    function setGlobalSeed(uint256 _globalSeed) external;

    function globalSeed() external returns (uint256);

}

interface IPhaseManager {

    enum Phase { Unstarted, Minting, Initialization, Gameplay }

    function currentPhase() external view returns (Phase);

    function changePhase() external;

}


// This contract manages the claiming of vrni NFTs
contract Claimer is ReentrancyGuard {

    IVrniMinimal private voronoiNFT;
    IPhaseManager private phaseManager;

    address public _deployer;

    uint256 constant MAX_SUPPLY = 10_000; // maximum number of Voronoi IDs that can be minted
    uint256 constant CLAIM_PRICE = 0.042069 ether; // standard claim price  !!Need to decide if it will be a free mint!!
    mapping(address => uint256) public freeMints; // allow Enso holders to mint for free

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

    // This burns the ability for the deployer to update this contract further, set the global seed or to withdraw ETH from the contract
    function renounceDeployerPermissions() public onlyDeployer {
        withdrawETH();
        if (voronoiNFT.globalSeed() == 0) {
            setGlobalSeed();
        }
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


    function setGlobalSeed() public onlyDeployer {
        require(address(voronoiNFT) != address(0), "UNSET_CONTRACT");
        require(voronoiNFT.globalSeed() == 0, "SEED_SET");

        voronoiNFT.setGlobalSeed(
                                uint256(
                                    keccak256(
                                        abi.encodePacked(
                                                        block.timestamp,
                                                        block.coinbase, 
                                                        block.gaslimit,
                                                        block.difficulty
                                                        )
                                        )
                                    )
                                );

    }

    function withdrawETH() public onlyDeployer {
        payable(_deployer).transfer(address(this).balance);
    }

    // handle the claims for paid Voronoi
    function claimVoronoi() external payable mintingPhase {
        require (nextId < MAX_SUPPLY, "CLAIM_ERROR");
        require (msg.value >= CLAIM_PRICE, "INSUFFICENT_PAYMENT");

        uint256 tokenId = nextId;
        nextId++;

        voronoiNFT.claim(msg.sender, tokenId, _claim(tokenId));
    }

    function claimVoronoi(uint256 amountClaiming) external payable mintingPhase {
        require (amountClaiming > 0 && (nextId+amountClaiming) < MAX_SUPPLY, "CLAIM_ERROR");
        require ((msg.value*amountClaiming) >= CLAIM_PRICE, "INSUFFICENT_PAYMENT");

        uint256 tokenId;

        for(uint256 i = 0; i< amountClaiming; i++) {
            tokenId = nextId;
            nextId++;
            voronoiNFT.claim(msg.sender, tokenId, _claim(tokenId));
        }

    }

    // handle the free claims for Voronoi
    function claimFreeVoronoi() external mintingPhase {
        require (nextId < MAX_SUPPLY, "CLAIM_ERROR");
        require (freeMints[msg.sender] > 0, "INSUFFICIENT_CLAIMS");
        freeMints[msg.sender]--;

        uint256 tokenId = nextId;
        nextId++;

        voronoiNFT.claim(msg.sender, tokenId, _claim(tokenId));
    }

    function claimFreeVoronoi(uint256 amountClaiming) external mintingPhase {
        require (amountClaiming > 0 && (nextId+amountClaiming) < MAX_SUPPLY, "CLAIM_ERROR");
        require (freeMints[msg.sender] >= amountClaiming, "INSUFFICIENT_CLAIMS");
        
        freeMints[msg.sender] -= amountClaiming;

        uint256 tokenId;

        for(uint256 i = 0; i< amountClaiming; i++) {
            tokenId = nextId;
            nextId++;
            voronoiNFT.claim(msg.sender, tokenId, _claim(tokenId));
        }
    }

    function _claim(uint256 _tokenId) internal view returns (bytes32) {
        return keccak256(
                        abi.encodePacked(
                                        Strings.toString(_tokenId),
                                        block.timestamp,
                                        block.coinbase
                                        )
                        );
    }



}