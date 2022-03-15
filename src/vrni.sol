// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "solmate/tokens/ERC721.sol";
import "solmate/utils/ReentrancyGuard.sol";

import "../lib/Base64.sol";
import "./Interfaces/IUriInterpreter.sol";

contract vrni is ERC721, ReentrancyGuard {
    IUriInterpreter private uriIntepreter;
    address public claimContract;
    address private dataManager;
    address public owner;

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

    // After initialization, all data for each NFT ID (Cell) is held in a struct and read by the IUriInterpreter, which is called by the tokenUri function
    struct CellData {
        bytes32 tokenSeed; // pseudo random seed generated upon claiming token, used to build the Voronoi Diagram
        address cellXYCoordinates; // polygon Saved as XY coordinates in Hex over 3 bytes (0xXXXYYY)
        CellViewData cellViewdata; // contains tightly packed data about the viewbox and cell colour must be interpretted by an interpreter contract 
        address cellPathdata; // SSTORE2 address for extended Path data
        CellMetaData cellMetadata; // contains tightly packed metadata which must be interpretted by an interpreter contract 
    }

    mapping (uint256 => CellData) public cellDataSet;

    uint256 public globalSeed; // set by claimant contract

    constructor() ERC721("vrni NFT", "vrni") {
        owner = msg.sender;
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
    function getSeed(uint256 id) external view returns (bytes32) {
        require(_exists(id), "NONEXISTANT_ID");
        return cellDataSet[id].tokenSeed;
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

    function getPathDataAddress(uint256 id) external view returns (address) {
        require(_exists(id), "NONEXISTANT_ID");
        return cellDataSet[id].cellPathdata;
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // External functions linked to the claiming contract
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function setClaimer(address newClaimer) external {
        require(msg.sender == owner, "NOT_PERMITTED");
        claimContract = newClaimer;
    }

    // claiming moved to external contract, claiming contract has to ensure there are no collisions in assigning ids
    function claim(address _to, uint256 _id, bytes32 _seed) external {
        require(msg.sender == claimContract, "NOT_PERMITTED");
        cellDataSet[_id].tokenSeed = _seed;
        _mint(_to, _id);
    }

    // allows the claiming contract to set the global seed once, and only once. 
    function setGlobalSeed(uint256 _globalSeed) external {
        require(msg.sender == claimContract && globalSeed == 0, "NOT_PERMITTED");
        globalSeed = _globalSeed;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // External functions for managing the CellData
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function setUriCoder(address _newUriCoder) external {
        uriIntepreter = IUriInterpreter(_newUriCoder);
    }


}

