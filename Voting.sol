// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "./Eddi.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


// contract Voting is Ownable{

// string []propuestas;
// //index de la propuesta=> numero de votos
// mapping(uint256=>uint256) counting;

// mapping(address=>bool) alreadyVote;

// Eddi crypto;
// constructor(Eddi contrato_eddi){
//     crypto=contrato_eddi;

// }

// function addPropousal(string memory _propuesta,uint index)public onlyOwner{
//     propuestas[index]=_propuesta;
// }
 
// function vote(uint256 _index)public{
//     require(!alreadyVote[msg.sender],'already vote');
//     uint256 userBalance=crypto.balanceOf(msg.sender);
//     counting[_index]=counting[_index]+userBalance;
//     alreadyVote[msg.sender]=true;
// }


// }