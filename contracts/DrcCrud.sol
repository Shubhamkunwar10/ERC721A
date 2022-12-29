// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract DrcCrud {
    // Define the struct that we will be using for our CRUD operations
    enum Status {applied, approved, issued, locked_for_transfer, locked_for_utilization, transferred, utilized}
    address owner;

    // DRC would be stored in this struct. knowing this DRC one should know the owner of the DRC, area and the status of the DRC
    // Everything else, is static data, not to be interpretted by blockchain.
    struct DRC {
        uint id;
        Status status;
        uint availableArea;
        // uint khasraNo;
        // string village;
        // string ward;
        // string scheme;
        // string plotNo;
        // string tehsil;
        // string district;
        string landUse; // It could be enum
        uint areaSurrendered;
        uint circleRateSurrendered;
        uint circleRateUtilization;
        uint FarCredited;
        SubDrc[] subDrc; 
        DrcOwner[] owners;
        Attribute[] attributes;
        // string issueDate;
    }

    struct DrcOwner{
        address _address;
        uint area;
    }
    struct SubDrc{
        string sNo;
        uint area;
        string status;
        uint linkeDrcId;
        // owners of subdrc is same as the original drc
    }
    struct Attribute{
    string name;
    string value;
    string mimeType;
    }


    // Create a mapping to store the DRC
    mapping(uint => DRC) public DrcList;

    constructor(address _owner){
        owner = _owner;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Only the contract owner can add change drc.");
        _;

    }
    // Create a function to add a new Drc to the mapping
    function createDRC(DRC memory _drc) public onlyOwner{

        // DrcList[drc.id] = drc;
        // emit event
    }

    // // Create a function to retrieve a Drc from the mapping by ID
    function readDrc(uint _id) public view returns (DRC memory) {
        // Retrieve the Drc from the mapping
        DRC memory drc = DrcList[_id];

        // Return the Drc's ID, name, and age
        return drc;
    }

    // Create a function to update a Drc in the mapping
    function updateDrc(uint _id, DRC memory _drc) public onlyOwner {
        // the drc should exist
        // Update the Drc in the mapping
        require(_id==_drc.id, "drcid should be same");
        insertDrc((_drc));
        // DrcList[_id] = _drc;
    }

    // // Create a function to delete a Drc from the mapping
    function deleteDrc(uint _id) public onlyOwner{
        // Delete the Drc from the mapping
        delete DrcList[_id];
    }

    function insertDrc (DRC memory _drc) internal {
        // This function just inserts the drc in the map
       DRC storage drc = DrcList[_drc.id]; // This takes care of list being created
        drc.id = _drc.id;
        drc.status = _drc.status;
        drc.availableArea = _drc.availableArea;
        drc.landUse = _drc.landUse;
        drc.areaSurrendered = _drc.areaSurrendered;
        drc.circleRateSurrendered=_drc.circleRateSurrendered;
        drc.circleRateUtilization = _drc.circleRateUtilization;

        for(uint i=0; i< _drc.subDrc.length; i++){
            drc.subDrc.push(_drc.subDrc[i]);
        }
        for(uint i=0; i< _drc.subDrc.length; i++){
            drc.owners.push(_drc.owners[i]);
        }
        for(uint i=0; i< _drc.subDrc.length; i++){
            drc.attributes.push(_drc.attributes[i]);
        }
        DrcList[drc.id]=drc; // final insertion
    }

  function isDrcCreated (uint _drcId) public view returns (bool) {
    // in mapping, default values of all atrributes is zero
    if( DrcList[_drcId].id !=0){
            return true; 
        }
        return false;
  }
}


/*
for test cases
1. test whether the drc exist or not
2. test whether only owner is allowed to make changes
3. check whether one can change the owner

*/
