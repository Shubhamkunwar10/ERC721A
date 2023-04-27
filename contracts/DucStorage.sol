// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./DataTypes.sol";
//import "./lib/Counters.sol";
//import "./lib/SafeMath.sol";


//    using SafeMath for uint256;
//    using Counters for Counters.Counter;

// Define the struct that we will be using for our CRUD operations

contract DucStorage {
    mapping(bytes32 => DUC) private certMap;
    mapping(bytes32 => bytes32[]) public ownerMap; //ownerId => DucId
    mapping(bytes32 => bytes32[]) public applicationMap; //applicationId => DucId[]
    // An application can have multiple DUC

    event Logger(string log);
    event LogAddress(string addressInfo, address _address);
    event LogBytes(string messgaeInfo, bytes32 _bytes);
    event LogBool(string messageInfo, bool message);
    event LogApplication(string message, TdrApplication application);

    address owner;
    address admin;
    address manager;
    address tdrManager;

    // Constructor function to set the initial values of the contract
    constructor(address _admin, address _manager) {
        // Set the contract owner to the caller
        owner = msg.sender;

        // Set the contract admin
        admin = _admin;
        manager = _manager;
    }
    // Modifier to check if the caller is the TDR manager
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the TDR manager");
        _;
    }

    // Modifier to check if the caller is the contract admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the contract admin");
        _;
    }
    modifier onlyManager() {
        require(msg.sender == manager, "Caller is not the contract manager");
        _;
    }

    function setAdmin(address _newAdmin) onlyOwner public{
        admin = _newAdmin;
    }
    function setOwner(address _newOwner) onlyOwner public {
        owner = _newOwner;
    }
    function setManager(address _newManager) onlyOwner public {
        manager = _newManager;
    }



    function createDuc(
        bytes32 id,
        bytes32 applicationId,
        bytes32 noticeId,
        uint farPermitted,
        uint circleRateSurrendered,
        bytes32[] memory owners,
        uint timeStamp,
        uint _tdrConsumed,
        DrcUtilizationDetails memory _drcUtilizationDetails,
        LocationInfo memory _locationInfo) public {
        certMap[id] = DUC({
        id: id,
        applicationId: applicationId,
        noticeId: noticeId,
        farPermitted: farPermitted,
        circleRateSurrendered: circleRateSurrendered,
        owners: owners,
        timeStamp: timeStamp,
        tdrConsumed: _tdrConsumed,
        drcUtilizationDetails:_drcUtilizationDetails,
        locationInfo: _locationInfo
        });
    }
    event DucCreated(bytes32 ducId, DUC duc,bytes32[] ownerIds);
    event DucUpdated(bytes32 ducId, DUC duc, bytes32[] ownerIds);

    function createDuc(DUC memory _duc) public onlyManager{
        //check whether the DRC already exists
        require(!isDucCreated(_duc.id),"certificate already exists");
        addDucToOwners(_duc);
        storeDucInMap(_duc);
        emit DucCreated(_duc.id, _duc, _duc.owners);
    }
    function updateDuc(DUC memory _duc) public onlyManager{
        //check whether the DRC already exists
        require(isDucCreated(_duc.id),"certificate does not exists");
        addDucToOwners(_duc);
        storeDucInMap(_duc);
        emit DucUpdated(_duc.id, _duc, _duc.owners);
    }

    function getDuc(bytes32 id) public view returns (DUC memory) {
        return certMap[id];
    }

    function updateDuc(
        bytes32 id,
        bytes32 applicationId,
        bytes32 noticeId,
        uint farPermitted,
        uint circleRateSurrendered,
        bytes32[] memory owners,
        uint timeStamp,
        uint _tdrConsumed,
        DrcUtilizationDetails memory _drcUtilizationDetails,
        LocationInfo memory _locationInfo
    ) public {
        require(certMap[id].id == id, "Cert does not exist");
        certMap[id] = DUC({
        id: id,
        applicationId: applicationId,
        noticeId: noticeId,
        farPermitted: farPermitted,
        circleRateSurrendered: circleRateSurrendered,
        owners: owners,
        timeStamp: timeStamp,
        tdrConsumed: _tdrConsumed,
        drcUtilizationDetails:_drcUtilizationDetails,
        locationInfo: _locationInfo
        });
    }

    function deleteDuc(bytes32 id) public {
        require(certMap[id].id == id, "Cert does not exist");
        delete certMap[id];
    }

    function isDucCreated(bytes32 ducId) public returns (bool) {
        if(certMap[ducId].id !=""){
            return true;
        }
        return false;

    }

    function addDucToOwners(DUC memory duc) public {
        for (uint i=0; i< duc.owners.length; i++){
            addDucToOwner(duc.id,duc.owners[i]);
        }
    }
    function addDucToOwner(bytes32 ducId, bytes32 ownerId) public {
        bytes32[] storage ducList = ownerMap[ownerId];
        ducList.push(ducId);
        ownerMap[ownerId]=ducList;
    }
    function storeDucInMap (DUC memory _duc) internal {
        //        drcMap[_drc.id]=_drc;
        //
        DUC storage duc = certMap[_duc.id];
        //
        duc.id = _duc.id;
        duc.applicationId = _duc.applicationId;
        duc.noticeId = _duc.noticeId;
        duc.farPermitted = _duc.farPermitted;
        duc.circleRateSurrendered = _duc.circleRateSurrendered;
        duc.timeStamp = _duc.timeStamp;
        duc.tdrConsumed=_duc.tdrConsumed;
        duc.drcUtilizationDetails = _duc.drcUtilizationDetails;
        duc.locationInfo = _duc.locationInfo;
        delete duc.owners;
        for(uint i =0; i<_duc.owners.length; i++){
            duc.owners.push(_duc.owners[i]);
        }
        certMap[_duc.id]=duc;
        emit Logger("store DUC in map executed");
    }

    /**
    CRUD for owner map
    */

    event DucIdsAdded(bytes32 ownerId, bytes32[] ducList);
    function addDucIdsToOwner(bytes32[] memory ducList, bytes32 ownerId) public onlyManager{
        if(isOwnerInOwnerMap(ownerId)){
            revert("owner already exist, try updating list");
        }
        ownerMap[ownerId] = ducList;
        emit DucIdsAdded(ownerId, ducList);
    }

    event DucIdsUpdated(bytes32 ownerId, bytes32[] drcList);
    function updateDucIdsToOwner(bytes32[] memory ducList, bytes32 ownerId) public onlyManager{
        if(!isOwnerInOwnerMap(ownerId)){
            revert("owner does not exist, try creating list");
        }
        ownerMap[ownerId] = ducList;
        emit DucIdsUpdated(ownerId, ducList);
    }

    event DucIdsDeleted(bytes32 ownerId);
    /**
    Removes the owner from owner map, deleting all drcIds of owner in map
    WARNING: does not deletes owner from DRC, that has to be done separately
    */
    function deleteDucIdsOfOwner(bytes32 ownerId) public onlyManager{
        delete ownerMap[ownerId];
        emit DucIdsDeleted(ownerId);
    }
    function isOwnerInOwnerMap(bytes32 ownerId) public view returns(bool) {
        if(ownerMap[ownerId].length == 0) {
            return false;
        }
        return true;
    }
    function getDucIdsForUser(bytes32 userId) public view returns(bytes32[] memory) {
        return ownerMap[userId];
    }

    function addDucIdsToApplication(bytes32[] memory ducList, bytes32 applicationId) public onlyManager{
        if(isApplicationInApplicationMap(applicationId)){
            revert("owner already exist, try updating list");
        }
        applicationMap[applicationId] = ducList;
    }

    function updateDucIdsToApplication(bytes32[] memory ducList, bytes32 applicationId) public onlyManager{
        if(!isApplicationInApplicationMap(applicationId)){
            revert("owner does not exist, try creating list");
        }
        applicationMap[applicationId] = ducList;
    }

    /**
    Removes the owner from owner map, deleting all drcIds of owner in map
    WARNING: does not deletes owner from DRC, that has to be done separately
    */
    function deleteDucIdsOfApplication(bytes32 applicationId) public onlyManager{
        delete applicationMap[applicationId];
    }

    function getDucIdsForApplication(bytes32 applicationId) public view returns(bytes32[] memory) {
        return applicationMap[applicationId];
    }
    function isApplicationInApplicationMap(bytes32 applicationId) public view returns(bool) {
        if(applicationMap[applicationId].length == 0) {
            return false;
        }
        return true;
    }
    function addDucToApplication(bytes32 ducId,bytes32 applicationId) public {
        bytes32[] storage ducList = applicationMap[applicationId];
        ducList.push(applicationId);
        applicationMap[applicationId]=ducList;
    }

}
