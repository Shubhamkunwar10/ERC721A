// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./TDR.sol";

contract DrcStorage {
    // Define the struct that we will be using for our CRUD operations

    enum DrcStatus {available,locked_for_transfer, locked_for_utilization, transferred, utilized}
    enum SubDrcStatus{locked_for_transfer, locked_for_utilization, transferred, utilized,rejected}

    // DRC would be stored in this struct. knowing this DRC one should know the owner of the DRC, area and the status of the DRC
    // Everything else, is static data, not to be interpretted by blockchain.
    struct DRC {
        bytes32 id;
        TdrStorage.TdrNotice notice;
        DrcStatus status;
        uint farCredited;
        uint farAvailable;
        uint areaSurrendered;
        uint circleRateSurrendered;
        uint circleRateUtilization;
        SubDrc[] subDrcs; 
        DrcOwner[] owners;
        Attribute[] attributes; //keep this field for the future attributes
        // string issueDate;
    }

    struct DrcOwner{
        bytes32 id;
        uint area;
    }
    struct SubDrc{
        uint sNo;
        uint far;
        SubDrcStatus status;
        bytes32 linkedDrcId;
        // owners of subdrc is same as the original drc
    }

    struct Attribute{
    string name;
    string value;
    string mimeType;
    }

    // Mappings
    // Create a mapping to store the DRC against Drc id
    mapping(bytes32 => DRC) public drcMap; 

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
        drcMap[_drc.id] = _drc;
        emit DrcCreated(_drc.id);
    }
    // Create a function to update a Drc in the mapping
    function updateDrc(bytes32 _id, DRC memory _drc) public onlyManager {
        // the drc should exist
        // Update the Drc in the mapping
        require(_id ==_drc.id, "drcid should be same");
        require(!isDrcCreated(_drc.id),"DRC does not exists");
        // insertDrc((_drc));
        drcMap[_id] = _drc;
    }

    // // Create a function to retrieve a Drc from the mapping by ID
    function getDrc(bytes32 _id) public view returns (DRC memory) {
        // Retrieve the Drc from the mapping
        DRC memory drc = drcMap[_id];

        // Return the Drc's ID, name, and age
        return drc;
    }



    // // Create a function to delete a Drc from the mapping
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

    
}


/*
for test cases
1. test whether the drc exist or not
2. test whether only owner is allowed to make changes
3. check whether one can change the owner

*/
