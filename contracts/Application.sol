// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./DRC.sol";
import "./UserManager.sol";
import "./DataTypes.sol";

contract DrcTransferApplicationStorage {
    // enum ApplicationStatus {pending, submitted, approved, rejected}

    mapping(bytes32 => DrcTransferApplication) public applicationMap; // application id => application
    mapping(bytes32 => bytes32[]) public userApplicationMap; // userId => application Id
    mapping(bytes32 => VerificationStatus) public verificationStatusMap; //applicationId => verification status

    address owner;
    address admin;
    address manager;
    //events
    event Logger(string s);
    event LogAddress(string addressInfo, address _address);
    event LogBytes(string messgaeInfo, bytes32 _bytes);
    event LogBool(string messageInfo, bool message);
    event LogApplication(string message, TdrApplication application);
    event DTACreatedForUser(bytes32 userId, bytes32 applicationId);
    event DTACreated(bytes32 applicationId);
    event DTAUpdated(bytes32 applicationId);

    // Constructor function to set the initial values of the contract
    constructor(address _admin, address _manager) {
        // Set the contract owner to the caller
        owner = msg.sender;

        // Set the contract admin
        admin = _admin;
        manager = _manager;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == admin || msg.sender == owner,
            "Only the admin or owner can perform this action."
        );
        _;
    }

    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Only the manager, admin, or owner can perform this action."
        );
        _;
    }

    function setAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function setManager(address _manager) public {
        require(msg.sender == owner || msg.sender == admin);
        manager = _manager;
    }

    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function createApplication(
        DrcTransferApplication memory dta
    ) public onlyManager {
        require(
            applicationMap[dta.applicationId].applicationId == "",
            "application already exist"
        );
        storeApplicationInMap(dta);
        storeApplicationForUser(dta);
        emit DTACreated(dta.applicationId);
    }

    function createApplication(
        bytes32 _applicationId,
        bytes32 _drcId,
        uint _farTransferred,
        Signatory[] memory _signatories,
        bytes32[] memory _buyers,
        uint _timeStamp,
        ApplicationStatus _status
    ) public onlyManager {
        require(
            applicationMap[_applicationId].applicationId == "",
            "application already exist"
        );
        emit Logger("application created in dta storage");
        storeApplicationInMap(
            DrcTransferApplication(
                _applicationId,
                _drcId,
                _farTransferred,
                _signatories,
                _buyers,
                _status,
                _timeStamp
            )
        );
        storeApplicationForUser(
            DrcTransferApplication(
                _applicationId,
                _drcId,
                _farTransferred,
                _signatories,
                _buyers,
                _status,
                _timeStamp
            )
        );
        emit DTACreated(_applicationId);
    }

    function updateApplication(
        DrcTransferApplication memory dta
    ) public onlyManager {
        require(
            applicationMap[dta.applicationId].applicationId != "",
            "application does not exist"
        );
        storeApplicationInMap(dta);
        emit DTAUpdated(dta.applicationId);
    }

    function getApplication(
        bytes32 _id
    ) public view returns (DrcTransferApplication memory) {
        return applicationMap[_id];
    }

    function deleteApplication(bytes32 _id) public onlyAdmin {
        require(msg.sender == admin, "Only the admin can delete applications.");
        delete applicationMap[_id];
    }

    // This function just creates a new appliction in the mapping based on the applicaiton in the memory
    function storeApplicationInMap(
        DrcTransferApplication memory _dta
    ) internal {
        DrcTransferApplication storage dta = applicationMap[_dta.applicationId];

        dta.applicationId = _dta.applicationId;
        dta.drcId = _dta.drcId;
        dta.farTransferred = _dta.farTransferred;
        dta.status = _dta.status;
        dta.timeStamp = _dta.timeStamp;
        delete dta.applicants;
        for (uint i = 0; i < _dta.applicants.length; i++) {
            dta.applicants.push(_dta.applicants[i]);
        }
        delete dta.buyers;
        for (uint i = 0; i < _dta.buyers.length; i++) {
            dta.buyers.push(_dta.buyers[i]);
        }

        applicationMap[dta.applicationId] = dta;
    }

    function storeVerificationStatus(
        bytes32 id,
        VerificationStatus memory status
    ) public onlyManager {
        verificationStatusMap[id] = status;
    }

    function deleteVerificationStatus(
        bytes32 id,
        VerificationStatus memory status
    ) public {
        delete verificationStatusMap[id];
    }

    function getVerificationStatus(
        bytes32 applicationId
    ) public view returns (VerificationStatus memory) {
        return verificationStatusMap[applicationId];
    }

    function getApplicationForUser(
        bytes32 userId
    ) public view onlyManager returns (bytes32[] memory) {
        return userApplicationMap[userId];
    }

    function storeApplicationForUser(
        DrcTransferApplication memory application
    ) internal {
        for (uint i = 0; i < application.applicants.length; i++) {
            bytes32 userId = application.applicants[i].userId;
            bytes32[] storage applicationIds = userApplicationMap[userId];
            applicationIds.push(application.applicationId);
            userApplicationMap[userId] = applicationIds;
            emit DTACreatedForUser(
                application.applicants[i].userId,
                application.applicationId
            );
        }
    }

    event addedDtaListToUser(bytes32[] applicationList, bytes32 userId);

    function addApplicationListToUser(
        bytes32[] memory applicationList,
        bytes32 userId
    ) public onlyManager {
        if (userApplicationMap[userId].length != 0) {
            revert("An application list already exist, try updating it");
        }
        userApplicationMap[userId] = applicationList;
        emit addedDtaListToUser(applicationList, userId);
    }

    event updatedDtaListToUser(bytes32[] applicationList, bytes32 userId);

    function updateApplicationListToUser(
        bytes32[] memory applicationList,
        bytes32 userId
    ) public onlyManager {
        if (userApplicationMap[userId].length != 0) {
            revert("An application list does not exist, try adding it");
        }
        userApplicationMap[userId] = applicationList;
        emit updatedDtaListToUser(applicationList, userId);
    }

    event deletedDtaListForUser(bytes32 userId);

    function deleteUserApplicationList(bytes32 userId) public onlyManager {
        delete userApplicationMap[userId];
        emit deletedDtaListForUser(userId);
    }
}
