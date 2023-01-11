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

    mapping(bytes32 => DrcTransferApplication) public applications;
    address admin;

    constructor() public {
        admin = msg.sender;
    }

    function createApplication(bytes32 _id, bytes32 _drcId, uint _farTransferred, Signatory[] memory _signatories, DrcStorage.DrcOwner[] memory _newDrcOwner, Status _status) public {
        require(msg.sender == admin, "Only the admin can create applications.");
        applications[_id] = DrcTransferApplication(_id, _drcId, _farTransferred, _signatories, _newDrcOwner, _status);
    }

    function updateApplication(bytes32 _id, bytes32 _drcId, uint _farTransferred, Signatory[] memory _signatories, DrcStorage.DrcOwner[] memory _newDrcOwner, Status _status) public {
        require(msg.sender == admin, "Only the admin can update applications.");
        DrcTransferApplication storage application = applications[_id];
        application.drcId = _drcId;
        application.farTransferred = _farTransferred;
        application.signatories = _signatories;
        application.newDrcOwner = _newDrcOwner;
        application.status = _status;
    }

    function getApplication(bytes32 _id) public view returns (bytes32, bytes32, uint, Signatory[] memory, DrcStorage.DrcOwner[] memory, Status) {
        DrcTransferApplication storage application = applications[_id];
        return (application.id, application.drcId, application.farTransferred, application.signatories, application.newDrcOwner, application.status);
    }

    function deleteApplication(bytes32 _id) public {
        require(msg.sender == admin, "Only the admin can delete applications.");
        delete applications[_id];
    }
}
