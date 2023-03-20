// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./DataTypes.sol";
//import "./lib/Counters.sol";
//import "./lib/SafeMath.sol";


//    using SafeMath for uint256;
//    using Counters for Counters.Counter;

// Define the struct that we will be using for our CRUD operations

contract DUCStorage {
    mapping(bytes32 => DUC) private certMap;
    mapping(bytes32 => bytes32[]) public ownerMap; //ownerId => DucId
    mapping(bytes32 => bytes32[]) public applicationMap; //applicationId => DucId[]
    // An application can have multiple DUC

    // Create a function to add a new Drc to the mapping
    function createDrc(DRC memory _drc) public onlyDrcCreator{
        //check whether the DRC already exists
        require(!isDrcCreated(_drc.id),"DRC already exists");
        addDrcToOwners(_drc);
        storeDrcInMap(_drc);
        emit DrcCreated(_drc.id, _drc.owners);
    }
    // Create a function to update a Drc in the mapping
    function updateDrc(bytes32 _id, DRC memory _drc) public onlyManager {
        // the drc should exist
        // Update the Drc in the mapping
        require(_id ==_drc.id, "drcid should be same");
        require(isDrcCreated(_drc.id),"DRC does not exists");
        // insertDrc((_drc));
        storeDrcInMap(_drc);
    }

    // Create a function to retrieve a Drc from the mapping by ID
    function getDrc(bytes32 _id) public view returns (DRC memory) {
        // Retrieve the Drc from the mapping
        DRC memory drc = drcMap[_id];

        // Return the Drc's ID, name, and age
        return drc;
    }



    // Create a function to delete a Drc from the mapping
    function deleteDrc(bytes32 _id) public onlyOwner{
        // Delete the Drc from the mapping
        delete drcMap[_id];
    }
//############################333
    function createCert(
        bytes32 id,
        bytes32 applicationId,
        bytes32 noticeId,
        uint farUtilized,
        uint circleRateSurrendered,
        uint circleRateUtilization,
        bytes32[] memory owners,
        uint timeStamp
    ) public {
        certMap[id] = DrcUtilizationCert({
        id: id,
        applicationId: applicationId,
        noticeId: noticeId,
        farUtilized: farUtilized,
        circleRateSurrendered: circleRateSurrendered,
        circleRateUtilization: circleRateUtilization,
        owners: owners,
        timeStamp: timeStamp
        });
    }
    event DucCreated(bytes32 ducId, bytes32[] ownerIds);
    event DucUpdated(bytes32 ducId, bytes32[] ownerIds);

    function createDrc(DUC memory _duc) public onlyDrcCreator{
        //check whether the DRC already exists
        require(!isDucCreated(_duc.id),"certificate already exists");
        addDrcToOwners(_drc);
        storeDucInMap(_drc);
        emit DucCreated(_drc.id, _drc.owners);
    }
    function updateDuc(DUC memory _duc) public onlyDrcCreator{
        //check whether the DRC already exists
        require(isDucCreated(_duc.id),"certificate does not exists");
        addDrcToOwners(_drc);
        storeDucInMap(_drc);
        emit DucUpdated(_drc.id, _drc.owners);
    }

    function readCert(bytes32 id) public view returns (DUC memory) {
        return certMap[id];
    }

    function updateCert(
        bytes32 id,
        bytes32 applicationId,
        bytes32 noticeId,
        uint farUtilized,
        uint circleRateSurrendered,
        uint circleRateUtilization,
        bytes32[] memory owners,
        uint timeStamp
    ) public {
        require(certMap[id].id == id, "Cert does not exist");
        certMap[id] = DrcUtilizationCert({
        id: id,
        applicationId: applicationId,
        noticeId: noticeId,
        farUtilized: farUtilized,
        circleRateSurrendered: circleRateSurrendered,
        circleRateUtilization: circleRateUtilization,
        owners: owners,
        timeStamp: timeStamp
        });
    }

    function deleteCert(bytes32 id) public {
        require(certMap[id].id == id, "Cert does not exist");
        delete certMap[id];
    }

    function isDucCreated(bytes32 ducId) public {
        if(certMap[_ducId].id !=""){
            return true;
        }
        return false;

    }

    function addDucToOwners(DUC memory duc) public {
        for (uint i=0; i< duc.owners.length; i++){
            addDrcToOwner(duc.id,duc.owners[i]);
        }
    }
    function addDucToOwner(bytes32 ducId, bytes32 ownerId) public {
        bytes32[] storage ducList = ownerMap[ownerId];
        ducList.push(ducId);
        ownerMap[ownerId]=ducList;
        emit DrcAddedToOwner(ducId,ownerId);
    }
    function storeDucInMap (DUC memory _duc) internal {
        //        drcMap[_drc.id]=_drc;
        //
        DUC storage duc = certMap[_duc.id];
        //
        duc.id = _duc.id;
        duc.applicationId = _duc.applicationId;
        duc.noticeId = _duc.noticeId;
        duc.farUtilized = _duc.farUtilized;
        duc.circleRateSurrendered = _duc.circleRateSurrendered;
        duc.circleRateUtilization = _duc.circleRateUtilization;
        duc.timeStamp = _duc.timeStamp;
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
        emit DrcIdsAdded(ownerId, ducList);
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

    //################333
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

}
