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


    address owner;
    address admin;
    address manager;

    constructor() {
        owner = msg.sender;
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

    function createApplication(DrcTransferApplication memory dta) public onlyAdmin{
        require(applicationMap[dta.id].id =="","application already exist");
        storeApplicationInMap(dta);
    }

    function createApplication(bytes32 _id, bytes32 _drcId, uint _farTransferred, Signatory[] memory _signatories, DrcStorage.DrcOwner[] memory _newDrcOwner, Status _status) public onlyManager{
        require(applicationMap[_id].id =="","application already exist");
        storeApplicationInMap(DrcTransferApplication(_id, _drcId, _farTransferred, _signatories, _newDrcOwner, _status));
    }

    function updateApplication(DrcTransferApplication memory dta) public onlyAdmin{
        require(applicationMap[dta.id].id !="","application does not exist");
        storeApplicationInMap(dta);

    }

    function updateApplication(bytes32 _id, bytes32 _drcId, uint _farTransferred, Signatory[] memory _signatories, DrcStorage.DrcOwner[] memory _newDrcOwner, Status _status) public onlyManager{
        require(applicationMap[_id].id !="","application does not exist");
        storeApplicationInMap(DrcTransferApplication(_id, _drcId, _farTransferred, _signatories, _newDrcOwner, _status));
    }

    function getApplication(bytes32 _id) view public returns(DrcTransferApplication memory){
       require(applicationMap[_id].id !="","application does not exist");
       return applicationMap[_id];
    }

    function deleteApplication(bytes32 _id) public onlyManager {
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
