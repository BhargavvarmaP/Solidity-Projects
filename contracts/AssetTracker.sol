// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.9.0;
contract AssetTracker {
  address private Admin;
  constructor(address _admin){
    Admin=_admin;
  }
   struct Users {
    address[] manufacturers;
    address[] distributors;
    address[] retailers;
   }
    struct Asset{
      uint256 assetid;
      string assetname;
      string assetdesc;
      address manufacturer;
      bool intialized;
      OWNER  role;
    }
    mapping(uint256=>Asset) public assetlist;
    mapping(uint256=>Users) internal userlist;
    mapping(address=>mapping(uint256=>bool)) private uservalidator;
    mapping(address => mapping(uint256 => bool)) private AssetStore;
    uint256 internal users;
    uint256 internal assets;
    enum OWNER{MANUFACTURER,DISTRIBUTOR,RETAILER}
   
   modifier OnlyAdmin() {
    require(msg.sender==Admin,"Not an Authorized user");
    _;
   }
   
   modifier checkRetailer(address _addr) {
    for(uint256 i=0;i<userlist[users].retailers.length;i++){
    require(_addr==userlist[users].retailers[i],"Not an Authorized user");
    }
              _;
   }
   modifier nonzeroAddress(address _addr){
    require(_addr!=address(0),"Entered Zero address");
        _;
   }
    function createManufacturer(address _manufacturer) public OnlyAdmin nonzeroAddress(_manufacturer){
        userlist[users].manufacturers.push(_manufacturer);
    }
    
    function createDistributor(address _distributor) public OnlyAdmin nonzeroAddress(_distributor){
        userlist[users].manufacturers.push(_distributor);
    }
    
    function createRetailer(address _retailer) public OnlyAdmin {
        userlist[users].manufacturers.push(_retailer);
    }
    function createAsset(uint256 _assetid,string calldata _assetname,string calldata _assetdesc) public  {
        require(!assetlist[assets].intialized,"Asset already Created");
        require()
        assetlist[assets]=Asset(_assetid,_assetname,_assetdesc,msg.sender,true,OWNER.MANUFACTURER);
        assets++;
        AssetStore[msg.sender][_assetid]=true;
    }
     
     function transferAssetToDistributor(uint256 _assetid,address _distributor) public OnlyManufacturer(msg.sender) checkRetailer(_distributor)nonzeroAddress(_distributor){
      require(!assetlist[_assetid].intialized,"Asset not exists");
      AssetStore[msg.sender][_assetid]=false;
      assetlist[_assetid].role=OWNER.DISTRIBUTOR;
      AssetStore[_distributor][_assetid]=true;
     }

     function transferAssetToRetailer(uint256 _assetid,address _retailer) public OnlyDistributor(msg.sender) checkRetailer(_retailer)nonzeroAddress(_retailer){
      require(!assetlist[_assetid].intialized,"Asset not exists");
      require(assetlist[_assetid].role==OWNER.DISTRIBUTOR);
      AssetStore[msg.sender][_assetid]=false;
      assetlist[_assetid].role=OWNER.RETAILER;
      AssetStore[_retailer][_assetid]=true;
     }

    
    function getAssetStatus(uint256 _assetid) public view returns (Asset memory _asset) {
        if(assetlist[_assetid].intialized){
        return assetlist[_assetid];
        }
    }
}