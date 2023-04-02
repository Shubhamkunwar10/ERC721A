//SPDX-License-Identifier: UNLICENSED


pragma solidity ^0.8.16;

import "./TDR.sol";
import "./DRC.sol";
import "./DataTypes.sol";

 contract KdaCommon{
    
    address public owner;
    // Address of the contract admin
    address public admin;
    address manager;

    event Logger(string log);
    event LogAddress(string addressInfo, address _address);
    event LogBytes(string messgaeInfo, bytes32 _bytes);
    event LogBool(string messageInfo, bool message);
    event LogApplication(string message, TdrApplication application);
    
    

    constructor(address _admin,address _manager){
        owner=msg.sender;
        admin=_admin;
        manager=_manager;
        }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyAdmin() {
       require(
           msg.sender == admin || msg.sender == owner,
           "Only the admin or owner can perform this action."
       );
        _;
    }

    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Only the manager, admin, or owner can perform this action."
        );
        _;
    }
    function setOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }
    
    function setAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }
    
    function setManager(address _manager) public onlyAdmin {
        manager = _manager;
    }

        /**
* @dev returns the address of the contract admin.
     */
    function getAdmin() public view returns (address){
        return admin;
    }

    /**
     * @dev returns the address of the contract owner.
     */
    function getOwner() public view returns (address) {
        return owner;
    }

    /**
     * @dev returns the address of the TDR manager.
     */
    function getManager() public view returns (address) {
        return manager;
    }

}