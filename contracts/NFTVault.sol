// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
contract NFTVault {
    IERC721 immutable public NFTCollection;
    constructor(IERC721 _nftcollection){
        NFTCollection=_nftcollection;
    }
   struct NFT{
        address depositor;
        uint256 tokenid;
        uint256 timestamp;
    }

    mapping(address=>mapping(uint256=>NFT)) public NFTlist;
    uint256 public nfts;

          event NFTDeposit(address indexed sender,uint256 tokenid);
          event NFTWithdraw(address indexed receiver,uint256 tokenid);

    function Deposit(uint256 _tokenid,IERC721 _nftaddr) public {
       require(IERC721(_nftaddr)==NFTCollection,"Not a Valid NFT");
       NFTCollection.safeTransferFrom(msg.sender,address(this),_tokenid,"");
        NFTlist[msg.sender][_tokenid]=NFT(msg.sender,_tokenid,block.timestamp);
        nfts++;
      emit NFTDeposit(msg.sender,_tokenid);
   }   

   function Withdraw(uint256 _tokenid,IERC721 _nftaddr) public {
       require(IERC721(_nftaddr)==NFTCollection,"Not a Valid NFT");
       NFTCollection.safeTransferFrom(address(this),msg.sender,_tokenid,"");
        delete NFTlist[msg.sender][_tokenid];
        nfts--;
        emit NFTWithdraw(msg.sender,_tokenid);
   }
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public pure returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}