// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract DrcCrud {
    // Define the struct that we will be using for our CRUD operations
    enum Status {applied, approved, issued, locked_for_transfer, locked_for_utilization, transferred, utilized}
    struct User {
        uint id;
        Status status;
        uint availableArea;
        uint khasraNo;
        string village;
        string ward;
        string scheme;
        string plotNo;
        string tehsil;
        string district;
        string landUse; // It could be enum
        uint areaSurrendered;
        uint circleRateSurrendered;
        uint circleRateUtilization;
        uint FarCredited;
        SubDrc[] SubDrc; 


        uint age;
        uint area;
        string issueDate;
        SubDrc[] subdrc;
    }
    struct Owner{
        string name;
        string ownerId;
    }
    struct SubDrc{
        string sNo;
        uint area;
        string status;
        Owner[] owners;
    }

    // Create a mapping to store the users
    mapping(uint => User) public users;

    // Create a counter to generate unique IDs for our users
    uint public userCount = 0;

    // Create a function to add a new user to the mapping
    function createUser(string memory _name, uint _age) public {
        // Increment the counter to get the next unique ID
        userCount++;

        // Create a new user with the provided name and age, and the next unique ID
        User memory newUser = User(userCount, _name, _age);

        // Add the new user to the mapping
        users[userCount] = newUser;
    }

    // Create a function to retrieve a user from the mapping by ID
    function readUser(uint _id) public view returns (uint, string memory, uint) {
        // Retrieve the user from the mapping
        User memory user = users[_id];

        // Return the user's ID, name, and age
        return (user.id, user.name, user.age);
    }

    // Create a function to update a user in the mapping
    function updateUser(uint _id, string memory _name, uint _age) public {
        // Retrieve the user from the mapping
        User memory user = users[_id];

        // Update the user's name and age
        user.name = _name;
        user.age = _age;

        // Update the user in the mapping
        users[_id] = user;
    }

    // Create a function to delete a user from the mapping
    function deleteUser(uint _id) public {
        // Delete the user from the mapping
        delete users[_id];
    }

    //todo
    /*
    1. ensure that there is an owner and method to transfer and owner
    2. ensure that there is a method to update the drc such that all field might not be required,
     or you can extracst the drc and then update all the fields. 
     Since the drc would be stored in a map, it means that internally also, i have to update everything in one go, 
     unless I can store drc in a nested map like structure, and then update only the least feasible branch. Why would I do that?
    */
}

