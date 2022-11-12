//SPDX-License-Identifier:MIT
pragma solidity >=0.4.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
//importing ERC721 file from openzeppelin
contract IPLPlay is ERC721 {

    address payable public Organizer; //Organizer who creates player nfts 
    
    struct Player{
        string name; //player name
        uint runs; // runs scored by player
        uint wickets; //number of wickets taken by player
        string level; // on what level the player card in eg:rookie,bronze,silver,gold,platinum
        uint points; // points scored by player card by participating in game
    }
     //stores the player info by player id , playerid=>Player
    mapping(uint=>Player) public IPLPlayers;
    // stores the price of playerid, playerid => price 
    mapping (uint=>uint) public PlayersPrice; 
    //index of player cards
    uint internal playerid=1001;

    constructor(address _organizer) ERC721("IPL Cricket Cards","IPLNFT") {
      //assigning the msg.sender address to Organizer
      Organizer=payable(_organizer);
    }
     //creating modifier for accessing functions by only organizer
    modifier OnlyOrganizer() {
        require(Organizer==msg.sender);
        _;
   }
   
      event TransferPlayerNFT(address indexed sender,address indexed receiver,uint value);
    //this function creates player and only accessible by Organizer
    function createPlayer(string memory _name,uint _runs,uint _wickets) public OnlyOrganizer {
     //assigning the values to IPLPlayers
     IPLPlayers[playerid]=Player(_name,_runs,_wickets,"Rookie",0);
     //calls safemint function in ERC721
     _safeMint(msg.sender,playerid);
     //Player id be incremented after every player creation
     playerid++;

   }
     //this function starts game between two playercards
   function BeginGame(uint _attackerid,address _attackeraddr,
                      uint _defenderid,address _defenderaddr) public OnlyOrganizer{
                        
    require(_attackeraddr==address(0)&&_attackeraddr==address(0),"Entered zero address");
   require(_attackeraddr==ownerOf(_attackerid),"Attacker owner and entered address mismatch");
   require(_defenderaddr==ownerOf(_defenderid),"Defender owner and entered address mismatch");
    Player storage Player1 = IPLPlayers[_attackerid];
    Player storage Player2 = IPLPlayers[_defenderid];

     if(Player1.runs>Player2.runs && Player1.wickets>Player2.wickets){
        Player1.points+=5;           
    }
    else if(Player1.runs>Player2.runs || Player1.wickets>Player2.wickets){
        Player1.points+=3;
    }
    else if(Player2.runs>Player1.runs || Player2.wickets>Player1.wickets){
        Player2.points+=3;
    }
    else{
        Player2.points+=5;
    }
    //calls upgrade level function to check points and update Player 1 level
     Player1.level = upgradelevel(Player1.points); 
     //calls upgrade level function to check points and update Player 2 level
     Player2.level = upgradelevel(Player2.points); 
}
    function upgradelevel(uint _points) internal pure returns(string memory _level){
        if(_points>100 && _points<350){
            return "Bronze";
        }
        else if(_points>=350 && _points<750){
            return "Silver";
        }
        else if(_points>=750){
            return "Gold";
        }
    }
    //this function allows to sets the  price and buy the player card,it only access by the owner of nft
   function allowBuy(uint _playerid,uint _price) public  {
    _price=_price*10**18;
    require(msg.sender == ownerOf(_playerid), "You are not holding the Player card");
       require(_price>= 1 ether,"Price must be greater than 1 ether");
        PlayersPrice[_playerid] = _price;
    }
     //this function allows to disable the playercard to buy by changing price to zero
    function disallowBuy(uint _playerid) public  {
    require(msg.sender == ownerOf(_playerid), "You are not holding the Player card");    
        PlayersPrice[_playerid] = 0;
    }
   //this function is to buy the playercard
   function buyPlayerCard(uint _playerid) payable public {
     //creating the variable called price so that it stores the price of playercard
        uint price = PlayersPrice[_playerid];
        require(price > 0, "This Playercard is not for sale");
        require(msg.value == price, "Incorrect value");
       //creating the variable called seller so that it stores the address of owner of playercard      
        address seller = ownerOf(_playerid);
        //calls the transfer function of ERC721,so that the player card transfers from owner to buyer
        _transfer(seller, msg.sender, _playerid);
        // it disallow the player card to buy after transfer,to allow it owner must call allow buy function
        PlayersPrice[_playerid] = 0; 
        // send the ETH to the seller
      (bool sent,)=payable(seller).call{value:msg.value}(""); 
        require(sent,"Failed to send ether");
        //emits the event of who is selling and who is buying and the value of player card
        emit Transfer(seller, msg.sender, msg.value);
    }
    function getBalance(address _addr) public  view returns(uint){
        require(_addr==address(0),"Entered zero address");
          return _addr.balance;
    }
    function setOrganizer(address _addr) public OnlyOrganizer {
        require(_addr==address(0),"Entered zero address");
        Organizer=payable(_addr);
    }
}