//SPDX-License-Identifier:MIT
pragma solidity>=0.4.0 <0.9.0;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
contract Escrow is ReentrancyGuard{
    struct Buyer {
        address buyer;
        bool   proceed;
        uint256 nounce;
    }
    struct Product{
      uint256 Id;
      bytes32 name;
      uint256 price;
      address buyer;
      address seller;
      uint256 quantity;
      bool exist;
      State status;
    }
    enum State{Existed,Ordered,Delivered,Funds_Released}
    mapping(address=>Buyer) private buyer_details;
    mapping(uint256=>Product) public product_details;
    mapping(uint256=>uint256) private amount_details;
    uint256 private fee;
    address public seller;
    bool private seller_proceed;

    event Products(uint256 indexed id,bytes32 productname,uint256 productprice,uint256 productquantity,uint256 Fee);
    event Requests(uint256 indexed id,address indexed buyer,uint256 time);
    event Orders(uint256 indexed id,address buyer);
    event ProductClaim(uint256 indexed id,address indexed buyer,uint256 amount);
    event SellerWithdraw(uint256 indexed id,address seller,uint256 amount);
    modifier OnlySeller() {
        require(msg.sender==seller,"Not a Valid Seller");
        _;
    }
    modifier OnlyBuyer() {
        require(msg.sender==buyer_details[msg.sender].buyer,"Not a Valid Buyer");
        _;
    }

    constructor(address _seller) {
        seller = _seller;
    }  
    
    receive() external payable OnlyBuyer {}
     function createProduct(uint256 _Id,bytes32 _name,uint256 _price,uint256 _quantity) public OnlySeller{
      require(!product_details[_Id].exist,"Product Already Existed");
      product_details[_Id] = Product(_Id,_name,_price,address(0),msg.sender,_quantity,true,State.Existed);  
     emit Products(_Id, _name, _price, _quantity,fee);
     }
    
     function requestProduct(uint256 _Id) public {
    require(msg.sender!=seller,"Seller cant be a Buyer");
    require(product_details[_Id].status==State.Existed,"Product is not authorized to request or Invalid Product");
         emit Requests(_Id, msg.sender, block.timestamp);
     } 
    
     function orderProduct(address _buyer,uint256 _Id) public OnlySeller{
         require(_buyer!=address(0),"Entered zero address");
         require(product_details[_Id].status==State.Existed,"Product is not authorized to order or Invalid Product");
         product_details[_Id].buyer = _buyer;
         product_details[_Id].status=State.Ordered;
         emit Orders(_Id, _buyer);
     }
    
    function claimProduct(uint256 _Id) payable public OnlyBuyer nonReentrant {
      require(product_details[_Id].status==State.Ordered,"Product is not authorized to claim or Invalid Product");
      uint256 _amount = product_details[_Id].price+fee;
      amount_details[_Id] = _amount;
      (bool sent,) = payable(address(this)).call{value:_amount}("");
      require(sent,"Transfer Failed");
      product_details[_Id].status = State.Delivered;
      buyer_details[msg.sender].proceed=true;
      buyer_details[msg.sender].nounce++; 
     emit ProductClaim(_Id, msg.sender, _amount);
    }
   
   function withdrawFunds(uint256 _Id) payable public OnlySeller nonReentrant{
       require(product_details[_Id].status==State.Delivered,"Product is not delivered yet or Invalid Product");
       (bool sent,) = payable(msg.sender).call{value:amount_details[_Id]}("");
       require(sent,"Transfer Failed");
       product_details[_Id].status = State.Funds_Released;
      seller_proceed=true; 
   emit SellerWithdraw(_Id, msg.sender, amount_details[_Id]);
   } 

    function setFee(uint256 _fee) public OnlySeller {
        fee=_fee;
    }
    
    function getProductDetails(uint256 _Id) public view returns(Product memory){
        require(product_details[_Id].exist,"product not existed");
        return product_details[_Id]; 
    }
    
}