// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./TDR.sol";
import "./DataTypes.sol";

contract DrcStorage {
    // Define the struct that we will be using for our CRUD operations



    // Mappings
    // Create a mapping to store the DRC against Drc id
    mapping(bytes32 => DRC) public drcMap;  // drcId => drc
    mapping(bytes32 => bytes32[]) public ownerMap; //ownerId => drcId
//    mapping(bytes32 => bytes32[] ) public userApplicationMap; // onwerid => applicationId[]
    mapping(bytes32 => bytes32[] ) public drcDtaMap; // drcId => applicationId []
    mapping(bytes32 => bytes32[] ) public drcDuaMap; // drcId => applicationId []

    // Events
    event DrcCreated(bytes32 drcId);
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
        require(msg.sender == manager, "Caller is not the contract admin");
        _;
    }
    modifier onlyTdrManager() {
        require(msg.sender == tdrManager, "Only the TDR Manager can perform this action.");
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
    function setTdrManager(address _newTdrManager) onlyOwner public {
        tdrManager = _newTdrManager;
    }
    // Create a function to add a new Drc to the mapping
    function createDrc(DRC memory _drc) public onlyTdrManager{
        //check whether the DRC already exists
        require(isDrcCreated(_drc.id),"DRC already exists");
        storeDrcInMap(_drc);
        emit DrcCreated(_drc.id);
    }
    // Create a function to update a Drc in the mapping
    function updateDrc(bytes32 _id, DRC memory _drc) public onlyManager {
        // the drc should exist
        // Update the Drc in the mapping
        require(_id ==_drc.id, "drcid should be same");
        require(!isDrcCreated(_drc.id),"DRC does not exists");
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



    function isDrcCreated (bytes32 _drcId) public view returns (bool) {
        // in mapping, default values of all atrributes is zero
        if(drcMap[_drcId].id !=""){
                return true; 
            }
            return false;
    }
    // ideally these functions should be moved to manager contract
    function addDrcOnwer(bytes32 _drcId, DrcOwner memory newOwner)public {
        require(isDrcCreated(_drcId),"DRC does not exists");
        DRC storage drc = drcMap[_drcId];
        drc.owners.push(newOwner);
        drcMap[_drcId] = drc;
        bytes32[] storage drcList = ownerMap[newOwner.userId];
        drcList.push(_drcId);
        ownerMap[newOwner.userId] = drcList;
    } 

  function addDrcOnwers(bytes32 _drcId, DrcOwner[] memory newOwners)public {
    require(isDrcCreated(_drcId),"DRC does not exists");
    DRC storage drc = drcMap[_drcId];
    for(uint i= 0; i< newOwners.length;i++){
        drc.owners.push(newOwners[i]);
        bytes32[] storage drcList = ownerMap[newOwners[i].userId];
        drcList.push(_drcId);
        ownerMap[newOwners[i].userId] = drcList;
    }
    drcMap[_drcId] = drc;
  }

  function deleteOwner(bytes32 _drcId, bytes32 ownerId) public{
    // assume singkle occurance of the ownerID
    // Funtion searches for owners and deletes it. Assume that there are multiple owner with same owner id.
    DRC storage drc = drcMap[_drcId];
    // uint count =0;
    uint index=drc.owners.length;
    for(uint i=0; i<drc.owners.length; i++ ){
        if(ownerId == drc.owners[i].userId){
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
        if(_drcId == drcList[i]){
            index =i;
            break;
        }

    }
    if(index==drcList.length){
            revert ("error. Owner not found");
        }
    for(uint i=index; i<drcList.length-1;i++){
        drcList[i]=drcList[i+1];
    }
    drcList.pop;
    ownerMap[ownerId]=drcList;
    }

  function getOwnerDetails(bytes32 _drcId, bytes32 ownerId) view public returns (DrcOwner memory) {
    DRC memory drc = drcMap[_drcId];
    for(uint i=0; i< drc.owners.length; i++){
        if (drc.owners[i].userId == ownerId) {
            return drc.owners[i];
            }
         }
    DrcOwner memory emptyDrcOwner;
    return emptyDrcOwner;
    }

    function storeDrcInMap (DRC memory _drc) internal {
        DRC storage drc = drcMap[_drc.id];
        
        drc.id = _drc.id;
        drc.applicationId = _drc.applicationId;
        drc.noticeId = _drc.noticeId;
        drc.status = _drc.status;
        drc.farAvailable = _drc.farAvailable;
        drc.areaSurrendered = _drc.areaSurrendered;
        drc.circleRateSurrendered = _drc.circleRateSurrendered;
        drc.circleRateUtilization = _drc.circleRateUtilization;
//        for(uint i =0; i<_drc.applications.length; i++){
//            drc.applications[i]= _drc.applications[i];
//        }
        for(uint i =0; i<_drc.owners.length; i++){
            drc.owners[i]= _drc.owners[i];
            bytes32[] storage drcList = ownerMap[_drc.owners[i].userId];
            drcList.push(drc.id);
            ownerMap[_drc.owners[i].userId] = drcList;
        }
//        for(uint i =0; i<_drc.attributes.length; i++){
//            drc.attributes[i]= _drc.attributes[i];
//        }

        drcMap[drc.id]=drc;
    }
    // add application to drc
    function addDtaToDrc(bytes32 drcId,bytes32 applicationId) public {
        bytes32[] storage applications = drcDtaMap[drcId];
        applications.push(applicationId);
        drcDtaMap[drcId]=applications;
//        DRC memory drc = drcStorage.getDrc(drcId);
//        //        drc.farAvailable = drc.farAvailable - farConsumed;
//        bytes32[] memory newApplications = new bytes32[](drc.applications.length+1);
//        for (uint i=0; i< drc.applications.length; i++){
//            newApplications[i]=drc.applications[i];
//        }
//        newApplications[drc.applications.length]=applicationId;
//        drcStorage.updateDrc(drc.id,drc);

    }
    // add application to drc
    function addDuaToDrc(bytes32 drcId,bytes32 applicationId) public {
        bytes32[] storage applications = drcDuaMap[drcId];
        applications.push(applicationId);
        drcDuaMap[drcId]=applications;
    }
    function getDtaIdsForDrc(bytes32 drcId) public returns (bytes32[] memory) {
        return drcDtaMap[drcId] ;
    }
    function getDuaIdsForDrc(bytes32 drcId) public returns (bytes32[] memory) {
        return drcDuaMap[drcId] ;
    }

//    function getApplicationForUser(bytes32 userId) public onlyManager returns (bytes32[] memory){
//        return userApplicationMap[userId];
//    }

}


/*
for test cases
1. test whether the drc exist or not
2. test whether only owner is allowed to make changes
3. check whether one can change the owner

*/
