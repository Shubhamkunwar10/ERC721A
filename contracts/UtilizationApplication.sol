// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./DRC.sol";
import "./UserManager.sol";
import "./KdaCommon.sol";


contract DuaStorage is KdaCommon {
    mapping(bytes32 => DUA) public applicationMap; // applicaton id => dua application
    mapping(bytes32 => bytes32[]) public userApplicationMap; //userId => application id list

    //logger events
    event DUACreatedForUser(bytes32 userId, bytes32 applicationId);
    event DUACreated(bytes32 applicationId);
    event DUAUpdated(bytes32 applicationId);


  // Constructor function to set the initial values of the contract
    constructor(address _admin,address _manager) KdaCommon(_admin,_manager) {}


    function createApplication(DUA memory dua) public onlyManager {
        require(
            applicationMap[dua.applicationId].applicationId == "",
            "application already exist"
        );
        storeApplicationInMap(dua);
        storeApplicationForUser(dua);
        emit DUACreated(dua.applicationId);
    }

    function createApplication(
        bytes32 _applicationId,
        bytes32 _drcId,
        uint _farTransferred,
        Signatory[] memory _signatories,
        uint _timeStamp,
        ApplicationStatus _status
    ) public onlyManager {
        require(
            applicationMap[_applicationId].applicationId == "",
            "application already exist"
        );
        storeApplicationInMap(
            DUA(
                _applicationId,
                _drcId,
                _farTransferred,
                _signatories,
                _status,
                _timeStamp
            )
        );
        storeApplicationForUser(
            DUA(
                _applicationId,
                _drcId,
                _farTransferred,
                _signatories,
                _status,
                _timeStamp
            )
        );
        emit DUACreated(_applicationId);
    }

    function updateApplication(DUA memory dua) public onlyManager {
        require(
            applicationMap[dua.applicationId].applicationId != "",
            "application does not exist"
        );
        storeApplicationInMap(dua);
        emit DUAUpdated(dua.applicationId);
    }

    function updateApplication(
        bytes32 _applicationId,
        bytes32 _drcId,
        uint _farTransferred,
        Signatory[] memory _signatories,
        uint _timeStamp,
        ApplicationStatus _status
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
                _signatories,
                _status,
                _timeStamp
            )
        );
        emit DUAUpdated(_applicationId);
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
        dua.status = _dua.status;
        dua.timeStamp = _dua.timeStamp;
        delete dua.signatories;
        for (uint i = 0; i < _dua.signatories.length; i++) {
            dua.signatories.push(_dua.signatories[i]);
        }

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
            emit DUACreatedForUser(
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
}
