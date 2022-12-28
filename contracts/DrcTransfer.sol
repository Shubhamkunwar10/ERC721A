pragma solidity ^0.6.0;

contract DrcHandler {
    // Define the struct that represents a piece of land
    struct Land {
        address owner;
        bool isForSale;
        uint price;
        bool hasDevelopmentRights;
        bool isUnderConstruction;
    }

    // Create a mapping to store the land parcels
    mapping(uint => Land) public lands;


    // Create a counter to generate unique IDs for the land parcels
    uint public landCount = 0;

    // Create an event to be emitted when a land parcel is bought
    event LandBought(uint indexed landId, address indexed buyer);

    // Create an event to be emitted when a land parcel's development rights are transferred
    event DevelopmentRightsTransferred(uint indexed landId, address indexed from, address indexed to);

    // Create a function to add a new land parcel to the mapping
    function createLand(bool _isForSale, uint _price) public {
        // Increment the counter to get the next unique ID
        landCount++;

        // Create a new land parcel with the provided sale status and price, and the next unique ID
        Land memory newLand = Land(msg.sender, _isForSale, _price, false, false);

        // Add the new land parcel to the mapping
        lands[landCount] = newLand;
    }

    // Create a function to buy a land parcel
    function buyLand(uint _id) public payable {
        // Retrieve the land parcel from the mapping
        Land memory land = lands[_id];

        // Check that the land parcel is for sale
        require(land.isForSale, "This land parcel is not for sale.");

        // Check that the sender has enough balance to buy the land
        require(msg.value >= land.price, "You do not have enough balance to buy this land.");

        // Transfer the ownership of the land to the sender
        land.owner = msg.sender;
        land.isForSale = false;

        // Update the land parcel in the mapping
        lands[_id] = land;

        // Emit the LandBought event
        emit LandBought(_id, msg.sender);
    }

    // Create a function to transfer the development rights of a land parcel
    function transferDevelopmentRights(uint _id, address _to) public {
        // Retrieve the land parcel from the mapping
        Land memory land = lands[_id];

        // Check that the sender is the owner of the land
        require(land.owner == msg.sender, "You are not the owner of this land.");

        // Check that the land has development rights
        require(land.hasDevelopmentRights, "This land does not have development rights.");

        // Transfer the development rights to the specified address
        land.hasDevelopmentRights = false;
        land.isUnderConstruction = false;
        land.owner = _to;

        // Update the land parcel in the mapping
        lands[_id] = land;

        // Emit the DevelopmentRightsTransferred event
        emit DevelopmentRightsTransferred(_id, msg.sender, _to);
    }

    // Create a function
/* List of the functions needed
1. change the owner of the drc handler
2. add nominee contract
3. replace the user with the nominee in the DRC
4. Apply drc
5. vcerifiy drc gen application
6. approve drc
7. issue drc
8. apply transfer drc
9. apply utlilization drc
10. approve trs/utilization
11. admin actions
    terminate DRC
    change owner
    change area
    change
12 change the accout id with the address
