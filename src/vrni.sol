// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "solmate/tokens/ERC721.sol";
import "solmate/utils/ReentrancyGuard.sol";

import "../lib/Base64.sol";
import "./Interfaces/IRenderSVG.sol";

contract vrni is ERC721, ReentrancyGuard {
    IRenderSVG private uriIntepreter;
    address public claimContract;
    address public dataManager; //initially is the Revealer then switches to a GamePlay dataManager
    address public deployer;


    // we split the CellViewData from the CellMetaData information to optimise the storage in the CellData struct. ViewData contains data directly viewable in the SVG.
    struct CellViewData {
        bytes3 colourRGB; 
        uint16 viewBoxX;
        uint16 viewBoxY;
        uint16 viewBoxWidth;
        uint16 viewBoxHeight;
        //20 bytes for address coordinates & 11 bytes here
    }
    
    
    // holds data which is not directly viewable in the SVG, but is used to derive other aspects which may be viewable
    struct CellMetaData {
        uint16 population;
        uint16 altitude;
        uint8 climate;
        uint8 resources;
        uint8 language;
        uint8 development;
        uint8 industry;
        uint8 taxRate;
        uint8 government;
        //20 bytes for address coordinates & 11 bytes here
    }

    // After initialization, all data for each NFT ID (Cell) is held in a struct and read by the IRenderSVG, which is called by the tokenUri function
    struct CellData {
        address cellXYCoordinates; // polygon Saved as XY coordinates in Hex over 2x 2bytes in an SSTORE2 address
        uint16 centreX; // pseudo random seed generated upon claiming token, used to build the Voronoi Diagram
        uint16 centreY;
        CellViewData cellViewdata; // contains tightly packed data about the viewbox and cell colour must be interpretted by an interpreter contract 
        address cellPathdata; // SSTORE2 address for extended Path data
        CellMetaData cellMetadata; // contains tightly packed metadata which must be interpretted by an interpreter contract 
    }

    mapping (uint256 => CellData) public cellDataSet;

    constructor() ERC721("vrni NFT", "vrni") {
        deployer = msg.sender;
    }

    function _exists(uint256 id) internal view returns (bool) {
        return ownerOf[id] != address(0);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return uriIntepreter.returnURI(id);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // View functions for retrieving cell information
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function getCentre(uint256 id) external view returns (uint16 x, uint16 y) {
        require(_exists(id), "NONEXISTANT_ID");
        return (cellDataSet[id].centreX, cellDataSet[id].centreY);
    }

    function getXYCoordinatesAddress(uint256 id) external view returns (address) {
        require(_exists(id), "NONEXISTANT_ID");
        return cellDataSet[id].cellXYCoordinates;
    }

    function getRawViewdata(uint256 id) external view returns (CellViewData memory) {
        require(_exists(id), "NONEXISTANT_ID");
        return cellDataSet[id].cellViewdata;
    }

    function getRawMetadata(uint256 id) external view returns (CellMetaData memory) {
        require(_exists(id), "NONEXISTANT_ID");
        return cellDataSet[id].cellMetadata;
    }

    function getRawCellData(uint256 id) external view returns (CellData memory) {
        require(_exists(id), "NONEXISTANT_ID");
        return cellDataSet[id];
    }

    function getPathDataAddress(uint256 id) external view returns (address) {
        require(_exists(id), "NONEXISTANT_ID");
        return cellDataSet[id].cellPathdata;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // External functions linked to the claiming contract
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function setClaimer(address newClaimer) external {
        require(msg.sender == deployer, "NOT_PERMITTED");
        claimContract = newClaimer;
    }

    // claiming moved to external contract, claiming contract has to ensure there are no collisions in assigning ids
    function claim(address _to, uint256 _id, uint16[2] memory xy) external {
        require(msg.sender == claimContract, "NOT_PERMITTED");
        cellDataSet[_id].centreX = xy[0];
        cellDataSet[_id].centreY = xy[1];
        _mint(_to, _id);
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // External functions for managing the CellData
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function setDataManager(address newDataManager) external {
        require(msg.sender == deployer, "NOT_PERMITTED");
        dataManager = newDataManager;
    }

    function revealData(uint256 id, CellData memory revealedData) external {
        require(msg.sender == dataManager, "NOT_PERMITTED");

        cellDataSet[id] = revealedData;
    }

    function checkRevealDataHash(CellData memory testData) public pure returns (bytes32 hashedData) {
        hashedData = keccak256(abi.encode(testData));
    }

    function checkRevealDataHash(CellData[] memory testData) public pure returns (bytes32[] memory hashedData) {
        uint256 loopLen = testData.length;

        for(uint256 i = 0; i<loopLen; i++) {
            hashedData[i] = keccak256(abi.encode(testData[i]));
        }

        return hashedData;
        
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function setUriCoder(address _newUriCoder) external {
        uriIntepreter = IRenderSVG(_newUriCoder);
    }


}

