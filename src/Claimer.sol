// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import "solmate/utils/ReentrancyGuard.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

interface IVrniMinimal {
    function claim(address _to, uint256 _id, bytes32 _seed) external;

    function setGlobalSeed(uint256 _globalSeed) external;

    function globalSeed() external returns (uint256);

}

// This contract manages the claiming of vrni NFTs
contract Claimer is ReentrancyGuard {

    IVrniMinimal private voronoiNFT;

    address public _deployer;

    bool public CLAIM_ACTIVE = false;

    uint256 constant MAX_SUPPLY = 10000; // maximum number of Voronoi IDs that can be minted
    uint256 constant CLAIM_PRICE = 0.042069 ether; // standard claim price
    mapping(address => uint256) public freeMints; // allow Enso holders to mint for free

    uint256 public nextId;

    constructor(address _voronoiNFT){
        _deployer = msg.sender;
        voronoiNFT = IVrniMinimal(_voronoiNFT);
    }

    modifier onlyDeployer {
        require(_deployer == msg.sender, "NOT_PERMITTED");
        _;
    }

    // NFT contract address can be set, and if needed reset later as long as the deployer permissions are not burnt
    function setVoronoiNFT(address _voronoiNFT) public onlyDeployer {
        voronoiNFT = IVrniMinimal(_voronoiNFT);
    }

    // This burns the ability for the deployer to update this contract further, stops claiming, set the global seed or to withdraw ETH from the contract
    function renounceDeployerPermissions() public onlyDeployer {
        withdrawETH();
        activateClaiming();
        if (voronoiNFT.globalSeed() == 0) {
            setGlobalSeed();
        }
        CLAIM_ACTIVE = false;
        _deployer = address(0);
    }

    // manage the free mint list for Enso holders, can only be done before claiming begins
    function setFreeMintList(address[] memory mintList, uint256[] memory mintAmounts) public onlyDeployer {
        require (!CLAIM_ACTIVE, "CLAIMING_STARTED");
        require(mintList.length == mintAmounts.length, "LISTS_UNEQUAL");
        for(uint256 i=0; i<mintList.length; i++) {
            freeMints[mintList[i]] = mintAmounts[i];
        }
    }

    function activateClaiming() public onlyDeployer {
        CLAIM_ACTIVE = true;
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
    function claimVoronoi() external payable {
        require (CLAIM_ACTIVE && nextId < MAX_SUPPLY, "CLAIM_ERROR");
        require (msg.value >= CLAIM_PRICE, "INSUFFICENT_PAYMENT");

        uint256 tokenId = nextId;
        nextId++;

        voronoiNFT.claim(msg.sender, tokenId, _claim(tokenId));
    }

    function claimVoronoi(uint256 amountClaiming) external payable {
        require (CLAIM_ACTIVE && amountClaiming > 0 && (nextId+amountClaiming) < MAX_SUPPLY, "CLAIM_ERROR");
        require ((msg.value*amountClaiming) >= CLAIM_PRICE, "INSUFFICENT_PAYMENT");

        uint256 tokenId;

        for(uint256 i = 0; i< amountClaiming; i++) {
            tokenId = nextId;
            nextId++;
            voronoiNFT.claim(msg.sender, tokenId, _claim(tokenId));
        }

    }

    // handle the free claims for Voronoi
    function claimFreeVoronoi() external {
        require (CLAIM_ACTIVE && nextId < MAX_SUPPLY, "CLAIM_ERROR");
        require (freeMints[msg.sender] > 0, "INSUFFICIENT_CLAIMS");
        freeMints[msg.sender]--;

        uint256 tokenId = nextId;
        nextId++;

        voronoiNFT.claim(msg.sender, tokenId, _claim(tokenId));
    }

    function claimFreeVoronoi(uint256 amountClaiming) external {
        require (CLAIM_ACTIVE && amountClaiming > 0 && (nextId+amountClaiming) < MAX_SUPPLY, "CLAIM_ERROR");
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