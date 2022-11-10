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
      uint256[] parts;
      bool intialized;
      OWNER  role;
    }
    struct Part{
        uint256 partid;
        string partname;
        string partdesc;
        address manufacturer;
        address[] owners;
    }
    mapping(uint256=>Asset) public assetlist;
    mapping(uint256=>Part) public partlist;
    mapping(uint256=>Users) internal userlist;
    mapping(address=>mapping(uint256=>bool)) private uservalidator;
    mapping(address => mapping(uint256 => bool)) private AssetStore;
    uint256 internal users;
    uint256 internal assets;
    uint256 internal parts;
    enum OWNER{MANUFACTURER,DISTRIBUTOR,RETAILER}
   
   modifier OnlyAdmin() {
    require(msg.sender==Admin,"Not an Authorized user");
    _;
   }
   modifier OnlyManufacturer(address _addr) {
    for(uint256 i=0;i<userlist[users].manufacturers.length;i++){
    require(msg.sender==userlist[users].manufacturers[i],"Not an Authorized user");
    }
    _;
   }
   modifier OnlyDistributor(address _addr) {
    for(uint256 i=0;i<userlist[users].distributors.length;i++){
    require(msg.sender==userlist[users].distributors[i],"Not an Authorized user");
    }
    _;
   }
   modifier checkDistributor(address _addr) {
    for(uint256 i=0;i<userlist[users].distributors.length;i++){
    require(_addr==userlist[users].distributors[i],"Not an Authorized user");
    }
    _;
   }
   modifier checkRetailer(address _addr) {
    for(uint256 i=0;i<userlist[users].retailers.length;i++){
    require(_addr==userlist[users].retailers[i],"Not an Authorized user");
    }
    _;
   }
    function createManufacturer(address _manufacturer) public OnlyAdmin {
        userlist[users].manufacturers.push(_manufacturer);
    }
    
    function createDistributor(address _distributor) public OnlyAdmin {
        userlist[users].manufacturers.push(_distributor);
    }
    
    function createRetailer(address _retailer) public OnlyAdmin {
        userlist[users].manufacturers.push(_retailer);
    }
    function createAsset(uint256 _assetid,string calldata _assetname,string calldata _assetdesc,
                                       uint256[] calldata _parts) public OnlyManufacturer(msg.sender) {
        require(!assetlist[assets].intialized,"Asset already Created");
        assetlist[assets].assetid = _assetid;
        assetlist[assets].assetname = _assetname;
        assetlist[assets].assetdesc = _assetdesc;
        assetlist[assets].manufacturer = msg.sender;

        for(uint256 i = 0; i<parts; i++) {
            assetlist[assets].parts.push(_parts[i]);
        }
        assetlist[assets].intialized=true;
        assetlist[assets].role=OWNER.MANUFACTURER;
        assets++;
        AssetStore[msg.sender][_assetid]=true;
    }
     function createPart (uint256 _partid,string calldata _partname,string calldata _partdesc,
                                          address _manufacturer) public OnlyManufacturer(msg.sender) {
        
        partlist[parts].partid = _partid;
        partlist[parts].partname = _partname;
        partlist[parts].partdesc = _partdesc;
        partlist[parts].manufacturer = _manufacturer; 
        partlist[parts].owners.push(_manufacturer);
        parts++;
    }
     
     function transferAssetToDistributor(uint256 _assetid,address _distributor) public OnlyManufacturer(msg.sender) checkRetailer(_distributor){
      require(!assetlist[_assetid].intialized,"Asset not exists");
      AssetStore[msg.sender][_assetid]=false;
      assetlist[_assetid].role=OWNER.DISTRIBUTOR;
      AssetStore[_distributor][_assetid]=true;
     }

     function transferAssetToRetailer(uint256 _assetid,address _retailer) public OnlyDistributor(msg.sender) checkRetailer(_retailer){
      require(!assetlist[_assetid].intialized,"Asset not exists");
      require(assetlist[_assetid].role==OWNER.DISTRIBUTOR);
      AssetStore[msg.sender][_assetid]=false;
      assetlist[_assetid].role=OWNER.RETAILER;
      AssetStore[_retailer][_assetid]=true;
     }

    function getPartOwners(uint256 _partid) public view returns (address[] memory) {
        return partlist[_partid].owners;
    }
    
    function getAssemblyPartList(uint256 _assetid) public view returns (uint256[] memory) {
        return assetlist[_assetid].parts;
    }
}