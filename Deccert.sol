// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721UriStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Deccert is ERC721URIStorage,Ownable{

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
 
    mapping(address=>uint256) private hasAllowance;
    //check the string use by the user is not repeat
    mapping(string=>bool)public _names;


    constructor() ERC721("Deccert", "DECCERT") {}

    struct Certi {
        uint256 tokenId;
        string name;
        string class;
        address owner;
        bool signed;
        uint256 blockNumber;
    }


    
    mapping(uint256=>Certi) _certificados ;
    address[] acceptedCoins;
    uint256[] priceCoins;

    string internal baseURI;
    uint256 internal currentPrice=10**8 wei;

    //MODIFICADORES
    modifier canDoIt(){
        require(hasAllowance[msg.sender]>0,'Has to be more than 0 permissions');
        hasAllowance[msg.sender]--;
        _;
    }

    modifier isValidCoin(address coinAddress){
        bool pass=false;
        for (uint256 index = 0; index < acceptedCoins.length; index++) {
            if (acceptedCoins[index]==coinAddress) {
                pass=true;
            }
        
        }
        require(pass,'its not a valid coin');
        _;
    }

    modifier isValidCoinPrice(address coinAddress,uint256 _price){
        bool pass=false;
        for (uint256 index = 0; index < acceptedCoins.length; index++) {
            if (acceptedCoins[index]==coinAddress) {
                
                if(priceCoins[index]>=_price){
                    pass=true;
                }
            }
        
        }
        require(pass,'its not a valid price ERC-20');
        _;
    }

    function createCertificate(
      string memory _name,
      string memory _class) external payable  returns (uint256){

      require(msg.value>currentPrice,'at least 0.1 Ethers');
      _tokenIds.increment();

      uint256 newItemId = _tokenIds.current();
      _mint(msg.sender, newItemId);


      Certi memory newCerti= Certi(
      _tokenIds.current(),//token id of hashima
      _name,
      _class,
      msg.sender,
      false,
      block.number);

      _certificados[newItemId] = newCerti;

      return newItemId;

    }


    function createCertificateERC20(
      string memory _name,
      string memory _class,
      address coin,
      uint256 coin_amount
      )external isValidCoin(coin) isValidCoinPrice(coin,coin_amount) returns (uint256){

      
      _tokenIds.increment();

      uint256 newItemId = _tokenIds.current();
      _mint(msg.sender, newItemId);


      Certi memory newCerti= Certi(
      _tokenIds.current(),//token id of hashima
      _name,
      _class,
      msg.sender,
      false,
      block.number);

      _certificados[newItemId] = newCerti;

      return newItemId;

    }

   function giveAllowance(address who,uint256 amount)external onlyOwner{
     hasAllowance[who]=amount;
  }
   
    function addCoin(address coinAddress)external onlyOwner{
        acceptedCoins.push(coinAddress);
    }

    function signNFT(uint256 NFT_ID)external canDoIt
    {
        _certificados[NFT_ID].signed=true;
    }
  
    function setPrice(uint256 _newPrice)external onlyOwner{
        currentPrice=_newPrice;
    }

    function setPriceERC20(address coin,uint256 _newPrice)external onlyOwner{
        require(_newPrice>0,'price has to be more than 0');
        for (uint256 index = 0; index < acceptedCoins.length; index++) {
            
            if(acceptedCoins[index]==coin){
                priceCoins[index]=_newPrice;
                break;
            }
        }
        
    }
    function get(uint256 _index)public view returns(Certi memory){
          return _certificados[_index];
    }
  
    function check(uint256 _index)external view{
          require(_certificados[_index].owner==msg.sender);
    }


    function dameTotal()public view returns(uint256){
        return(_tokenIds.current());
    }

    function setBaseURI(string calldata newEntry)external onlyOwner{
      baseURI=newEntry;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");

       return string(abi.encodePacked(baseURI,Strings.toString(tokenId),".json"));

        
    }

}