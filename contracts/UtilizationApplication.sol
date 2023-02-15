// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./DRC.sol";
import "./UserManager.sol";

contract DuaStorage {



    mapping(bytes32 => DUA) public applicationMap;
    mapping(bytes32 => bytes32[] ) public userApplicationMap;

    event DUACreatedForUser(bytes32 userId, bytes32 applicationId);
    //logger events
    event LogAddress(string addressInfo, address _address);
    event LogBytes(string messgaeInfo, bytes32 _bytes);
    event LogBool(string messageInfo, bool message);
    event LogApplication(string message, TdrApplication application);
    event DTACreatedForUser(bytes32 userId, bytes32 applicationId);

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

    function createApplication(DUA memory dta) public onlyAdmin{
        require(applicationMap[dta.applicationId].applicationId =="","application already exist");
        storeApplicationInMap(dta);
        storeApplicationForUser(dta);
    }

    function createApplication(bytes32 _id, bytes32 _drcId, uint _farTransferred, Signatory[] memory _signatories, ApplicationStatus _status) public onlyManager{
        require(applicationMap[_id].applicationId =="","application already exist");
        storeApplicationInMap(DUA(_id, _drcId, _farTransferred, _signatories, _status));
    }

    function updateApplication(DUA memory dta) public onlyAdmin{
        require(applicationMap[dta.applicationId].applicationId !="","application does not exist");
        storeApplicationInMap(dta);

    }

    function updateApplication(bytes32 _id, bytes32 _drcId, uint _farTransferred, Signatory[] memory _signatories, ApplicationStatus _status) public onlyManager{
        require(applicationMap[_id].applicationId !="","application does not exist");
        storeApplicationInMap(DUA(_id, _drcId, _farTransferred, _signatories, _status));
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
    function storeApplicationInMap (DUA memory _dta) internal {
        DUA storage dta = applicationMap[_dta.applicationId];
        
        dta.applicationId = _dta.applicationId;
        dta.drcId = _dta.drcId;
        dta.farUtilized = _dta.farUtilized;
        dta.status = _dta.status;
        for (uint i =0; i< _dta.signatories.length; i++){
            dta.signatories[i]=_dta.signatories[i];
        }


        applicationMap[dta.applicationId]=dta;
    }
    function getApplicationForUser(bytes32 userId) public onlyManager returns (bytes32[] memory){
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
