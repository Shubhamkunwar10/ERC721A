// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;
/**
 * @title Nominee Contract
 * @dev Contract that allows the TDR manager to add, read, update, and delete nominees for users.
 * @author Ras Dwivedi
 * Date: 04/03/2023
 */
contract Nominee {
    mapping(bytes32 => bytes32[]) private userNominees;
    address owner;
    address admin;
    address manager;

    /**
    * @dev Constructor function to set the initial values of the contract.
     * @param _admin The address of the contract admin.
     * @param _manager The address of the TDR manager.
     */

    constructor(address _admin, address _manager) {
        // Set the contract owner to the caller
        owner = msg.sender;

        // Set the contract admin
        admin = _admin;
        manager = _manager;
    }
    /**
     * @dev Modifier to check if the caller is the TDR manager.
     */    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner of the contract");
        _;
    }
    /**
    * @dev Modifier to check if the caller is the contract admin.
    */
        modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the contract admin");
        _;
    }
    /**
    * @dev Modifier to check if the caller is the contract manager.
    */
    modifier onlyManager() {
        require(msg.sender == manager, "Caller is not the contract manager");
        _;
    }

    /**
    * @dev Updates the address of the contract admin. Can only be called by the owner
     * @param _newAdmin The new address of the contract admin.
     */
    function setAdmin(address _newAdmin) onlyOwner public{
        admin = _newAdmin;
    }

    /**
     * @dev Updates the address of the contract owner. Can only be called by the owner
     * @param _newOwner The new address of the contract owner.
     */
    function setOwner(address _newOwner) onlyOwner public {
        owner = _newOwner;
    }

    /**
     * @dev Updates the address of the TDR manager. Can only be called by the User manager.
     * @param _newManager The new address of the TDR manager.
     */
    function setManager(address _newManager) onlyOwner public {
        manager = _newManager;
    }

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
    function getNominees(bytes32 user) public view onlyManager returns (bytes32[] memory) {
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
    function findIndex(bytes32[] memory arr, bytes32 element) public pure returns(uint) {
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == element) {
                return i;
            }
        }
        return arr.length;
    }
}
