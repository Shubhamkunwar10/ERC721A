//SPDX-License-Identifier: UNLICENSED

/**

UserManager contract is used to map user id to user address, and to manage verifier, approver and issuer addresses.
The contract owner and admin have the authority to update user, verifier, approver and issuer addresses.
*/
pragma solidity ^0.8.16;
import "./DataTypes.sol";
import "./KdaCommon.sol";
import "./UserStorage.sol";

contract UserManager is KdaCommon {

  // Constructor function to set the initial values of the contract
    constructor(address _admin,address _manager) KdaCommon(_admin,_manager) {}

    // Data layer
    UserStorage public userStorage;
    address public userStorageAddress;

    function loadUserStorage(address _userStorageAddress) public {
        userStorageAddress = _userStorageAddress;
        userStorage = UserStorage(userStorageAddress);
    }




    /**
     * @dev Function to add a user
 * @param userId 12 bit uint id of the user
 * @param userAddress address of the user
 */
    function addUser(bytes32 userId, address userAddress) public onlyManager {
        userStorage.addUser(userId,userAddress);
    }

/**
 * @dev Function to update a user
 * @param userId 12 bit uint id of the user
 * @param userAddress address of the user
 */
    function updateUser(bytes32 userId, address userAddress) public onlyManager {
        userStorage.updateUser(userId,userAddress);
    }


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

    function addOfficer(KdaOfficer memory officer) public {  
        KdaOfficer memory officerToSign =getOfficerByAddress(msg.sender);
        if (userStorage.ifOfficerHasRole(officer,Role.ADMIN)) {
            // this should be admin, and not manager
            require(msg.sender == manager, "Only contract admin can add  admin"); // only admin can add  user
        } else {
            require(userStorage.ifOfficerHasRole(officerToSign,Role.ADMIN), "Only  Admin can add officers");
        }

        userStorage.addOfficer(officer);
    }

    /**
     * Updates an existing Officer in the mapping of KdaOfficers.
     * @param officer The Officer to update in the mapping.
     * @dev The method will only allow an Admin to update an existing Officer. If the Officer does not exist in the
     * mapping, the method will revert with an error message. If the Officer is updated successfully, the method will
     * emit the OfficerUpdated event.
     */
    function updateOfficer (KdaOfficer memory officer) public {
        KdaOfficer memory officerToSign =getOfficerByAddress(msg.sender);
        if (userStorage.ifOfficerHasRole(officer,Role.ADMIN)) {
            // this should be admin, and not manager
            require(msg.sender == manager, "Only contract admin can add  admin"); // only admin can add ADMIN
        } else {
            require(userStorage.ifOfficerHasRole(officerToSign,Role.ADMIN), "Only admin can update officers");
        }

        userStorage.updateOfficer(officer);
    }

    /**
     * Deletes an Officer from the mapping of KdaOfficers.
     * @param id The ID of the Officer to delete from the mapping.
     * @dev The method will only allow an Admin to delete an existing Officer. If the Officer does not exist in the
     * mapping, the method will revert with an error message. If the Officer is deleted successfully, the method will
     * emit the OfficerDeleted event.
     */
    function deleteOfficer(bytes32 id) public {
        KdaOfficer memory officerToSign =getOfficerByAddress(msg.sender);
        require(userStorage.ifOfficerHasRole(officerToSign,Role.ADMIN), "Only admin can delete officers");
        userStorage.deleteOfficer(id);
    }

    function isAdmin(address _address) public view returns (bool) {
        return admin == _address;
    }

    // This method would @return empty address in case address is not found
    function getUserId (address _address) public view returns (bytes32){
        return userStorage.getUserId(_address);
    }

    function getOfficer(bytes32 id) view public returns(KdaOfficer memory){
        return userStorage.getOfficer(id);
    }
    function getRoles(bytes32 id) view public returns(Role[] memory){
        return userStorage.getRoles(id);
    }
    function getOfficerByAddress(address _address) view public returns(KdaOfficer memory){
        return userStorage.getOfficerByAddress(_address);
    }

    function isOfficerTDRSubVerifier(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if(userStorage.ifOfficerHasRole(officer,Role.SUB_VERIFIER)) {
            return true;
        }
    return false;
    }

    function isOfficerTDRVerifier(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if(userStorage.ifOfficerHasRole(officer,Role.CHIEF_TOWN_AND_COUNTRY_PLANNER)  ||
            userStorage.ifOfficerHasRole(officer,Role.VC) ||
            userStorage.ifOfficerHasRole(officer,Role.VERIFIER)) {
            return true;
        }
        return false;
    }
    function isOfficerTdrApprover(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
       if(userStorage.ifOfficerHasRole(officer,Role.CHIEF_TOWN_AND_COUNTRY_PLANNER)  ||
            userStorage.ifOfficerHasRole(officer,Role.DM) ||
            userStorage.ifOfficerHasRole(officer,Role.ENGINEER)) {
            return true;
        }
        return false;
    }
    function isOfficerDrcIssuer(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if( userStorage.ifOfficerHasRole(officer,Role.VC)){
            return true;
        }
        return false;
    }
    function isOfficerDtaVerifier(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if( userStorage.ifOfficerHasRole(officer,Role.ADMIN) ||
             userStorage.ifOfficerHasRole(officer,Role.VC)) {
            return true;
        }
        return false;
    }
    function isOfficerDtaApprover(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if( userStorage.ifOfficerHasRole(officer,Role.VC)||
             userStorage.ifOfficerHasRole(officer,Role.APPROVER)){
            return true;
        }
        return false;
    }
    function isOfficerNoticeCreator(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
     if( userStorage.ifOfficerHasRole(officer,Role.ADMIN) ||
             userStorage.ifOfficerHasRole(officer,Role.VC)){
            return true;
        }
        return false;
    }

}
