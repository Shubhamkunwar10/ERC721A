// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./DRC.sol";
import "./UserManager.sol";
import "./DataTypes.sol";

contract DrcTransferApplicationStorage {
    // enum ApplicationStatus {pending, submitted, approved, rejected}


    mapping(bytes32 => DrcTransferApplication) public applicationMap;
    mapping(bytes32 => bytes32[] ) public userApplicationMap;
    mapping(bytes32 => VerificationStatus) public verificationStatusMap;



    address owner;
    address admin;
    address manager;
    //events
    event LogAddress(string addressInfo, address _address);
    event LogBytes(string messgaeInfo, bytes32 _bytes);
    event LogBool(string messageInfo, bool message);
    event LogApplication(string message, TdrApplication application);
    event DTACreatedForUser(bytes32 userId, bytes32 applicationId);



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

    function createApplication(DrcTransferApplication memory dta) public onlyManager{
        require(applicationMap[dta.applicationId].applicationId=="","application already exist");
        storeApplicationInMap(dta);
        storeApplicationForUser(dta);
    }

    function createApplication(bytes32 _id, bytes32 _drcId, uint _farTransferred, Signatory[] memory _signatories, DrcOwner[] memory _newDrcOwner, ApplicationStatus _status) public onlyManager{
        require(applicationMap[_id].applicationId =="","application already exist");
        storeApplicationInMap(DrcTransferApplication(_id, _drcId, _farTransferred, _signatories, _newDrcOwner, _status));
    }

    function updateApplication(DrcTransferApplication memory dta) public onlyManager{
        require(applicationMap[dta.applicationId].applicationId !="","application does not exist");
        storeApplicationInMap(dta);

    }

    function updateApplication(bytes32 _id, bytes32 _drcId, uint _farTransferred, Signatory[] memory _signatories, DrcOwner[] memory _newDrcOwner, ApplicationStatus _status) public onlyManager{
        require(applicationMap[_id].applicationId !="","application does not exist");
        storeApplicationInMap(DrcTransferApplication(_id, _drcId, _farTransferred, _signatories, _newDrcOwner, _status));
    }

    function getApplication(bytes32 _id) view public returns(DrcTransferApplication memory){
       require(applicationMap[_id].applicationId !="","application does not exist");
       return applicationMap[_id];
    }

    function deleteApplication(bytes32 _id) public onlyManager {
        require(msg.sender == admin, "Only the admin can delete applications.");
        delete applicationMap[_id];
    }
    // This function just creates a new appliction in the mapping based on the applicaiton in the memory
    function storeApplicationInMap (DrcTransferApplication memory _dta) internal {
        DrcTransferApplication storage dta = applicationMap[_dta.applicationId];
        
        dta.applicationId = _dta.applicationId;
        dta.drcId = _dta.drcId;
        dta.farTransferred = _dta.farTransferred;
        dta.status = _dta.status;
        for (uint i =0; i< _dta.signatories.length; i++){
            dta.signatories[i]=_dta.signatories[i];
        }
        for (uint i =0; i< _dta.newDrcOwner.length; i++){
            dta.newDrcOwner[i]=_dta.newDrcOwner[i];
        }

        applicationMap[dta.applicationId]=dta;
    }


    function storeVerificationStatus(bytes32 id, VerificationStatus memory status) public {
        verificationStatusMap[id] = status;
    }
    function getVerificationStatus(bytes32 applicationId) public view returns(VerificationStatus memory) {
        return verificationStatusMap[applicationId];
    }
    function getApplicationForUser(bytes32 userId) public onlyManager returns (bytes32[] memory){
        return userApplicationMap[userId];
    }
    function storeApplicationForUser(DrcTransferApplication memory application) public onlyManager {
        for(uint i=0; i<application.signatories.length; i++){
            bytes32 userId = application.signatories[i].userId;
            bytes32[] storage applicationIds = userApplicationMap[userId];
            applicationIds.push(application.applicationId);
            userApplicationMap[userId]=applicationIds;
            emit DTACreatedForUser(application.signatories[i].userId,application.applicationId);
        }
    }
}
