//SPDX-License-Identifier: UNLICENSED

/**

UserManager contract is used to map user id to user address, and to manage verifier, approver and issuer addresses.
The contract owner and admin have the authority to update user, verifier, approver and issuer addresses.
*/
pragma solidity ^0.8.16;
import "./DataTypes.sol";
import "./KdaCommon.sol";


contract UserStorage is KdaCommon {
    // Mapping from user id to user address
    mapping(bytes32 => address) public userMap; // id => address
    mapping(address => bytes32) public reverseUserMap; //address => id

    // List of verifier addresses
    mapping(bytes32 => KdaOfficer) public officerMap; // id => officer Struct
    mapping(bytes32 => address) public officerAddressMap; // id => address
    mapping(address => bytes32) public reverseOfficerMap; // address => id


    // Event emitted after a user is updated
    event UserAdded(bytes32 userId, address userAddress);
    // Event emitted after a user is updated
    event UserUpdated(bytes32 userId, address userAddress);
    event UserDeleted(bytes32 userId, address userAddress);

    // Event emitted after a officer is added
    event OfficerAdded(bytes32 officerId, address officerAddress);
    // Event emitted after a officer is updated
    event OfficerUpdated(bytes32 officerId, address officerAddress);
    // Event emitted after a officer is deleted
    event OfficerDeleted(bytes32 officerId);

    // Constructor function to set the initial values of the contract
    constructor(address _admin,address _manager) KdaCommon(_admin,_manager) {}


    // CRUD operation on user

    /**
     * @dev Function to add a user
 * @param userId 12 bit uint id of the user
 * @param userAddress address of the user
 */
    function addUser(bytes32 userId, address userAddress) public onlyManager {
        // check is user already does not exist
        if(userMap[userId]!=address(0)){
            revert("User already exists, instead try updating the address");
        }
        // Update the user in the mapping
        userMap[userId] = userAddress;
        reverseUserMap[userAddress]=userId;

        // Emit the UserAdded event
        emit UserAdded(userId, userAddress);
    }

    /**
     * @dev Function to update a user
 * @param userId 12 bit uint id of the user
 * @param userAddress address of the user
 */
    function updateUser(bytes32 userId, address userAddress) public onlyManager {
        // check if user already exists
        if(userMap[userId]==address(0)){
            revert("user does not exist");
        }

        // Update the user in the mapping
        userMap[userId] = userAddress;
        reverseUserMap[userAddress]=userId;

        // Emit the UserUpdated event
        emit UserUpdated(userId, userAddress);
    }

    /**
     * @dev Function to update a user
 * @param userId 12 bit uint id of the user
 * @param userAddress address of the user
 */
    function deleteUser(bytes32 userId, address userAddress) public onlyManager {
        // check if user already exists
        if(userMap[userId]==address(0)){
            revert("user does not exist");
        }

        // Update the user in the mapping
        userMap[userId] = address(0);
        reverseUserMap[userAddress]="";


        // Emit the UserUpdated event
        emit UserDeleted(userId, userAddress);
    }
    /**
    get userId from address
    */
    // This method would @return empty address in case address is not found
    function getUserId (address _address) public view returns (bytes32){
        return reverseUserMap[_address];
    }
    /**
    get user address from user Id
    */
    function getUserAddress(bytes32 userId) public view returns (address){
        return userMap[userId];
    }


    //CRUD operation on KDA officer

    /**
     * Adds a new Officer to the mapping of KdaOfficers.
     * @param officer The Officer to add to the mapping.
     * @dev The method will only allow an Admin to add a new Officer.
     * If the Officer already exists in the mapping,address
     * the method will revert with an error message. If the Officer is added successfully, the method will emit
     * the OfficerAdded event.
     */
    /**
   officer.role == Role.Admin, msg.sender should have role superAdmin, else msg.sender should have
    */
    function addOfficer (KdaOfficer memory officer) public onlyManager {
        address officerAddress = userMap[officer.userId];
        if(officerAddress == address(0)){
            revert("Officer account not created");
        }
        // check role of the user should be admin only if not manager

        // check is user already does not exist
        if(officerAddressMap[officer.userId]!=address(0)){
            revert("Officer already exist, instead try updating the address");
        }
        // Update the verifier in the mapping
        officerMap[officer.userId] = officer;
        officerAddressMap[officer.userId]=officerAddress;
        reverseOfficerMap[officerAddress]=officer.userId;


        // Emit the verifierAdded event
        emit OfficerAdded(officer.userId, officerAddress);
    }

/**
 * Updates an existing Officer in the mapping of KdaOfficers.
 * @param officer The Officer to update in the mapping.
     * @dev The method will only allow an Admin to update an existing Officer. If the Officer does not exist in the
     * mapping, the method will revert with an error message. If the Officer is updated successfully, the method will
     * emit the OfficerUpdated event.
     */
    function updateOfficer (KdaOfficer memory officer) public onlyManager {
        address officerAddress = userMap[officer.userId];
        // check role of the user should be admin only

        // check is user already does not exist
        if(officerAddressMap[officer.userId]==address(0)){
            revert("Officer does not exist, instead try adding the address");
        }
        // Update the verifier in the mapping
        officerMap[officer.userId] = officer;
        officerAddressMap[officer.userId]=officerAddress;
        reverseOfficerMap[officerAddress]=officer.userId;


        // Emit the verifierAdded event
        emit OfficerUpdated(officer.userId, officerAddress);
    }

/**
 * Deletes an Officer from the mapping of KdaOfficers.
 * @param id The ID of the Officer to delete from the mapping.
     * @dev The method will only allow an Admin to delete an existing Officer. If the Officer does not exist in the
     * mapping, the method will revert with an error message. If the Officer is deleted successfully, the method will
     * emit the OfficerDeleted event.
     */
    function deleteOfficer(bytes32 id) public onlyManager{
        // check if verifier already exists
        if(officerAddressMap[id]==address(0)){
            revert("officer does not exist");
        }
        // Delete the verifier in the mapping
        address _address = officerAddressMap[id];
        delete(officerMap[id]);
        delete(officerAddressMap[id]);
        delete(reverseOfficerMap[_address]);

        // Emit the verifierUpdated event
        emit OfficerDeleted(id);
    }


    function getOfficer(bytes32 id) view public returns(KdaOfficer memory){
        return officerMap[id];
    }
    function getRoles(bytes32 id) view public returns(Role[] memory){
        return officerMap[id].roles;
    }
    function getOfficerAddress(bytes32 id) view public returns(address ){
        return officerAddressMap[id];
    }
    function getOfficerByAddress(address _address) view public returns(KdaOfficer memory){
        bytes32 id = reverseOfficerMap[_address];
        return officerMap[id];
    }
    function getRolesByAddress(address _address) view public returns(Role[] memory){
        bytes32 id = reverseOfficerMap[_address];
        return officerMap[id].roles;
    }
    function getOfficerIdByAddress(address _address) view public returns(bytes32){
        return reverseOfficerMap[_address];
    }

    function isAdmin(address _address) public view returns (bool) {
        return admin == _address;
    }

    function ifOfficerHasRoles(Role roleToCheck) public view returns(bool){
        Role[] memory getAllRoles=getRolesByAddress(msg.sender);

        for (uint256 i = 0; i < getAllRoles.length; i++) {
        if (getAllRoles[i] == roleToCheck) {
            return true; 
        }
    }    
    return false;
    }

    function ifOfficerHasRole(KdaOfficer memory officer, Role roleToCheck) public view returns(bool) {

    }


}
