//SPDX-License-Identifier:MIT
pragma solidity >=0.4.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AssetTracking {
    using SafeMath for uint;

    // Struct for an asset
    struct Asset {
        string id;
        string name;
        address owner;
        string location;
        uint value;
    }

    // Mapping from asset ID to asset struct
    mapping (string => Asset) public assets;

    // Participants in the asset tracking system
    address public owner;
    address public manufacturer;
    address public distributor;
    address public retailer;

    // Function to add a new asset
    function addAsset(string memory id, string memory name, string memory location, uint value) public {
        // Check that the caller is the manufacturer
        require(msg.sender == manufacturer, "Only the manufacturer can add assets.");

        // Check that the asset does not already exist
        require(assets[id] == Asset(0, 0, 0, 0, 0), "Asset already exists.");

        // Add the asset
        assets[id] = Asset(id, name, manufacturer, location, value);

        // Emit the AssetAdded event
        emit AssetAdded(id, name, manufacturer, location, value);
    }

    // Function to update the location of an asset
   function updateLocation(string memory id, string memory location) public {
    // Check that the asset exists
    require(assets[id] != Asset(0, 0, 0, 0, 0), "Asset does not exist.");

    // Check that the caller is the owner or the current location of the asset
    require(msg.sender == assets[id].owner || msg.sender == assets[id].location, "Only the owner or the current location of the asset can update the location.");

    // Update the location of the asset
    assets[id].location = location;

    // Emit the LocationUpdated event
    emit LocationUpdated(id, location);
}
function transferOwnership(string memory id, address newOwner) public {
    // Check that the asset exists
    require(assets[id] != Asset(0, 0, 0, 0, 0), "Asset does not exist.");

    // Check that the caller is the current owner of the asset
    require(msg.sender == assets[id].owner, "Only the current owner of the asset can transfer ownership.");

    // Transfer ownership of the asset
    assets[id].owner = newOwner;

    // Emit the OwnershipTransferred event
    emit OwnershipTransferred(id, newOwner);
}
}