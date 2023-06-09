// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./TDR.sol";
import "./DataTypes.sol";
//import "./lib/Counters.sol";
//import "./lib/SafeMath.sol";
import "./KdaCommon.sol";

contract DrcStorage is KdaCommon {

//    using SafeMath for uint256;
//    using Counters for Counters.Counter;

    // Mappings
    // Create a mapping to store the DRC against Drc id
    mapping(bytes32 => DRC) public drcMap;  // drcId => drc
    mapping(bytes32 => bytes32[]) public ownerMap; //ownerId => drcId
    //mapping(bytes32 => bytes32[] ) public userApplicationMap; // onwerid => applicationId[]
    mapping(bytes32 => bytes32[] ) public drcDtaMap; // drcId => applicationId []
    mapping(bytes32 => bytes32[] ) public drcDuaMap; // drcId => applicationId []
    mapping (bytes32 => DrcCancellationInfo) public drcCancelMap; // drcId = cancellationInfo
    // Events
    event DrcCreated(bytes32 drcId, DRC drc, bytes32[] owners);
    event DrcUpdated(bytes32 drcId, DRC drc, bytes32[] owners);
    event OwnerAddedToDRC(bytes32 ownerId, bytes32 drcId, bytes32[] owners);
    event OwnerDeletedFromDrc(bytes32 ownerId, bytes32 drcId, bytes32[] owners);
    event DtaAddedToDrc(bytes32 dtaId, bytes32 applicationId);
    event DuaAddedToDrc(bytes32 dtaId, bytes32 applicationId);
    event DrcAddedToOwner(bytes32 drcId, bytes32 ownerId);

    address public tdrManager;



    function storeDrcCancellationInfo(bytes32 drcId, DrcCancellationInfo memory _drcCancellationInfo) external onlyManager {
        require(isDrcCreated(drcId),"DRC does not exists");
        drcCancelMap[drcId] = _drcCancellationInfo;

    }

    function deleteDrcCancellationInfo(bytes32 drcId) public onlyManager{
        delete drcCancelMap[drcId];
    }


    function getDrcCancellationInfo(bytes32 drcId) public view returns(DrcCancellationInfo memory) {
        return(drcCancelMap[drcId]);
    } 


    // Constructor function to set the initial values of the contract
    constructor(address _admin,address _manager) KdaCommon(_admin,_manager) {}


    modifier onlyDrcCreator() {
        // Drc is created only in two ways, either through land acquisition or through transfer.manager
        // In case of land acquisition, tdr manager would create the drc
        // in cae of transfer, drc manager would create the drc
        require(msg.sender == tdrManager|| msg.sender==manager, "Only the TDR Manager can perform this action.");
        _;
    }

    function setTdrManager(address _newTdrManager) onlyOwner public {
        tdrManager = _newTdrManager;
    }
    // Create a function to add a new Drc to the mapping
    function createDrc(DRC memory _drc) public onlyDrcCreator{
         if (_drc.owners.length <= 0) {
            revert("DRC has 0 owners");
        } 
        //check whether the DRC already exists
        require(!isDrcCreated(_drc.id),"DRC already exists");
        addDrcToOwners(_drc);
        storeDrcInMap(_drc);
        emit DrcCreated(_drc.id, _drc, _drc.owners);
    }
    // Create a function to update a Drc in the mapping
    function updateDrc(bytes32 _id, DRC memory _drc) public onlyManager {
        // the drc should exist
        // Update the Drc in the mapping
        require(_id ==_drc.id, "drcid should be same");
        require(isDrcCreated(_drc.id),"DRC does not exists");
        // insertDrc((_drc));
        storeDrcInMap(_drc);
        emit DrcUpdated(_drc.id, _drc, _drc.owners);

    }
    


    function addDrcToOwners(DRC memory drc) internal {
        for (uint i=0; i< drc.owners.length; i++){
            addDrcToOwner(drc.id,drc.owners[i]);
        }
    }
    function addDrcToOwner(bytes32 drcId, bytes32 ownerId) internal {
        bytes32[] storage drcList = ownerMap[ownerId];
        drcList.push(drcId);
        ownerMap[ownerId]=drcList;
        emit DrcAddedToOwner(drcId,ownerId);
    }


    // Create a function to retrieve a Drc from the mapping by ID
    function getDrc(bytes32 _id) public view returns (DRC memory) {
        // Retrieve the Drc from the mapping
        DRC memory drc = drcMap[_id];

        // Return the Drc's ID, name, and age
        return drc;
    }



    // Create a function to delete a Drc from the mapping
    function deleteDrc(bytes32 _id) public onlyAdmin{
        // Delete the Drc from the mapping
        delete drcMap[_id];
    }

    /**
    CRUD operations on the owner map
    */
    event DrcIdsAdded(bytes32 ownerId, bytes32[] drcList);
    function addDrcIdsToOwner(bytes32[] memory drcList, bytes32 ownerId) public onlyManager{
        if(isOwnerinOwnerMap(ownerId)){
            revert("owner already exist, try updating list");
        }
        ownerMap[ownerId] = drcList;
        emit DrcIdsAdded(ownerId, drcList);
    }

    event DrcIdsUpdated(bytes32 ownerId, bytes32[] drcList);
    function updateDrcIdsToOwner(bytes32[] memory drcList, bytes32 ownerId) public onlyManager{
        if(!isOwnerinOwnerMap(ownerId)){
            revert("owner does not exist, try creating list");
        }
        ownerMap[ownerId] = drcList;
        emit DrcIdsUpdated(ownerId, drcList);
    }

    event DrcIdsDeleted(bytes32 ownerId);
    /**
    Removes the owner from owner map, deleting all drcIds of owner in map
    WARNING: does not deletes owner from DRC, that has to be done separately
    */
    function deleteDrcIdsOfOwner(bytes32 ownerId) public onlyManager{
        delete ownerMap[ownerId];
        emit DrcIdsDeleted(ownerId);
    }

    function isDrcCreated (bytes32 _drcId) public view returns (bool) {
        // in mapping, default values of all atrributes is zero
        if(drcMap[_drcId].id !=""){
                return true; 
            }
            return false;
    }
    // ideally these functions should be moved to manager contract
    function addDrcOwner(bytes32 drcId, bytes32  newOwner)public {
        require(isDrcCreated(drcId),"DRC does not exists");
        DRC storage drc = drcMap[drcId];
        require(!isOwnerInDrc(drc, newOwner),"owner already in drc");
        drc.owners.push(newOwner);
        drcMap[drcId] = drc;
        addDrcToOwner(drcId,newOwner);
        emit OwnerAddedToDRC(newOwner,drcId,drc.owners);
    }


  function deleteOwner(bytes32 drcId, bytes32 ownerId) public{
    // assume single occurance of the ownerID
    // Funtion searches for owners and deletes it. Assume that there are multiple owner with same owner id.
    DRC storage drc = drcMap[drcId];
    bytes32[] memory oldOwners = drc.owners;
    // uint count =0;
    uint index=drc.owners.length;
    for(uint i=0; i<drc.owners.length; i++ ){
        if(ownerId == drc.owners[i]){
            index = i;
            break;
        }
    }
    if(index ==drc.owners.length){
            revert("Owner not found");
        }
    for(uint i=index; i<drc.owners.length-1;i++){
        drc.owners[i]=drc.owners[i+1];
    }
    drc.owners.pop();    
    // remove the drc from the the deleted user drcList.
    bytes32[] storage drcList = ownerMap[ownerId];
    index = drcList.length;
    for (uint i=0; i<drcList.length; i++){
        if(drcId == drcList[i]){
            index =i;
            break;
        }

    }
    if(index==drcList.length){
            revert ("error. DRC not found");
        }
    for(uint i=index; i<drcList.length-1;i++){
        drcList[i]=drcList[i+1];
    }
    drcList.pop;
    ownerMap[ownerId]=drcList;
    emit OwnerDeletedFromDrc(ownerId,drcId,oldOwners);

  }

    /**
    This function is outdated.
    It was used earlier when owner percentage were there in DRC
    */
  function getOwnerDetails(bytes32 _drcId, bytes32 ownerId) view public returns (bytes32) {
    DRC memory drc = drcMap[_drcId];
    for(uint i=0; i< drc.owners.length; i++){
        if (drc.owners[i]== ownerId) {
            return drc.owners[i];
            }
         }
      return "";
//    DrcOwner memory emptyDrcOwner;
//    return emptyDrcOwner;
    }

    function storeDrcInMap (DRC memory _drc) internal{
//        drcMap[_drc.id]=_drc;
//
        DRC storage drc = drcMap[_drc.id];
//
        drc.id = _drc.id;
        drc.applicationId = _drc.applicationId;
        drc.noticeId = _drc.noticeId;
        drc.status = _drc.status;
        drc.farCredited=_drc.farCredited;
        drc.farAvailable = _drc.farAvailable;
        drc.areaSurrendered = _drc.areaSurrendered;
        drc.circleRateSurrendered = _drc.circleRateSurrendered;
        drc.circleRateUtilization = _drc.circleRateUtilization;
        drc.timeStamp = _drc.timeStamp;
        drc.hasPrevious = _drc.hasPrevious;
        drc.previousDRC = _drc.previousDRC;
////        for(uint i =0; i<_drc.applications.length; i++){
////            drc.applications[i]= _drc.applications[i];
////        }
        delete drc.owners;

//    drc.owners = new DrcOwner[];
        for(uint i =0; i<_drc.owners.length; i++){
            drc.owners.push(_drc.owners[i]);
//            DrcOwner storage d = new ();
//            d.userId = _drc.owners[i];
//            d.area = d.area ;
//            drc.owners.push(owner);
////            drc.owners[i]= _drc.owners[i];
//            bytes32[] storage drcList = ownerMap[_drc.owners[i].userId];
//            drcList.push(drc.id);
//            ownerMap[_drc.owners[i].userId] = drcList;
        }
////        for(uint i =0; i<_drc.attributes.length; i++){
////            drc.attributes[i]= _drc.attributes[i];
////        }

        drcMap[_drc.id]=drc;
        emit Logger("store DRC in map executed");
    }
    // add application to drc
    event AllDTaForDrc(bytes32 drcId, bytes32[] applicationIds);

    function addDtaToDrc(bytes32 drcId,bytes32 applicationId) public onlyManager {
        bytes32[] storage applications = drcDtaMap[drcId];
        applications.push(applicationId);
        drcDtaMap[drcId]=applications;
        emit DtaAddedToDrc(drcId,applicationId);
        emit AllDTaForDrc(drcId,applications);

    }

    /**
CRUD operations on the drc DTA Map
*/
    event DtaIdsAdded(bytes32 drcId, bytes32[] dtaList);
    function addDtaIdsToDrc(bytes32[] memory dtaList, bytes32 drcId) public onlyManager{
        if(isDrcinDtaMap(drcId)){
            revert("drc already exist, try updating list");
        }
        drcDtaMap[drcId] = dtaList;
        emit DtaIdsAdded(drcId, dtaList);
    }

    event DtaIdsUpdated(bytes32 drcId, bytes32[] dtaList);
    function updateDtaIdsToDrc(bytes32[] memory dtaList, bytes32 drcId) public onlyManager{
        if(!isDrcinDtaMap(drcId)){
            revert("drc does not exist, try adding list");
        }
        drcDtaMap[drcId] = dtaList;
        emit DtaIdsUpdated(drcId, dtaList);
    }

    event DtaIdsDeleted(bytes32 drcId);
    function deleteDtaIdsOfDrc(bytes32 drcId) public onlyManager{
        delete drcDtaMap[drcId];
        emit DtaIdsDeleted(drcId);
    }
    function getDtaIdsForDrc(bytes32 drcId) public view returns (bytes32[] memory) {
        return drcDtaMap[drcId] ;
    }

    // add application to drc
    event AllDuaForDrc(bytes32 drcId, bytes32[] applicationIds);

    function addDuaToDrc(bytes32 drcId,bytes32 applicationId) public onlyManager{
        bytes32[] storage applications = drcDuaMap[drcId];
        applications.push(applicationId);
        drcDuaMap[drcId]=applications;
        emit DuaAddedToDrc(drcId,applicationId);
        emit AllDuaForDrc(drcId,applications);


    }
    // CRUD operations for drc dua map
    event DuaIdsAdded(bytes32 drcId, bytes32[] duaList);
    function addDuaIdsToDrc(bytes32[] memory duaList, bytes32 drcId) public onlyManager{
        if(isDrcinDuaMap(drcId)){
            revert("drc already exist, try updating list");
        }
        drcDuaMap[drcId] = duaList;
        emit DuaIdsAdded(drcId, duaList);
    }

    event DuaIdsUpdated(bytes32 drcId, bytes32[] duaList);
    function updateDuaIdsToDrc(bytes32[] memory duaList, bytes32 drcId) public onlyManager{
        if(!isDrcinDuaMap(drcId)){
            revert("drc does not exist, try adding list");
        }
        drcDuaMap[drcId] = duaList;
        emit DuaIdsUpdated(drcId, duaList);
    }

    event DuaIdsDeleted(bytes32 drcId);
    function deleteDuaIdsOfDrc(bytes32 drcId) public onlyManager{
        delete drcDuaMap[drcId];
        emit DuaIdsDeleted(drcId);
    }

//    function getDtaIdsForDrc(bytes32 drcId) public returns (bytes32[] memory) {
//        return drcDtaMap[drcId] ;
//    }
    function getDuaIdsForDrc(bytes32 drcId) public view returns (bytes32[] memory) {
        return drcDuaMap[drcId] ;
    }
//    function getDrcIdsForUser(bytes32 userId) public returns(bytes32[] memory) {
//        return ownerMap[userId];
//    }

    function isDrcinDuaMap(bytes32 drcId) public view returns(bool) {
        if(drcDuaMap[drcId].length == 0) {
        return false;
        }
    return true;
    }
    function isDrcinDtaMap(bytes32 drcId) public view returns(bool) {
        if(drcDtaMap[drcId].length == 0) {
            return false;
        }
        return true;
    }

    function getDrcIdsForUser(bytes32 userId) public view returns(bytes32[] memory) {
        return ownerMap[userId];
    }
    function isOwnerinOwnerMap(bytes32 ownerId) public view returns(bool) {
        if(ownerMap[ownerId].length == 0) {
            return false;
        }
        return true;
    }
    function isDrcExists(bytes32 drcId) public view returns(bool) {

        if(drcMap[drcId].id == "") {
            return false;
        }
        return true;
    }

    function isOwnerInDrc(DRC memory drc, bytes32 owner) public returns (bool){
        for (uint i=0; i < drc.owners.length; i++){
            if (drc.owners[i]==owner){
                return true;
            }
        }
        return false;
    }

//    //Generate DRCId
//    Counters.Counter private _drcIdCounter;
//    uint256 private constant _maxDrcCount = 99999;
//    string private counterPrefix = "DRC";

//    function generateDRCId() internal returns (bytes32) {
//        require (_drcIdCounter.current() < _maxDrcCount, "DRC ID counter has reached maximum value");
//        uint256 drcId = _drcIdCounter.current();
//        _drcIdCounter.increment();
//        bytes memory drcCountBytes = new bytes(5);
//        for (uint256 i = 0; i < 5; i++) {
//            drcCountBytes[4-i] = bytes1(uint8(48 + (drcId % 10)));
//            drcId /= 10;
//        }
//        return keccak256(abi.encodePacked(counterPrefix, drcId));
//    }
//    // Get latest DRC ID
//    function getLatestDRCId() public view returns (bytes32) {
//        return keccak256(abi.encodePacked(counterPrefix, _drcIdCounter.current()));
//    }

}


/*
for test cases
1. test whether the drc exist or not
2. test whether only owner is allowed to make changes
3. check whether one can change the owner

*/
