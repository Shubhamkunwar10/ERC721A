// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.16;
// contract UserRegistry {
//     // mapping of user names to addresses
//     mapping(string => address) public users;

//     // address of the contract owner (admin)
//     address public owner;

//     // constructor function to set the contract owner
//     constructor() public {
//         owner = msg.sender;
//     }

//     // add a new user to the registry
//     function addUser(string memory name) public {
//         // only the contract owner can add new users
//         require(msg.sender == owner, "Only the contract owner can add new users.");
//         // add the user to the mapping
//         users[name] = msg.sender;
//     }

//     // update the address of a user by name
//     function updateUser(string memory name, address newAddress) public {
//         // only the contract owner can update user addresses
//         require(msg.sender == owner, "Only the contract owner can update user addresses.");
//         // update the user's address in the mapping
//         users[name] = newAddress;
//     }

//     // retrieve the address of a user by name
//     function getUser(string memory name) public view returns (address) {
//         return users[name];
//     }
// }
