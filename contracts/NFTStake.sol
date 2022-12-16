//SPDX-License-Identifier:MIT
pragma solidity >=0.4.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakeMyNFT is ERC20,ERC721Holder {
    IERC721 public NFTCollection;
    IERC20 public RewardToken;
    
    constructor(IERC721 _nft) ERC20("BTSToken","BTS") {
       NFTCollection = _nft;
    }
    
    struct Staker {
        address staker;
        uint256 tokenid;
        uint256 timestamp;
    }

    mapping(address=>Staker) private staker_details;
    mapping(uint256=>uint256) private staking_details;
    mapping(address=>mapping(uint256=>bool)) private stakeValidator;
    
    function stakeNFT(IERC721 _tokenaddress,uint256 _tokenid) public {
        require(NFTCollection==_tokenaddress,"Not a Valid NFT");
        require(msg.sender==NFTCollection.ownerOf(_tokenid),"Not an Authorized owner");
        require(!stakeValidator[msg.sender][_tokenid],"token alrdy at staking");
        staker_details[msg.sender].staker = msg.sender;
        staker_details[msg.sender].tokenid = _tokenid;
        staker_details[msg.sender].timestamp = block.timestamp;
        staking_details[_tokenid] = staker_details[msg.sender].timestamp;
        NFTCollection.safeTransferFrom(msg.sender,address(this),_tokenid);
        stakeValidator[msg.sender][_tokenid] = true; 
    }

    function claimReward(IERC721 _tokenaddress,uint256 _tokenid) public {
        require(NFTCollection==_tokenaddress,"Not a Valid NFT");
        require(stakeValidator[msg.sender][_tokenid],"token not yet staked");
        uint256 time = staking_details[_tokenid] - block.timestamp;
        require(time>=30 days,"token must stake atleast 30 days to claimrewards");
        uint256 reward = calculateReward(time);
        NFTCollection.safeTransferFrom(address(this),msg.sender,_tokenid,"");
        _mint(msg.sender, reward);
        delete staker_details[msg.sender];
        delete staking_details[_tokenid];
        stakeValidator[msg.sender][_tokenid] = false;
    }

    function calculateReward(uint256 _time) private view returns(uint256){
        return (_time*((20*10**decimals())/1 days));
    }
}