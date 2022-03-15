# vrniWrlds #
**vrniWrlds is a maximally onchain open-ended world-building and strategy game, centred around owned components. vrniWrlds is compromised of two major building blocks, the vrni land NFT ("vrni"), and the DLNY token ("DLNY").**

**Note vrniWrlds is purely experimental, unaudited and not intended to be an investment or speculative instrument of any kind. The developers of this project will not be liable for any loss which results from the use of this project. By using these contracts, front ends or any other vrniWrlds related products, users accept that they are aware of these risks and assume responsibility for any loss that may result. The developers of this project have no intention to conduct any marketing, seek entry for any token related to this project into an exchange, and will not provide guidance to further development of this project, nor issue a "roadmap". All code produced as part of this project is released under an open-source license, and provided on an as-is basis.**

License: https://github.com/ColinPlatt/vrniWrlds/blob/main/LICENSE

## Introduction ##

The name vrni comes from the Voronoi Diagram or Voronoi Tessellation, a mathematical concept used to partition a plane into regions closest to a centre. It is named after Ukranian mathematian Georgy Voronoy. In a Voronoi Diagram, regions or "cells" are the areas closest to the originating point. A simple real world example is the areas around a post office attributed to a postal worker, with each individual post office looking to minimise the distance covered and thus splitting their regional coverage amongst all post office in a given district. Voronoi Diagrams are used in a variety of other scientific and engineering applications.

Interestingly, from an NFT and land game perspective, Voronoi cells are not squares on a grid, but somewhat random polygons. This allows for much greater differentiation amongst cells within a map, which can be differentiated not only by their game features, such as geographical features, location relative to others on a map, or in game resource and population, but also by size and shape. These non standard polygons, also allow for much more feature rich maps, whilst minimalising the computing resouce needs. In short, by using a Voronoi Diagram, you can have a complex map, that can be completely built onchain.

Within the mathematics aspect of Voronoi Diagrams, the dual, is known as the Delaunay triangulation. It is used to calculate and construct a Voronoi Diagram. The Delaunay triangulation is named for Russian mathematian Boris Delaunay, who developed his Doctoral Thesis based on Voronoy's work.

Considering its complementary nature, DLNY is an ERC20 based token that allows the holder of a vrni NFT to change and modify aspects related to its underlying onchain metadata. DLNY tokens are released in two ways, through a novel concept we will call "function mining", and later through a staking process that releases DLNY tokens based on attributes of the vrni NFTs themselves in a way that is coherent within the gameplay.

## Onchain Metadata ##

vrni NFTs are built in a "maximally onchain" manner. This means that everything about the NFT that should be stored, should be done on the underlying blockchain, and anything used to compute what is stored, if reasonably possible, should be done on chain.  The vrniWlrds project is intended to be built using the Arbitrum L2 blockchain, which offers lower costs than the Ethereum mainnet, greater computational abilityt, while deriving part of its security assumptions from the Ethereum blockchain itself.

vrni NFTs conform to the ERC721 (based on the Rari-capital solmate implementation), and metadata can be split as follows:

- visual imagery: held onchain in Base64 encoded SVG (Scalable Vector Graphics), which allows for smart contracts to directly affect change to the visual imagery in a way that does not require a trusted third party.

- attribute metadata: stored onchain in JSON readable format, which can be updated with smart contract interactions, allowing vrni NFTs to evolve with game play and over time. Attributes can be read and analysed by NFT marketplaces.

Each individual vrni NFT is mapped to its corresponding metadata which is held by the NFT smart contract, this includes the following data fields:

- Cell Data
    - Initial coordinates (x,y on a 2d plane 3840x2160), which are assigned in a pseudo-random process upon minting and evolved in the initiation process to become the originating points
    - Polygon coordinates, dimensions of the edges of the cell or land area. This is developed through the initiation process which combines onchain and offchain calculations (which are returned to the storage through a modified MerkleDrop)
    - Pathdata, a SSTORE2 address which allows for later linking to extensions and inclusion of more complex visual elements for the vrni NFTs.

- View Data
    - Colour (RGB), saving information linked to the colour of the cell shown when viewing the NFT in a web browser. Initially this will be linked to whether the cell covers land or water, and altitude/depth. Later, will include tinting linked to population, development, pollution, and goverance
    - Viewbox coordinates, allows the NFT holder to "zoom in" and "zoom out" on their cell when displaying their cell.

- Gameplay Metadata
    - Population: attributed during the initialization phase, and evolves overtime through smart contract interaction and gameplay
    - Altitude: attributed during the initiatization phase
    - Climate: attributed during the initiatization phase
    - Resources: attributed during the initiatization phase, and evolves overtime through smart contract interaction and gameplay
    - Language: attributed during the initiatization phase
    - Development: attributed during the initiatization phase, and evolves overtime through smart contract interaction and gameplay
    - Industry: evolves overtime through smart contract interaction and gameplay
    - Tax Rate: set by the vrni NFT owner through smart contract interaction
    - Government: set by the vrni NFT owner through smart contract interaction, and can be used to create "delegatation" for certain aspects that affect other gameplay metadata (e.g. tax rates)


## DLNY Token Usages ##

The DLNY token is used within the vrniWrlds game, and has no external value. It can be used to modify some aspects of metadata, by "upgrading" and "reinvesting".

- Upgrading using DLNY tokens, allows a vrni NFT holder to interact with a smart contract to discover or exploit features in their NFT. This could include developing the capability to extract resources, develop an industry or evolve the overall development index. Upgrading is a one-off "payment" that changes the index level of a point in metadata. Upgrading requires "burning" DLNY tokens through smart contract interaction.
- Reinvesting DLNY allows a vrni NFT holder to commit DLNY to the NFT smart contract to improve aspect of their gameplay Metadata overtime. It can be thought of as locking DLNY to produce more DLNY tokens over time, and at anypoint the vrni NFT can remove their "staked" DLNY tokens from this contract.

In addition to upgrading and reinvesting the DLNY token, vrni NFTs themselves can be locked to allow for the evolution of certain gameplay metadata aspects, such as population increases, and tax collection (released in DLNY).

#### Function Mining ####

As vrniWrlds is maximally onchain, the project will require paying a considerablly higher amount of gas than a typical project. During the initialization phase, in particular, there will be the need to compute and save a large amount of data to the Arbitrum blockchain. While all aspects of this phase could be done by the developers, this leads to centralisation concerns and reduces community participation. The alternative proposed is "function mining", this can be described as the developers creating and deploying a series of smart contracts which can interact with the vrni NFT metadata, and allowing **anyone holding a vrni NFT** to interact with the contract to initiate a computation (and pay the gas for that computation). The functions are run in the way that the executing party cannot change any of the aspects about how the process is run, it simply spreads the costs and responsibility of its execution amongst the network of vrni NFT holders. As the executing party spends ETH for the common good of the project, the execution logs the gas spent (note this is gas and not the final amount of ETH as it does not account for the _gas price_). The total amount of gas logged is stored in a special **distributor contract**, and allows the executor to withdraw 1 DLNY token for every 1000 gas spent. Given this method, it is not possible to know the exact amount of DLNY tokens that will be produced during this phase.

Function Mining also allows users who do not wish to engage in multiple ongoing claiming events across multiple individual NFTs to complete a task that updates and reveals for vrni NFTs that they do not own in a trustless manner.  



## Project Phases ##

- Minting
 There will be a maximum of 10,000 vrni NFTs available to be minted, of which a number will be reserved for ENSO NFT holders following a snapshot. Minting will be done a first-come-first-served basis. Upon minting the vrni NFT will be assigned an iniatial coordinate (site), this will be used to generate the initial Voronoi Diagram, which will be overlayed on a secondary contract, as such it is a piece of the puzzle, but not the final piece, as to which cell will be attributed to the individual vrni NFT. 10 NFTs of the 10,000 total supply will be reserved for minting by the deployer contract, these tokens will be used participate in the game and give clarity to the holdings of the developers.

- Initialization
 Following the minting process, or in the even that not all vrni NFTs are minted and the community have deemed that the process should commence, the project can move to the initialization phase (closing further mints in the event that not all NFTs are claimed). 

 In this phase, an offchain process will take place, collecting all sites, and computing a final Voronoi Diagram. This process will be run through a script that will be published ahead of time, and verifiable by any participant who wishes to run verify it. Following its completion, the results will be published through a modified MerkleDrop, which allows initially for each vrni NFT holder to reveal their cell data and gameplay metadata, doing so will trigger function mining releasing the initial supply of DLNY. After a predetermined period, if not all vrni NFT metadata has been revealed, function mining will be opened up to allow anyone holding vrni NFTs to reveal the remaining metadata in batches.

- Full gameplay
Once the Initialization phase has been completed and all vrni NFT metadata has been revealed, the project will be considered to be in full gameplay. This will allow for the operation of reinvesting, upgrading and NFT staking.
