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
    address[] acceptedCoins;
    mapping(address=>uint256) private COINS_PRICE;

    string internal baseURI;
    uint256 internal currentPrice=10**8 wei;
 
    mapping(string=>mapping(address=>uint256)) private HAS_ALLOWANCE;
    mapping(string=>mapping(address=>uint256)) private MINTING_POWER;

    //check the string use by the user is not repeat
    mapping(string=>bool)public _names;


    constructor() ERC721("Deccert", "DECCERT") {}


    struct Certi {
        uint256 tokenId;
        string name;
        address owner;
        address previusOwner;
        uint256 blockNumber;
        uint256 time;
    }
    
    mapping(uint256=>Certi) _certificados ;
    mapping(uint256=>bool) SIGNED; 


//-----------------MODIFICADORES--------------------------//
    modifier hasPermission(string memory _uri){
        require(HAS_ALLOWANCE[_uri][msg.sender]>0,'Has to be more than 0 permissions');
        HAS_ALLOWANCE[_uri][msg.sender]--;
        _;
    }

    modifier hasMintingPower(string memory _uri){
        require(MINTING_POWER[_uri][msg.sender]>0,'Has to be more than 0 minting power');
        MINTING_POWER[_uri][msg.sender]--;
        _;
    }

    modifier LegalCoin(address _coin){
        bool pass=false;
        for (uint256 index = 0; index < acceptedCoins.length; index++) {
            if(acceptedCoins[index]==_coin){
                pass=true;
                break;
            }
        }
        require(pass,'not accepted coin');
        _;
    }
    
    function giveMintingPower(
        address _user,
        uint256 _howMuch,
        string memory _uri
        )public onlyOwner{

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


    //Owner can give user capability to mint an specific URI NFT
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

/////////////////////////////////////////////////////////////////////////////////////
    
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

    //Any user can call this function and mint their own certificate 
    function PreMintingERC20(
      string memory _name,
      string memory _uri,
      address _token_address,
      address who) external LegalCoin(_token_address)  returns (uint256){
        
        uint256 _price=COINS_PRICE[_token_address];
        require(_price>0);
        IERC20(_token_address).transferFrom(msg.sender, address(this), _price);
        
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _uri);
        SIGNED[newItemId]=false;

        Certi memory newCerti= Certi(
        _tokenIds.current(),//token id of hashima
        _name,
        who,
        who,
        block.number,
        block.timestamp
        );

        _certificados[newItemId] = newCerti;

        return newItemId;

    }

/////////////////////////////////////////////////////////////////////////////////////

    //sender sign no signed NFT.
    //hasPermission modifier rest 1 from its public mapping counting
    function SignCertificate(
        uint256 tokenId,
        string memory _uri)public hasPermission(_uri){
        SIGNED[tokenId]=true;
    }

    //function called by contract owner to give 'minting power' to backend 
    //and third partys.
    function givePermission(
        address _user,
        uint256 _howMuch,
        string memory _uri
        )public onlyOwner{

            HAS_ALLOWANCE[_uri][_user]=_howMuch;
    }


    function addCoin(address coinAddress)external onlyOwner{
        acceptedCoins.push(coinAddress);
    }


/////////////----SETTERS----//////////////
    function setPrice(uint256 _newPrice)external onlyOwner{
        currentPrice=_newPrice;
    }

    function setPriceERC20(address coin,uint256 _newPrice)external onlyOwner{
        require(_newPrice>0,'price has to be more than 0');
        for (uint256 index = 0; index < acceptedCoins.length; index++) {
            
            if(acceptedCoins[index]==coin){
                COINS_PRICE[coin]=_newPrice;
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


    function getTotal()public view returns(uint256){
        return(_tokenIds.current());
    }

    // function setBaseURI(string calldata newEntry)external onlyOwner{
    //   baseURI=newEntry;
    // }

    // function tokenURI(uint256 tokenId) public view override returns (string memory) {
    //     require(_exists(tokenId), "URI query for nonexistent token");

    //    return string(abi.encodePacked(baseURI,Strings.toString(tokenId),".json"));

    // }

    //mierda de perro
  
}