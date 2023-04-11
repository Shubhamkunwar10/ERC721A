// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./DRC.sol";
import "./UserManager.sol";
import "./DataTypes.sol";
import "./KdaCommon.sol";

contract DrcTransferApplicationStorage is KdaCommon{
    // enum ApplicationStatus {pending, submitted, approved, rejected}

    mapping(bytes32 => DrcTransferApplication) public applicationMap; // application id => application
    mapping(bytes32 => bytes32[]) public userApplicationMap; // userId => application Id
    mapping(bytes32 => DtaVerificationStatus) public verificationStatusMap; //applicationId => verification status

    //events
   
    event DtaAddedToUser(bytes32 userId, bytes32 applicationId);
    event DtaCreated(bytes32 applicationId, DrcTransferApplication dta, bytes32[] applicants);
    event DtaUpdated(bytes32 applicationId, DrcTransferApplication dta, bytes32[] applicants);

    // Constructor function to set the initial values of the contract
constructor(address _admin,address _manager) KdaCommon(_admin,_manager) {}


    function createApplication(
        DrcTransferApplication memory dta
    ) public onlyManager {
        require(
            applicationMap[dta.applicationId].applicationId == "",
            "application already exist"
        );
        storeApplicationInMap(dta);
        storeApplicationForUser(dta);
        emit DtaCreated(dta.applicationId, dta, getApplicantIdsFromApplication(dta));
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
        DrcTransferApplication memory dta =  DrcTransferApplication(
                _applicationId,
                _drcId,
                _farTransferred,
                _signatories,
                _buyers,
                _status,
                _timeStamp
            );
        storeApplicationInMap(dta);
        storeApplicationForUser(dta);
        // storeApplicationInMap(
        //     DrcTransferApplication(
        //         _applicationId,
        //         _drcId,
        //         _farTransferred,
        //         _signatories,
        //         _buyers,
        //         _status,
        //         _timeStamp
        //     )
        // );
        // storeApplicationForUser(
        //     DrcTransferApplication(
        //         _applicationId,
        //         _drcId,
        //         _farTransferred,
        //         _signatories,
        //         _buyers,
        //         _status,
        //         _timeStamp
        //     )
        // );
        emit DtaCreated(_applicationId,dta, getApplicantIdsFromApplication(dta));
    }

    function updateApplication(
        DrcTransferApplication memory dta
    ) public onlyManager {
        require(
            applicationMap[dta.applicationId].applicationId != "",
            "application does not exist"
        );
        storeApplicationInMap(dta);
        emit DtaUpdated(dta.applicationId,dta, getApplicantIdsFromApplication(dta));
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
        DtaVerificationStatus memory status
    ) public onlyManager {
        verificationStatusMap[id] = status;
    }

    function deleteVerificationStatus(
        bytes32 id,
        DtaVerificationStatus memory status
    ) public {
        delete verificationStatusMap[id];
    }

    function getVerificationStatus(
        bytes32 applicationId
    ) public view returns (DtaVerificationStatus memory) {
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
            emit DtaAddedToUser(
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


    function getApplicantIdsFromApplication(
        DrcTransferApplication memory _dta
    ) 
    internal 
    pure 
    returns (bytes32[] memory) {
        bytes32[] memory applicantList = new bytes32[](
            _dta.applicants.length
        );
        for (uint i = 0; i < _dta.applicants.length; i++) {
            applicantList[i] = _dta.applicants[i].userId;
        }
        return applicantList;
    }
}
