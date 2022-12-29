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
    function createDRC(DRC memory _drc) public {

        // Increment the counter to get the next unique ID
        

        // // Create a new Drc with the provided name and age, and the next unique ID
        // Drc memory newDrc = Drc(DrcCount, _name, _age);

        // Add the new Drc to the mapping
 


    //     for(uint i=0; i< _drc.subDrc.length; i++){
    //         uint l = drc.subDrc.length();
    //         src.subDrc.push(); // add a new element to subdrc
    //         drc.subDrc[l].sNo= _drc.subDrc[i].sNo;
    //         drc.subDrc[l].area = _drc.subDrc[i].area;
    //         drc.subDrc[l].status = _drc.subDrc[i].status;
    //         drc.subDrc[l].linkeDrcId= _drc.subDrc[i].linkeDrcId;
    //         }
    //     for(uint i=0; i< _drc.owners.length; i++){
    //         uint l = drc.owners.length();
    //         src.owners.push(); // add a new element to owners
    //         drc.owners[l]._address= _drc.owners[i]._address;
    //         drc.owners[l].area = _drc.owners[i].area;
    //         }
    //     for(uint i=0; i< _drc.subDrc.length; i++){
    //         uint l = drc.subDrc.length();
    //         src.subDrc.push(); // add a new element to subdrc
    //         drc.subDrc[l].sNo= _drc.subDrc[i].sNo;
    //         drc.subDrc[l].area = _drc.subDrc[i].area;
    //         drc.subDrc[l].status = _drc.subDrc[i].status;
    //         drc.subDrc[l].linkeDrcId= _drc.subDrc[i].linkeDrcId;
    //         }

    //     drc.subDrc = SubDrc[_drc.subDrc.length]
    //         drc.attributes.push(_subDrc.a) 
    //   // add the credential at the end of the batch Credential array
    //   Credential memory _credential = dataList[i];
    //   uint l = batch.credentials.length;
    //   batch.credentials.push();
    //   batch.credentials[l].candidate=_credential.candidate;
    //   for(uint j=0; j < _credential.attributes.length;j++){
    //       batch.credentials[l].attributes.push(_credential.attributes[j]);
    //   }
    //     // uint availableArea;
    //     // uint khasraNo;
    //     // string village;
    //     // string ward;
    //     // string scheme;
    //     // string plotNo;
    //     // string tehsil;
    //     // string district;
    //     string landUse; // It could be enum
    //     uint areaSurrendered;
    //     uint circleRateSurrendered;
    //     uint circleRateUtilization;
    //     uint FarCredited;
    //     SubDrc[] subDrc; 
    //     DrcOwner[] owners;
    //     Attribute[] attributes;


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
    function updateDrc(uint _id, DRC memory _drc) public {
        // the drc should exist
        // if drcList[_id] length !=0
        // Update the Drc in the mapping
        require(_id==_drc.id, "drcid should be same");
        insertDrc((_drc));
        // DrcList[_id] = _drc;
    }

    // // Create a function to delete a Drc from the mapping
    function deleteDrc(uint _id) public {
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
        // drc.FarCredited = _drc.FarCredited;
        // drc.subDrc=_drc.subDrc; //
        // drc.owners = _drc.owners;
        // drc.attributes = _drc.attributes;
// copy the subDrc to the drc
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

    //todo
    /*
    1. ensure that there is an owner and method to transfer and owner
    2. ensure that there is a method to update the drc such that all field might not be required,
     or you can extracst the drc and then update all the fields. 
     Since the drc would be stored in a map, it means that internally also, i have to update everything in one go, 
     unless I can store drc in a nested map like structure, and then update only the least feasible branch. Why would I do that?
    */
}

