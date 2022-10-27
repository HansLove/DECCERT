// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IHashima.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Server is Ownable,ReentrancyGuard{

    mapping(address=>Payment) debt;
    uint256 private STARS_LIMIT=2;
    IHashima hashimaContract;
    
    constructor(IHashima hashima_contract){
        hashimaContract=hashima_contract;
    
    }

    struct Payment{
        uint256 stars;
        string URI;
        bool paid;
    }



    uint256 minPrice=0.0001 ether;


    function payServer(uint256 _stars,string calldata _uri)external payable{
        require(msg.value>=minPrice,'min price no reach');
        require(_stars<STARS_LIMIT,'stars limit reach');

        Payment memory paymentInput=Payment(
            _stars,
            _uri,
            true
        );

        debt[msg.sender]=paymentInput;
    }

    //Esta funciona la llama el servidor para ver si el usuario pago su Hashima
    //devuelve si pago y cuantas estrellas junto con la URI
    function checkPayment(address _user)public view returns(bool,uint256,string memory){
        return (debt[_user].paid,debt[_user].stars,debt[_user].URI);
    }


    //cuando el servidor tenga listo el hashima lo deposita
    function depositHashima(uint256 tokenId,address clientUser)external nonReentrant{
        require(debt[clientUser].paid,'user no pay');
        hashimaContract.transferFrom(msg.sender, clientUser, tokenId);
        Payment memory newPay=debt[clientUser];
        newPay.paid=false;
        debt[clientUser]=newPay;
    }
    
    function paymentRegister(address _user)external view returns(bool){
        return debt[_user].paid;
    }

    //Funcion para que el dueño cambie el precio
    function setMinPrice(uint256 _minPrice)public onlyOwner{
        minPrice=_minPrice;
    }

    //Funcion para que el dueño cambie la tolerancia del estrellas
    //This number multiplies by 2
    function setStarsLimit(uint256 _numberStars)public onlyOwner{
        STARS_LIMIT=_numberStars;
    }

}