// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
import "./DataTypes.sol";
import "./KdaCommon.sol";


// Contract to maintain the TDR notice and applicationIds.
// A TdrNotice stores all the applicationIds against a notice. If any of the application is converted to DRC,
//  it stops taking further application against that notice. One should that go to court and get the DRC quashed.
// Note: This is a storage contract. Job of this contract is not to see the logic of the storage, 
// but to store the values in the blockchain. All the logic and checks should be there in the TdrManager contract
// TDR storage contract
contract TdrStorage is KdaCommon{
    // Address of the TDR manager
    address public tdrManager;

    // Mapping from TDR id to TDR data
    mapping(bytes32 => TdrNotice) public noticeMap; // noticeId => Notice
    mapping(bytes32 => TdrApplication) public applicationMap; // appId => application
    // Map to store the applications against the notice
    mapping(bytes32 => bytes32[]) public noticeApplicationMap; //noticeId => application
    mapping(bytes32 => VerificationStatus) public verificationStatusMap; //app Id => verification
    mapping(bytes32 => bytes32[]) public userApplicationMap; // userId => applicationId[]
    //User application mapping

    // Application zone mapping
    mapping(bytes32 => Zone) public applicationZoneMap;
    // TDR struct definition

    // Event emitted after a TDR is created
    event TdrApplicationUpdated(bytes32 noticeId, bytes32 applicationId, bytes32[] applicants);
    event TdrApplicationCreated(
        bytes32 noticeId,
        bytes32 applicationId,
        bytes32[] applicants
    );

    event NoticeCreated(bytes32 noticeId, TdrNotice notice);
    event NoticeUpdated(bytes32 noticeId, TdrNotice notice);
    event ApplicationCreatedForUser(bytes32 userId, bytes32 applicationId);

    // Event emitted after a TDR is updated
    event TDRUpdated(bytes32 noticeId, bytes32 applicationId);

    // Event emitted after a TDR is deleted
    event TDRDeleted(bytes32 noticeId);


   // Constructor function to set the initial values of the contract
    constructor(address _admin,address _manager) KdaCommon(_admin,_manager) {}




    event zoneSet(bytes32 applicationId, Zone _zone);


    // Function to create a new TDR
    function createApplication(
        TdrApplication memory _tdrApplication
    ) public onlyManager {
        // check that an application have not been created earlier
        if (isApplicationCreated(_tdrApplication.applicationId)) {
            revert("application with same id has already been created");
        }
        require(
            (_tdrApplication.applicants).length > 0,
            "Applicant should be greater than 0"
        );

        // add application to the map
        addApplicationToMap(_tdrApplication);
        storeApplicationForUser(_tdrApplication);
        // Create a new TDR and add it to the mapping

        // Emit the TDRCreated event
        emit TdrApplicationCreated(
            _tdrApplication.noticeId,
            _tdrApplication.applicationId,
            getApplicantIdsFromTdrApplication(_tdrApplication)
        );
    }

    function storeApplicationForUser(
        TdrApplication memory application
    ) public onlyManager {
        emit LogApplication(
            "logging the application before saving to users",
            application
        );
        for (uint i = 0; i < application.applicants.length; i++) {
            bytes32 userId = application.applicants[i].userId;
            bytes32[] storage applicationIds = userApplicationMap[userId];
            applicationIds.push(application.applicationId);
            userApplicationMap[userId] = applicationIds;
            emit ApplicationCreatedForUser(
                application.applicants[i].userId,
                application.applicationId
            );
        }
    }

    function getApplicationForUser(
        bytes32 userId
    ) public view onlyManager returns (bytes32[] memory) {
        return userApplicationMap[userId];
    }

    // Function to create a new TDR
    function createNotice(TdrNotice memory tdrNotice) public onlyManager {
        emit Logger("START createNotice");
        if (isNoticeCreated(tdrNotice)) {
            revert("notice already created");
        }
        saveNoticeInMap(tdrNotice);
        emit NoticeCreated(tdrNotice.noticeId, tdrNotice);
    }

    function saveNoticeInMap(TdrNotice memory _tdrNotice) public {
        noticeMap[_tdrNotice.noticeId] = _tdrNotice;
        emit LogBytes("notice saved in map", _tdrNotice.noticeId);
    }

    function updateNotice(TdrNotice memory tdrNotice) public onlyManager {
        emit Logger("START: updateNotice");
        TdrNotice memory _tdrNotice = noticeMap[tdrNotice.noticeId];
        if (!isNoticeCreated(tdrNotice)) {
            revert("no such notice exists, reverting");
        }
        if(_tdrNotice.status == NoticeStatus.ISSUED){
            revert("DRC already issued against the notice");
        }
        saveNoticeInMap(tdrNotice);
        emit NoticeUpdated(tdrNotice.noticeId, tdrNotice);
    }

    function deleteNotice(bytes32 noticeId) public onlyManager {
        delete noticeMap[noticeId];
    }

    /**
     * @dev Adds an application to a notice specified by its noticeId.
     * @param noticeId The bytes32 identifier of the notice to which the application is to be added.
     * @param applicationId The bytes32 identifier of the application to be added to the notice.
     * @dev Revert if no notice exists with the given noticeId.
     */
    function addApplicationToNotice(
        bytes32 noticeId,
        bytes32 applicationId
    ) public onlyManager {
        TdrNotice storage tdrNotice = noticeMap[noticeId];
        // notice should exist
        if (tdrNotice.noticeId == "") {
            revert("No such notice exist");
        }
        bytes32[] storage applications = noticeApplicationMap[noticeId];
        applications.push(applicationId);
        noticeApplicationMap[noticeId] = applications;
    }

    // Function to read a TDR
    function getApplication(
        bytes32 _applicationId
    ) public view returns (TdrApplication memory) {
        // Retrieve the TDR from the mapping
        TdrApplication memory application = applicationMap[_applicationId];

        // Return the TDR data
        return application;
    }

    // function to get a notice
    function getNotice(
        bytes32 _noticeId
    ) public view returns (TdrNotice memory) {
        // Retrieve the TDR from the mapping
        TdrNotice memory notice = noticeMap[_noticeId];

        // Return the TDR data
        return notice;
    }

    // Function to update a TDR
    function updateApplicationStatus(
        bytes32 _applicationId,
        ApplicationStatus _status
    ) public onlyManager {
        // fetch the application
        TdrApplication storage application = applicationMap[_applicationId];
        // revert if empty
        if (application.applicationId == "") {
            revert("Application with does not exist");
        }
        // update the application
        application.status = _status;
        // Update the application in the mapping
        applicationMap[_applicationId] = application;
        // check for the notice
        if (_status == ApplicationStatus.DRCISSUED) {
            TdrNotice storage notice = noticeMap[application.noticeId];
            notice.status = NoticeStatus.ISSUED;
            noticeMap[application.noticeId] = notice;
        }

        // Emit the TDRUpdated event
        emit TDRUpdated(application.noticeId, application.applicationId);
    }

    function updateApplication(
        TdrApplication memory _application
    ) public onlyManager {
        emit LogBytes("begin update application", _application.applicationId);
        if (!isApplicationCreated(_application.applicationId)) {
            revert("Application does not exist");
        }
        addApplicationToMap(_application);
        emit TdrApplicationUpdated(
            _application.noticeId,
            _application.applicationId,
            getApplicantIdsFromTdrApplication(_application)
        ); // emit this event
    }

    function deleteApplication(bytes32 noticeId) public onlyManager {
        delete applicationMap[noticeId];
    }

    /**
     * @dev Adds an application to the applicationMap.
     * @param _application The TdrApplication memory object to be added to the applicationMap.
     */
    function addApplicationToMap(TdrApplication memory _application) internal {
        emit Logger("Adding application to map");
        // Retrieve the application in storage using its applicationId
        TdrApplication storage application = applicationMap[
            _application.applicationId
        ];
        // Copy the properties of the input _application to the storage application
        application.applicationId = _application.applicationId;
        application.timeStamp = _application.timeStamp;
        application.place = _application.place;
        application.noticeId = _application.noticeId;
        application.farRequested = _application.farRequested;
        application.circleRateUtilized = _application.circleRateUtilized;
        //        application.farGranted = _application.farGranted;
        application.status = _application.status;
        delete application.applicants;

        // Copy the applicants array from the input _application to the storage application
        for (uint i = 0; i < _application.applicants.length; i++) {
            // possible bug here over then length of the applicants.
            application.applicants.push(_application.applicants[i]);
            // application.applicants[i] = _application.applicants[i];
        }
        // Add the storage application to the applicationMap using its applicationId
        applicationMap[_application.applicationId] = application;
        emit LogBytes(
            "successfully added application to map",
            _application.applicationId
        );
    }

    // // Function to delete a TDR
    // function deleteTDR(uint _tdrId) public onlyManager {
    //     // Delete the TDR from the mapping
    //     delete tdrData[_tdrId];

    // Emit the TDRDeleted event

    function isNoticeCreated(
        TdrNotice memory _tdrNotice
    ) public returns (bool) {
        emit Logger("notice check was called");
        // in mapping, default values of all atrributes is zero
        TdrNotice memory _noticeFromMap = noticeMap[_tdrNotice.noticeId];
        if (_noticeFromMap.noticeId == "") {
            emit Logger("notice has not been created");

            return false;
        }
        emit Logger("notice has been created");
        return true;
    }

    function isApplicationCreated(
        bytes32 _applicationId
    ) public returns (bool) {
        emit Logger("application check was called");
        // in mapping, default values of all atrributes is zero
        TdrApplication memory application = applicationMap[_applicationId];
        if (application.applicationId == "") {
            emit Logger("application has not been created");
            return false;
        }
        require(_applicationId > 0, "Applicant must be greater than 0");
        emit Logger("application has been created");
        return true;
    }

    function storeVerificationStatus(
        bytes32 id,
        VerificationStatus memory status
    ) public {
        verificationStatusMap[id] = status;
    }

    function getVerificationStatus(
        bytes32 applicationId
    ) public view returns (VerificationStatus memory) {
        return verificationStatusMap[applicationId];
    }

    function deletVerificationStatus(
        bytes32 id
    )  public {
        delete verificationStatusMap[id];
    }

    function getApplicationsForNotice(
        bytes32 noticeId
    ) public view returns (bytes32[] memory) {
        return noticeApplicationMap[noticeId];
    }

    function deleteApplicationInMap(bytes32 applicationId) public onlyManager {
        delete applicationMap[applicationId];
    }

    function addApplicationListToNotice(
        bytes32[] memory applicationList,
        bytes32 noticeId
    ) public onlyManager {
        noticeApplicationMap[noticeId] = applicationList;
    }

    function updateApplicationListToNotice(
        bytes32[] memory applicationList,
        bytes32 noticeId
    ) public onlyManager {
        noticeApplicationMap[noticeId] = applicationList;
    }

    function deleteApplicationListToNotice(
        bytes32 noticeId
    ) public onlyManager {
        delete noticeApplicationMap[noticeId];
    }

    function addApplicationListToUser(
        bytes32[] memory applicationList,
        bytes32 userId
    ) public onlyManager {
        userApplicationMap[userId] = applicationList;
    }

    function updateApplicationListToUser(
        bytes32[] memory applicationList,
        bytes32 userId
    ) public onlyManager {
        userApplicationMap[userId] = applicationList;
    }

    function deleteApplicationListToUser(bytes32 userId) public onlyManager {
        delete userApplicationMap[userId];
    }

    // delete application from notice
    function deleteApplicationFromNotice(
        bytes32 noticeId,
        bytes32 applicationId
    ) public onlyManager {
        bytes32[] storage applicationIds = noticeApplicationMap[noticeId];
        uint index = findIndex(applicationIds, applicationId);
        if (index == applicationIds.length) {
            revert("applicationId not found");
        }
        for (uint i = index; i < applicationIds.length; i++) {
            applicationIds[i] = applicationIds[i + 1];
        }
        applicationIds.pop();
        noticeApplicationMap[noticeId] = applicationIds;
    }

    function deleteApplicationFromUser(
        bytes32 userId,
        bytes32 applicationId
    ) public onlyManager {
        bytes32[] storage applicationIds = userApplicationMap[userId];
        uint index = findIndex(applicationIds, applicationId);
        if (index == applicationIds.length) {
            revert("applicationId not found");
        }
        for (uint i = index; i < applicationIds.length; i++) {
            applicationIds[i] = applicationIds[i + 1];
        }
        applicationIds.pop();
        userApplicationMap[userId] = applicationIds;
    }

    function findIndex(
        bytes32[] memory arr,
        bytes32 element
    ) internal pure returns (uint) {
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == element) {
                return i;
            }
        }
        return arr.length;
    }

    function getApplicantIdsFromTdrApplication(
        TdrApplication memory _tdrApplication
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory applicantList = new bytes32[](
            _tdrApplication.applicants.length
        );
        for (uint i = 0; i < _tdrApplication.applicants.length; i++) {
            applicantList[i] = _tdrApplication.applicants[i].userId;
        }
        return applicantList;
    }
    // delete applicatiion from user

    // CRUD operation for zone
    function setZone(bytes32 _applicationId, Zone _zone) public onlyManager {
        require(
            isApplicationCreated(_applicationId),
            "Application is not exist"
        );
        require(_applicationId > 0, "Application ID is greater than 0");
        applicationZoneMap[_applicationId] = _zone;
        emit zoneSet(_applicationId, _zone);
    }

    function getZone(bytes32 _applicationId) public view returns(Zone){
        return applicationZoneMap[_applicationId];
    }

    function deleteZone(bytes32 _applicationId) public onlyAdmin {
        delete applicationZoneMap[_applicationId];
    }

}

