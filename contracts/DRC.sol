// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./TDR.sol";
import "./DataTypes.sol";

contract DrcStorage {
    // Define the struct that we will be using for our CRUD operations



    // Mappings
    // Create a mapping to store the DRC against Drc id
    mapping(bytes32 => DRC) public drcMap; 
    mapping(bytes32 => bytes32[]) public ownerMap;

    // Events
    event DrcCreated(bytes32 drcId);

    
    address owner;
    address admin;
    address drcManager;
    constructor(address _admin) {
        // Set the contract admin
        admin = _admin;

        // Set the TDR manager to the contract admin
        owner = msg.sender;
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
        require(msg.sender == drcManager, "Caller is not the contract admin");
        _;
    }

    function changeAdmin(address _newAdmin) onlyOwner public{
        admin = _newAdmin;
    }
    function changeOwner(address _newOwner) onlyOwner public {
        owner = _newOwner;
    }
    function changeManager(address _newManager) onlyAdmin public {
        drcManager = _newManager;
    }
    // Create a function to add a new Drc to the mapping
    function createDRC(DRC memory _drc) public onlyManager{
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
    } 

  function addDrcOnwers(bytes32 _drcId, DrcOwner[] memory newOwners)public {
    require(isDrcCreated(_drcId),"DRC does not exists");
    DRC storage drc = drcMap[_drcId];
    for(uint i= 0; i< newOwners.length;i++){
        drc.owners.push(newOwners[i]);
    }
    drcMap[_drcId] = drc;
  }

  function deleteOwner(bytes32 _drcId, bytes32 ownerId) public{
    // assume singkle occurance of the ownerID
    // Funtion searches for owners and deletes it. Assume that there are multiple owner with same owner id.
    DRC storage drc = drcMap[_drcId];
    // uint count =0;
    uint index;
    for(uint i=0; i<drc.owners.length; i++ ){
        if(ownerId == drc.owners[i].id){
            index = i;
            break;
        }
        if(i == drc.owners.length -1){
            revert("Owner not found");
        }
    }
    for(uint i=index; i<drc.owners.length-1;i++){
        drc.owners[i]=drc.owners[i+1];
    }
    drc.owners.pop();

    }

  function getOwnerDetails(bytes32 _drcId, bytes32 ownerId) view public returns (DrcOwner memory) {
    DRC memory drc = drcMap[_drcId];
    for(uint i=0; i< drc.owners.length; i++){
        if (drc.owners[i].id == ownerId) {
            return drc.owners[i];
            }
         }
    DrcOwner memory emptyDrcOwner;
    return emptyDrcOwner;
    }

    function storeDrcInMap (DRC memory _drc) internal {
        DRC storage drc = drcMap[_drc.id];
        
        drc.id = _drc.id;
        drc.notice = _drc.notice;
        drc.status = _drc.status;
        drc.farAvailable = _drc.farAvailable;
        drc.areaSurrendered = _drc.areaSurrendered;
        drc.circleRateSurrendered = _drc.circleRateSurrendered;
        drc.circleRateUtilization = _drc.circleRateUtilization;
        for(uint i =0; i<_drc.applications.length; i++){
            drc.applications[i]= _drc.applications[i];
        }
        for(uint i =0; i<_drc.owners.length; i++){
            drc.owners[i]= _drc.owners[i];
            bytes32[] storage drcList = ownerMap[_drc.owners[i].id];
            drcList.push(drc.id);
            ownerMap[_drc.owners[i].id] = drcList;
        }
        for(uint i =0; i<_drc.attributes.length; i++){
            drc.attributes[i]= _drc.attributes[i];
        }

        drcMap[drc.id]=drc;
    }
}


/*
for test cases
1. test whether the drc exist or not
2. test whether only owner is allowed to make changes
3. check whether one can change the owner

*/
