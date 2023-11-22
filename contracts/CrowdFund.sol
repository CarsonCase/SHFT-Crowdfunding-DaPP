// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

error TransferLock();
error RefundNotAvailable();
error FailedRaise();
error FundEarly();
error AlreadyComplete();
error NothingToClaim();

struct Tokenomics{
    uint team;
    uint liquidity;
    uint marketing;
    uint investors;
    uint crowdFund;
}

contract CrowdFund is ERC20, Ownable{
    bool isComplete;
    uint public endTime;
    uint public fundingGoal;
    uint tokensLeftForFund;
    Tokenomics public tokenomics;

    mapping(address=>uint) public contributions;

    event NewContribution(uint amount);

    constructor(uint _endTime, uint _fundingGoal, Tokenomics memory _tokenomics) ERC20("MyToken","MTKN") Ownable(msg.sender){
        endTime = _endTime;
        fundingGoal = _fundingGoal;
        tokenomics = _tokenomics;
    
        _mint(address(1), tokenomics.team);
        _mint(address(this), tokenomics.liquidity);
        _mint(address(3), tokenomics.marketing);
        _mint(address(4), tokenomics.investors);
        tokensLeftForFund = tokenomics.crowdFund;
        _mint(address(this), tokenomics.crowdFund);
    }

    receive() payable external{
        if(block.timestamp >= endTime){
            revert AlreadyComplete();
        }
        if(msg.value != 0){
            tokensLeftForFund -= msg.value;
            _transfer(address(this), msg.sender, msg.value);
            contributions[msg.sender] += msg.value;
            emit NewContribution(msg.value);
        }

    }

    function getStruct() external view returns(Tokenomics memory){
        return tokenomics;
    }

    function fund() external onlyOwner{
        if(isComplete){
            revert AlreadyComplete();
        }
        if(block.timestamp < endTime){
            revert FundEarly();
        }
        if(address(this).balance < fundingGoal){
            revert FailedRaise();
        }
        isComplete = true;
        payable(owner()).call{value: address(this).balance}("");
    }

    function _update(address from, address to, uint256 value) internal override{
        if(from != address(0) && from != address(this) && !isComplete){
            revert TransferLock();
        }
        super._update(from,to,value);
    }

    function claim() external returns(uint claimedAmount){
        claimedAmount = contributions[msg.sender];
        contributions[msg.sender] = 0;

        if(isComplete){
            revert AlreadyComplete();
        }
        if(block.timestamp < endTime){
            revert RefundNotAvailable();
        }
        if(address(this).balance >= fundingGoal){
            revert RefundNotAvailable();
        }
        if(claimedAmount == 0){
            revert NothingToClaim();
        }
        payable(msg.sender).call{value:claimedAmount}("");
    }
}
