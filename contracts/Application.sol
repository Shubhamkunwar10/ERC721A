// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./DRC.sol";
import "./UserManager.sol";

contract DrcTransferApplicationStorage {
    enum Status {pending, submitted, approved, rejected}

    struct DrcTransferApplication {
        bytes32 id;
        bytes32 drcId;
        uint farTransferred;
        Signatory[] signatories;
        DrcStorage.DrcOwner[] newDrcOwner;
        Status status;
    }

    struct Signatory {
        bytes32 userId;
        bool hasUserSigned;
    }

    mapping(bytes32 => DrcTransferApplication) public applicationMap;
    address admin;

    constructor(){
        admin = msg.sender;
    }
    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the contract admin");
        _;
    }


    function createApplication(DrcTransferApplication memory dta) public onlyAdmin{
        require(applicationMap[dta.id].id =="","application already exist");
        storeApplicationInMap(dta);
    }

    function createApplication(bytes32 _id, bytes32 _drcId, uint _farTransferred, Signatory[] memory _signatories, DrcStorage.DrcOwner[] memory _newDrcOwner, Status _status) public {
        require(msg.sender == admin, "Only the admin can create applications.");
        require(applicationMap[_id].id =="","application already exist");
        storeApplicationInMap(DrcTransferApplication(_id, _drcId, _farTransferred, _signatories, _newDrcOwner, _status));
    }

    function updateApplication(DrcTransferApplication memory dta) public onlyAdmin{
        require(applicationMap[dta.id].id !="","application does not exist");
        storeApplicationInMap(dta);

    }

    function updateApplication(bytes32 _id, bytes32 _drcId, uint _farTransferred, Signatory[] memory _signatories, DrcStorage.DrcOwner[] memory _newDrcOwner, Status _status) public {
        require(msg.sender == admin, "Only the admin can update applications.");
        require(applicationMap[_id].id !="","application does not exist");
        storeApplicationInMap(DrcTransferApplication(_id, _drcId, _farTransferred, _signatories, _newDrcOwner, _status));
    }

    function getApplication(bytes32 _id) view public returns(DrcTransferApplication memory){
       require(applicationMap[_id].id !="","application does not exist");
       return applicationMap[_id];
    }

    function deleteApplication(bytes32 _id) public {
        require(msg.sender == admin, "Only the admin can delete applications.");
        delete applicationMap[_id];
    }
    // This function just creates a new appliction in the mapping based on the applicaiton in the memory
    function storeApplicationInMap (DrcTransferApplication memory _dta) internal {
        DrcTransferApplication storage dta = applicationMap[_dta.id];
        
        dta.id = _dta.id;
        dta.drcId = _dta.drcId;
        dta.farTransferred = _dta.farTransferred;
        dta.status = _dta.status;
        for (uint i =0; i< _dta.signatories.length; i++){
            dta.signatories[i]=_dta.signatories[i];
        }
        for (uint i =0; i< _dta.newDrcOwner.length; i++){
            dta.newDrcOwner[i]=_dta.newDrcOwner[i];
        }

        applicationMap[dta.id]=dta;
    }
}
