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

    function loadUserStorage(address _userStorageAddress) public onlyOwner{
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
        if(officer.designation == Designation.VC){
            userStorage.addOfficer(officer);
        } else {
        require(isOfficerUserManager(msg.sender),"Only VC can add user");
        userStorage.addOfficer(officer);
        }
    }
    function addVC(KdaOfficer memory officer) public {  
        require(isOfficerUserManager(msg.sender),"Only VC can add user");
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
        require(isOfficerUserManager(msg.sender),"Only VC can add user");
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
        require(isOfficerUserManager(msg.sender),"Only VC can add user");
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

    // User roles functions
    function isOfficerUserManager(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if( ifOfficerHasRole(officer,Role.USER_MANAGER)){
            return true;
        }
        return false;
    }

    function isOfficerKdaRegistrar(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if( ifOfficerHasRole(officer,Role.KDA_REGISTRAR)){
            return true;
        }
        return false;
    }
    // roles related to TDR notice and application
    function isOfficerNoticeManager(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if( ifOfficerHasRole(officer,Role.TDR_NOTICE_MANAGER)){
            return true;
        }
        return false;
    }
    
    function isOfficerTdrApplicationVerifier(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if(ifOfficerHasRole(officer,Role.TDR_APPLICATION_VERIFIER)){
            return true;
        }
        return false;
    }
    function isOfficerTdrApplicationSubVerifier(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if(ifOfficerHasRole(officer,Role.TDR_APPLICATION_SUB_VERIFIER)){
            return true;
        }
        return false;
    }
    function isOfficerTdrApplicationApprover(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
       if(ifOfficerHasRole(officer,Role.TDR_APPLICATION_APPROVER_CHIEF_TOWN_AND_COUNTRY_PLANNER)  ||
            ifOfficerHasRole(officer,Role.TDR_APPLICATION_APPROVER_DM) ||
            ifOfficerHasRole(officer,Role.TDR_APPLICATION_APPROVER_CHIEF_ENGINEER)) {
            return true;
        }
        return false;
    }
    function isOfficerDrcIssuer(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if( ifOfficerHasRole(officer,Role.DRC_ISSUER)){
            return true;
        }
        return false;
    }
    function isOfficerDtaVerifier(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if( ifOfficerHasRole(officer,Role.DTA_VERIFIER)) {
            return true;
        }
        return false;
    }

    function isOfficerDtaApprover(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if( ifOfficerHasRole(officer, Role.DTA_APPROVER)){
            return true;
        }
        return false;
    }

    function isOfficerDuaApprover(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if( ifOfficerHasRole(officer, Role.DUA_APPROVER)){
            return true;
        }
        return false;
    }

    function isOfficerDrcManager(address _address) view public returns(bool){
        KdaOfficer memory officer = getOfficerByAddress(_address);
        if( ifOfficerHasRole(officer,Role.DRC_MANAGER)){
            return true;
        }
        return false;
    }



    function getOfficerIdByAddress(address _address) view public returns(bytes32) {
        return userStorage.getOfficerIdByAddress(_address);
    }

    function ifOfficerHasRole(KdaOfficer memory officer, Role roleToCheck) public pure returns(bool){
        
        Role[] memory getAllRoles=officer.roles;

        for (uint256 i = 0; i < getAllRoles.length; i++) {
        if (getAllRoles[i] == roleToCheck) {
            return true; 
        }
    }    
    return false;
    }

}
