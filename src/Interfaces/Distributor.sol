// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "solmate/utils/ReentrancyGuard.sol";

interface IDLNY {
    function mint(address _to, uint256 _amount) external;
}

interface IDistributor {
    function logPoints(address user, uint256 gasUsed) external;
}

contract GasLogger {
    
    IDistributor private activeDistributor;

    modifier trackGas() {
        uint256 startGas = gasleft();
        _;
        uint256 endGas = gasleft();
        activeDistributor.logPoints(msg.sender, startGas - endGas);
    }

    function setDistributor(address _newDistributor) internal {
        activeDistributor = IDistributor(_newDistributor);
    }
}

// contract keeps track of gas used to perform functions
contract Distributor is Ownable, ReentrancyGuard {

    address public dlny;

    uint256 public MULTIPLIER = 10e15;

    mapping(address => bool) private pointLoggers;

    mapping(address => uint256) private claimableTokens;

    constructor(){}

    modifier onlyLogger() {
        require(pointLoggers[msg.sender], "INVALID_LOGGER");
        _;
    }

    function setToken(address _dlny) public onlyOwner {
        dlny = _dlny;
    }

    function updateMultiplier(uint256 _newMultiplier) public onlyOwner {
        MULTIPLIER = _newMultiplier;
    }

    function addLogger(address _newLogger) public onlyOwner {
        pointLoggers[_newLogger] = true;
    }

    function removeLogger(address _logger) public onlyOwner {
        pointLoggers[_logger] = false;
    }

    function logPoints(address user, uint256 gasUsed) public onlyLogger {
        claimableTokens[user] += gasUsed * MULTIPLIER;
    }

    function pendingTokens(address user) public view returns (uint256) {
        return claimableTokens[user];
    }

    function claimTokens() public nonReentrant {
        uint256 tokensToClaim = claimableTokens[msg.sender];
        claimableTokens[msg.sender] = 0;

        IDLNY(dlny).mint(msg.sender, tokensToClaim);
    }

    function claimTokens(uint256 tokensToClaim) public nonReentrant {
        require(tokensToClaim <= claimableTokens[msg.sender], "INVALID_CLAIM_AMT");
        claimableTokens[msg.sender] -= tokensToClaim;

        IDLNY(dlny).mint(msg.sender, tokensToClaim);
    }

}