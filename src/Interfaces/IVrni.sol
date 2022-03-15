// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

interface IVoronoiWorld is IERC721 {
    
    // we split the CellViewData from the CellMetaData information to optimise the storage in the CellData struct. ViewData contains data directly viewable in the SVG.
    struct CellViewData {
        bytes3 colourRGB; 
        uint16 viewBoxX;
        uint16 viewBoxY;
        uint16 viewBoxWidth;
        uint16 viewBoxHeight;
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
    }
    
    function claimContract() external view returns (address);

    function getSeed(uint256 id) external view returns (bytes32);

    function getXYCoordinatesAddress(uint256 id) external view returns (address);

    function getRawMetadata(uint256 id) external view returns (CellMetaData memory);

    function getRawViewdata(uint256 id) external view returns (CellViewData memory);

    function getPathDataAddress(uint256 id) external view returns (address);

    function updateCellCoordinates(uint256 id, address _xyCoordPointer) external;

    function updateCellMetadata(uint256 id, bytes32 _RawMetadata) external;

    function setDataSetter(address _newDataSetter) external;

    function setUriCoder(address _newUriCoder) external;

    function globalSeed() external returns (uint256);

}