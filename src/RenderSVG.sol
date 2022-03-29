// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {Base64} from "openzeppelin-contracts/contracts/utils/Base64.sol";
import {SSTORE2} from "solmate/utils/SSTORE2.sol";
import {BytesLib} from "solidity-bytes-utils/BytesLib.sol";

interface IVrni {

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

    function getXYCoordinatesAddress(uint256 id) external view returns (address);

    function getRawViewdata(uint256 id) external view returns (CellViewData memory);

    function getRawMetadata(uint256 id) external view returns (CellMetaData memory);

    function getRawCellData(uint256 id) external view returns (CellData memory);

    function getPathDataAddress(uint256 id) external view returns (address);

}

contract RenderSVG {
    using SSTORE2 for address;

    IVrni public vrniNFT;

    constructor(
        address _vrniNFT
    ){
        vrniNFT = IVrni(_vrniNFT);
    }

    function returnURI(uint256 _tokenID) external view returns (string memory) {

            address coordinatesPointer = vrniNFT.getXYCoordinatesAddress(_tokenID);

            bytes memory bytesCoords = coordinatesPointer.read();

            // find length of bytesCoords and initialize array
            uint256 coordsLength = bytesCoords.length / 4;

            uint16[] memory coordinatesArray = new uint16[](coordsLength);

            for(uint256 i = 0; i < coordsLength; i++) {
                
                coordinatesArray[i] = BytesLib.toUint16(BytesLib.slice(bytesCoords, i*4, i*4+4),0);
            }




    }
    


}

/*
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {Base64} from "openzeppelin-contracts/contracts/utils/Base64.sol";

library LootSVG {

    function tokenURIBuilder(uint256 id) public view returns (string memory) {
        string[17] memory parts;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: black; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="white" /><text x="10" y="20" class="base">NFT ID: ';

        parts[1] = Strings.toString(id);

        parts[2] = '</text><text x="10" y="40" class="base"> Collection: 0x';

        parts[3] = toAsciiString(address(this));

        parts[4] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4]));
        
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Mock NFT #', Strings.toString(id), '", "description": "Mock NFT with SVG metadata.", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function toAsciiString(address x) internal pure returns (string memory) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
        bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
        bytes1 hi = bytes1(uint8(b) / 16);
        bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
        s[2*i] = char(hi);
        s[2*i+1] = char(lo);            
    }
    return string(s);
}

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

}

*/