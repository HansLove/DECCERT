// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Deccert.sol";


contract Eddi is ERC20,Ownable{

    mapping(address => mapping(uint256=>uint256)) public checkpoints;
    mapping(uint256 => bool) public has_deposited;
    mapping(uint256 => address) public staking_accounts;


    uint public REWARD_PER_BLOCK = 100;
 
    mapping(address=>uint256) private tolerance;
    //check the string use by the user is not repeat
    mapping(string=>bool)public _names;

    Deccert private contratoBase;
    constructor(Deccert deccert_contract) ERC20("Education", "EDDI") {
      _mint(msg.sender, 500**19);
      contratoBase=deccert_contract;
    }
    
    function aprovar(uint256 tokenId)external{
        contratoBase.approve(address(this), tokenId);
    }

    function deposit(uint256 tokenId) external{
        require (msg.sender == contratoBase.ownerOf(tokenId), 'Sender must be owner');
        require (!has_deposited[tokenId], 'Sender already deposited');
        //La altura del bloque de partida
        checkpoints[msg.sender][tokenId] = block.number;
        staking_accounts[tokenId]=msg.sender;
        
        contratoBase.transferFrom(msg.sender, address(this), tokenId);
      
        has_deposited[tokenId]=true;
   }

    function withdraw(uint256 tokenId) external{
        require(has_deposited[tokenId], 'No tokens to withdarw');
        require(staking_accounts[tokenId]==msg.sender,'Only the Staker');
        collect(msg.sender,tokenId);
        contratoBase.transferFrom(address(this), msg.sender, tokenId);
        
        has_deposited[tokenId]=false;
    }

    function collect(address beneficiary,uint256 tokenId) public{
        uint256 reward = calculateReward(beneficiary,tokenId);
        checkpoints[beneficiary][tokenId] = block.number;      
        _mint(msg.sender, reward);
    }

    function hashimaOnStaking(uint256 tokenId)public view returns(bool){
        return has_deposited[tokenId];
    }

    function calculateReward(address beneficiary,uint256 tokenId) public view returns(uint256){
        if(!has_deposited[tokenId])return 0;
        
        uint256 checkpoint = checkpoints[beneficiary][tokenId];
        return REWARD_PER_BLOCK*(block.number-checkpoint);
    }



}
