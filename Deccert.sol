// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Deccert is ERC721URIStorage,Ownable{

    using Counters for Counters.Counter;

    ///////////////-----Variable-------------///////////
    Counters.Counter private _tokenIds;
    mapping(address=>uint256) private COINS_PRICE;

    string internal baseURI;
    uint256 internal currentPrice=10**8 wei;
 
    mapping(string=>mapping(address=>uint256)) private MINTING_POWER;


    constructor() ERC721("Deccert", "DECCERT") {}

    struct Certi {
        uint256 tokenId;
        string name;
        address owner;
        address previusOwner;
        uint256 blockNumber;
        uint256 time;
    }
    
    mapping(uint256=>Certi) _certificados;
    mapping(uint256=>bool) SIGNED; 


    modifier hasMintingPower(string memory _uri){
        require(MINTING_POWER[_uri][msg.sender]>0,'Has to be more than 0 minting power');
        MINTING_POWER[_uri][msg.sender]--;
        _;
    }

    function giveMintingPower(
        address _user,
        uint256 _howMuch,
        string memory _uri)public onlyOwner{

            MINTING_POWER[_uri][_user]=_howMuch;
    }


    //Only the owner can call this function to mint NFT
    function ManualMinting(
        string memory _name,
        string memory _uri,
        address who
        ) external onlyOwner returns(uint256){

        //incrementamos en 1 el contador
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _uri);
        SIGNED[newItemId]=true;

        Certi memory newCerti= Certi(
        _tokenIds.current(),//token id of Deccert certificate
        _name,
        who,
        who,
        block.number,
        block.timestamp
        );

        _certificados[newItemId] = newCerti;

        return newItemId;

    }


    //Admin can give user capability to mint an specific URI NFT
    //Admin has to 
    function PermissionMinting(
        string memory _name,
        string memory _uri,
        address who) external hasMintingPower(_uri) returns(uint256){

        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _uri);
        SIGNED[newItemId]=true;

        Certi memory newCerti= Certi(
        _tokenIds.current(),//token id of Deccert certificate
        _name,
        who,
        address(0),
        block.number,
        block.timestamp
        );

        _certificados[newItemId] = newCerti;

        return newItemId;

    }


    //Any user can call this function and mint their own certificate 
    function PreMinting(
      string memory _name,
      string memory _uri,
      address who) external payable returns (uint256){

        //incrementamos en 1 el contador
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _uri);
        SIGNED[newItemId]=false;

        Certi memory newCerti= Certi(
        _tokenIds.current(),//token id of Deccert NFT
        _name,
        who,
        who,
        block.number,
        block.timestamp
        );

        _certificados[newItemId] = newCerti;

        return newItemId;

    }

    function SignNFT(uint256 tokenId) external onlyOwner{
        require(!SIGNED[tokenId],'NFT already signed');
        SIGNED[tokenId]=true;
    }

    function UnsignNFT(uint256 tokenId)external onlyOwner{
        require(SIGNED[tokenId],'NFT already signed');
        SIGNED[tokenId]=false;
    }



    function get(uint256 _index)public view returns(Certi memory){
          return _certificados[_index];
    }
  
    function getTotal()public view returns(uint256){
        return(_tokenIds.current());
    }


    //Returns the amount of NFTs that an account can
    //Mint for an specific URL
    function getMintingPower(string memory what,address _who)external view returns(uint256){
        return MINTING_POWER[what][_who];
    }

    // function setBaseURI(string calldata newEntry)external onlyOwner{
    //   baseURI=newEntry;
    // }

    // function tokenURI(uint256 tokenId) public view override returns (string memory) {
    //     require(_exists(tokenId), "URI query for nonexistent token");

    //    return string(abi.encodePacked(baseURI,Strings.toString(tokenId),".json"));

    // }

  
}