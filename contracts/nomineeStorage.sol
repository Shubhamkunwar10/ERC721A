// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
/**
 * @title Nominee Contract
 * @dev Contract that allows the TDR manager to add, read, update, and delete nominees for users.
 * @author Ras Dwivedi
 * Date: 04/03/2023
 */
import "./DataTypes.sol";
import "./KdaCommon.sol";

contract NomineeStorage is KdaCommon  {
    mapping(bytes32 => bytes32[]) private userNominees;
    mapping(bytes32 => nomineeApplication) public nomineeApplicationMap;

    event LogOfficer(string message, KdaOfficer officer);


   // Constructor function to set the initial values of the contract
    constructor(address _admin,address _manager) KdaCommon(_admin,_manager) {}


    // Events emitted when nominee operation is made
    event nomineesAdded(bytes32 user);
    event nomineesUpdated(bytes32 user);
    event nomineesDeleted(bytes32 user);

    /**
    * @dev Adds nominees to the mapping for a particular user
    * @param user The user for whom the nominees are being added
    * @param nominees The array of nominees being added for the user
    */
    function addNominee(bytes32 user, bytes32[] memory nominees) public onlyManager {
        userNominees[user] = nominees;
        emit nomineesAdded(user);
    }

    /**
     * @dev Returns the list of nominees for a particular user
     * @param user The user for whom the nominees are being retrieved
     * @return The array of nominees for the user
     */
    function getNominees(bytes32 user) public onlyManager view returns (bytes32[] memory) {
        return userNominees[user];
    }

    /**
     * @dev Updates a nominee list for a particular user
     * @param user The user for whom the nominee is being updated
     * @param newNominees The new nominee that is being updated
     */
    function updateNominee(bytes32 user, bytes32[] memory newNominees) public onlyManager {
        userNominees[user] = newNominees;
        emit nomineesUpdated(user);
    }

    /**
     * @dev Deletes a nominee for a particular user
     * @param user The user for whom the nominee is being deleted
     * @param nominee The nominee being deleted
     */
    function deleteNominee(bytes32 user, bytes32 nominee) public onlyManager {
        bytes32[] storage nominees = userNominees[user];
        uint index = findIndex(nominees, nominee);
        if (index == nominees.length){
            revert("nominee not found");
        }
        for (uint i=index; i< nominees.length; i++){
            nominees[i]= nominees[i+1];
        }
        nominees.pop();
        userNominees[user]= nominees;
    }
    function findIndex(bytes32[] memory arr, bytes32 element) internal pure returns(uint) {
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == element) {
                return i;
            }
        }
        return arr.length;
    }
    event nomineeApplicationAdded(bytes32 applicationId, bytes32 userId);
    event nomineeApplicationUpdated(bytes32 applicationId, bytes32 userId);
    event nomineeApplicationDeleted(bytes32 applicationId, bytes32 userId);

    function createNomineeApplication(nomineeApplication memory application) onlyManager public {
        // check whether the application exists or not
        if(isApplicationCreated(application.applicationId)){
            revert("application already created");
        }
        nomineeApplicationMap[application.applicationId] = application;
        emit nomineeApplicationAdded(application.applicationId, application.userId);
    }
    
    function updateNomineeApplication(nomineeApplication memory application) onlyManager public {
        // check whether the application exists or not
        if(!isApplicationCreated(application.applicationId)){
            revert("application does not exists");
        }
        nomineeApplicationMap[application.applicationId] = application;
        emit nomineeApplicationUpdated(application.applicationId, application.userId);
    }
    function deleteNomineeApplication(nomineeApplication memory application) onlyManager public {
        // check whether the application exists or not
        if(!isApplicationCreated(application.applicationId)){
            revert("application does not exist");
        }
        delete nomineeApplicationMap[application.applicationId];
        emit nomineeApplicationDeleted(application.applicationId, application.userId);
    }
    function getNomineeApplication(bytes32 applicationId) public view returns (nomineeApplication memory) {
        return nomineeApplicationMap[applicationId];
    }
    function isApplicationCreated(bytes32 _applicationId) public view returns (bool) {
        nomineeApplication memory application = nomineeApplicationMap[_applicationId];
        if (application.applicationId==""){
            return false;
        }
        return true;
    }
}
