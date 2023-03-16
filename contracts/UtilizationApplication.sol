// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./DRC.sol";
import "./UserManager.sol";

contract DuaStorage {



    mapping(bytes32 => DUA) public applicationMap;
    mapping(bytes32 => bytes32[] ) public userApplicationMap;

    //logger events
    event LogAddress(string addressInfo, address _address);
    event LogBytes(string messgaeInfo, bytes32 _bytes);
    event LogBool(string messageInfo, bool message);
    event LogApplication(string message, TdrApplication application);
    event DUACreatedForUser(bytes32 userId, bytes32 applicationId);
    event DUACreated(bytes32 applicationId);
    event DUAUpdated(bytes32 applicationId);

    address owner;
    address admin;
    address manager;

    // Constructor function to set the initial values of the contract
    constructor(address _admin, address _manager) {
        // Set the contract owner to the caller
        owner = msg.sender;

        // Set the contract admin
        admin = _admin;
        manager = _manager;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin || msg.sender == owner, "Only the admin or owner can perform this action.");
        _;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager, admin, or owner can perform this action.");
        _;
    }

    function setAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function setManager(address _manager) public {
        require (msg.sender == owner ||  msg.sender == admin);
        manager = _manager;
    }
    function setOwner(address _newOwner) onlyOwner public {
        owner = _newOwner;
    }

    function createApplication(DUA memory dua) public onlyManager{
        require(applicationMap[dua.applicationId].applicationId =="","application already exist");
        storeApplicationInMap(dua);
        storeApplicationForUser(dua);
        emit DUACreated(dua.applicationId);
    }

    function createApplication(bytes32 _applicationId, bytes32 _drcId, uint _farTransferred, Signatory[] memory _signatories, uint _timeStamp, ApplicationStatus _status) public onlyManager{
        require(applicationMap[_applicationId].applicationId =="","application already exist");
        storeApplicationInMap(DUA(_applicationId, _drcId, _farTransferred, _signatories, _status, _timeStamp));
        storeApplicationForUser(DUA(_applicationId, _drcId, _farTransferred, _signatories,_status,  _timeStamp));
        emit DUACreated(_applicationId);
    }

    function updateApplication(DUA memory dua) public onlyManager{
        require(applicationMap[dua.applicationId].applicationId !="","application does not exist");
        storeApplicationInMap(dua);
        emit DUAUpdated(dua.applicationId);
    }

    function updateApplication(bytes32 _applicationId, bytes32 _drcId, uint _farTransferred, Signatory[] memory _signatories, uint _timeStamp, ApplicationStatus _status) public onlyManager{
        require(applicationMap[_applicationId].applicationId !="","application does not exist");
        storeApplicationInMap(DUA(_applicationId, _drcId, _farTransferred, _signatories,_status, _timeStamp));
        emit DUAUpdated(_applicationId);

    }

    function getApplication(bytes32 _id) view public returns(DUA memory){
       require(applicationMap[_id].applicationId !="","application does not exist");
       return applicationMap[_id];
    }

    function deleteApplication(bytes32 _id) public onlyManager {
        require(msg.sender == admin, "Only the admin can delete applications.");
        delete applicationMap[_id];
    }
    // This function just creates a new appliction in the mapping based on the applicaiton in the memory
    function storeApplicationInMap (DUA memory _dua) internal {
        DUA storage dua = applicationMap[_dua.applicationId];
        
        dua.applicationId = _dua.applicationId;
        dua.drcId = _dua.drcId;
        dua.farUtilized = _dua.farUtilized;
        dua.status = _dua.status;
        dua.timeStamp = _dua.timeStamp;
        delete dua.signatories;
        for (uint i =0; i< _dua.signatories.length; i++){
            dua.signatories.push(_dua.signatories[i]);
        }


        applicationMap[dua.applicationId]= dua;
    }
    function getApplicationForUser(bytes32 userId) public view onlyManager returns (bytes32[] memory){
        return userApplicationMap[userId];
    }
    function storeApplicationForUser(DUA memory application) public onlyManager {
        for(uint i=0; i<application.signatories.length; i++){
            bytes32 userId = application.signatories[i].userId;
            bytes32[] storage applicationIds = userApplicationMap[userId];
            applicationIds.push(application.applicationId);
            userApplicationMap[userId]=applicationIds;
            emit DUACreatedForUser(application.signatories[i].userId,application.applicationId);
        }
    }
}
