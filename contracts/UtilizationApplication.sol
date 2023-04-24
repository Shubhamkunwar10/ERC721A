// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./DRC.sol";
import "./UserManager.sol";
import "./KdaCommon.sol";


contract DuaStorage is KdaCommon {
    mapping(bytes32 => DUA) public applicationMap; // applicaton id => dua application
    mapping(bytes32 => bytes32[]) public userApplicationMap; //userId => application id list

    //logger events
    event DuaAddedToUser(bytes32 userId, bytes32 applicationId);
    event DuaCreated(bytes32 applicationId, DUA dua, bytes32[] applicants);
    event DuaUpdated(bytes32 applicationId);


  // Constructor function to set the initial values of the contract
    constructor(address _admin,address _manager) KdaCommon(_admin,_manager) {}


    function createApplication(DUA memory dua) public onlyManager {
        require(
            applicationMap[dua.applicationId].applicationId == "",
            "application already exist"
        );
        storeApplicationInMap(dua);
        storeApplicationForUser(dua);
        emit DuaCreated(dua.applicationId,dua,getApplicantIdsFromApplication(dua));
    }

    function createApplication(
        bytes32 _applicationId,
        bytes32 _drcId,
        uint _farTransferred,
        uint _farPermitted,
        Signatory[] memory _signatories,
        ApplicationStatus _status,
        uint _timeStamp,
        DrcUtilizationDetails memory _drcUtilizationDetails
    ) public onlyManager {
        require(
            applicationMap[_applicationId].applicationId == "",
            "application already exist"
        );
        
        DUA memory dua = DUA(
                _applicationId,
                _drcId,
                _farTransferred,
                _farPermitted,
                _signatories,
                _status,
                _timeStamp,
                _drcUtilizationDetails
            );
        storeApplicationInMap(dua);
        storeApplicationForUser(dua);

        // storeApplicationInMap(
        //     DUA(
        //         _applicationId,
        //         _drcId,
        //         _farTransferred,
        //         _signatories,
        //         _status,
        //         _timeStamp
        //     )
        // );
        // storeApplicationForUser(
        //     DUA(
        //         _applicationId,
        //         _drcId,
        //         _farTransferred,
        //         _signatories,
        //         _status,
        //         _timeStamp
        //     )
        // );
        emit DuaCreated(_applicationId,dua,getApplicantIdsFromApplication(dua));
    }

    function updateApplication(DUA memory dua) public onlyManager {
        require(
            applicationMap[dua.applicationId].applicationId != "",
            "application does not exist"
        );
        storeApplicationInMap(dua);
        emit DuaUpdated(dua.applicationId);
    }

    function updateApplication(
        bytes32 _applicationId,
        bytes32 _drcId,
        uint _farTransferred,
        uint _farPermitted,
        Signatory[] memory _signatories,
        uint _timeStamp,
        ApplicationStatus _status,
        DrcUtilizationDetails memory _drcUtilizationDetails
    ) public onlyManager {
        require(
            applicationMap[_applicationId].applicationId != "",
            "application does not exist"
        );
        storeApplicationInMap(
            DUA(
                _applicationId,
                _drcId,
                _farTransferred,
                _farPermitted,
                _signatories,
                _status,
                _timeStamp,
                _drcUtilizationDetails
            )
        );
        emit DuaUpdated(_applicationId);
    }

    function getApplication(bytes32 _id) public view returns (DUA memory) {
        require(
            applicationMap[_id].applicationId != "",
            "application does not exist"
        );
        return applicationMap[_id];
    }

    function deleteApplication(bytes32 _id) public onlyAdmin {
        require(msg.sender == admin, "Only the admin can delete applications.");
        delete applicationMap[_id];
    }

    // This function just creates a new appliction in the mapping based on the applicaiton in the memory
    function storeApplicationInMap(DUA memory _dua) internal {
        DUA storage dua = applicationMap[_dua.applicationId];

        dua.applicationId = _dua.applicationId;
        dua.drcId = _dua.drcId;
        dua.farUtilized = _dua.farUtilized;
        dua.farPermitted = _dua.farPermitted;
        dua.status = _dua.status;
        dua.timeStamp = _dua.timeStamp;
        delete dua.signatories;
        for (uint i = 0; i < _dua.signatories.length; i++) {
            dua.signatories.push(_dua.signatories[i]);
        }
        dua.drcUtilizationDetails = _dua.drcUtilizationDetails;

        applicationMap[dua.applicationId] = dua;
    }

    function getApplicationForUser(
        bytes32 userId
    ) public view onlyManager returns (bytes32[] memory) {
        return userApplicationMap[userId];
    }

    function storeApplicationForUser(
        DUA memory application
    ) public onlyManager {
        for (uint i = 0; i < application.signatories.length; i++) {
            bytes32 userId = application.signatories[i].userId;
            bytes32[] storage applicationIds = userApplicationMap[userId];
            applicationIds.push(application.applicationId);
            userApplicationMap[userId] = applicationIds;
            emit DuaAddedToUser(
                application.signatories[i].userId,
                application.applicationId
            );
        }
    }

    event addedDuaListToUser(bytes32[] applicationList, bytes32 userId);

    function addApplicationListToUser(
        bytes32[] memory applicationList,
        bytes32 userId
    ) public onlyManager {
        if (userApplicationMap[userId].length != 0) {
            revert("An application list already exist, try updating it");
        }
        userApplicationMap[userId] = applicationList;
        emit addedDuaListToUser(applicationList, userId);
    }

    event updatedDuaListToUser(bytes32[] applicationList, bytes32 userId);

    function updateApplicationListToUser(
        bytes32[] memory applicationList,
        bytes32 userId
    ) public onlyManager {
        if (userApplicationMap[userId].length != 0) {
            revert("An application list does not exist, try adding it");
        }
        userApplicationMap[userId] = applicationList;
        emit updatedDuaListToUser(applicationList, userId);
    }

    event deletedDuaListForUser(bytes32 userId);

    function deleteUserApplicationList(bytes32 userId) public onlyManager {
        delete userApplicationMap[userId];
        emit deletedDuaListForUser(userId);
    }
    function getApplicantIdsFromApplication(
        DUA memory _dua
    ) 
    internal 
    pure 
    returns (bytes32[] memory) {
        bytes32[] memory applicantList = new bytes32[](
            _dua.signatories.length
        );
        for (uint i = 0; i < _dua.signatories.length; i++) {
            applicantList[i] = _dua.signatories[i].userId;
        }
        return applicantList;
    }
}
