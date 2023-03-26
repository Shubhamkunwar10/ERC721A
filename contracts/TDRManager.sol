// SPDX-License-Identifier: UNLICENSED
/**
TDRManager is a contract to manage the TDRs on the blockchain. It offers following functionality
1. Apply for TDR
2. Verify TDR
3. Approved TDR
4. Issue TDR

Owner is the deployer of the contract, and is KDA admin.
Admin is the manager of the contract. Admin key is to be used by the system.
ToDo: look for better name for admin


Contracts imported
1. TDR.sol: It stored the data of the TDR. This contract only implements the business logic layer of the contract
2. UserManager.sol: UserManager manages the users on the blockchain.
    It keeps the records of the user, issuer, verifier and the approvers on the blockchain.
 */
pragma solidity ^0.8.16;

import "./TDR.sol";
import "./UserManager.sol";
import "./DRC.sol";

/**
@title TDR Manager for TDR storage
@author Ras Dwivedi
@notice Manager contract for TDR storage: It implements the business logic for the TDR storage
 */
contract TDRManager {
    // Address of the TDR storage contract
    TdrStorage public tdrStorage;
    UserManager public userManager;
    DrcStorage public drcStorage;

    // Address of the contract admin
    address public tdrStorageAddress;
    address public drcStorageAddress;
    address public userManagerAddress;
    event TdrApplicationRejected(
        bytes32 applicationId,
        string reason,
        bytes32[] applicants
    );
    event Logger(string log);
    event LogAddress(string addressInfo, address _address);
    event LogBytes(string messgaeInfo, bytes32 _bytes);
    event LogBool(string messageInfo, bool message);
    event LogApplication(string message, TdrApplication application);
    event DrcIssued(DRC drc, bytes32[] owners);
    event TdrApplicationSubmitted(bytes32 applicationId, bytes32[] applicants);
    event DrcSubmitted(bytes32 drcId);

    address owner;
    address admin;
    address manager;

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
    modifier onlyNoticeCreator() {
        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
        emit LogOfficer("Officer in action", officer);
        if (officer.role != Role.SUPER_ADMIN && officer.role != Role.ADMIN) {
            revert("Only user with role admin can create notice");
        }
        _;
    }

    function setAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function setManager(address _manager) public {
        require(msg.sender == owner || msg.sender == admin);
        manager = _manager;
    }

    // Import all the contracts
    // function to add tdrStorage contract
    function loadTdrStorage(address _tdrStorageAddress) public {
        tdrStorageAddress = _tdrStorageAddress;
        tdrStorage = TdrStorage(tdrStorageAddress);
    }

    function loadDrcStorage(address _drcStorageAddress) public {
        drcStorageAddress = _drcStorageAddress;
        drcStorage = DrcStorage(drcStorageAddress);
    }

    // function to update tdrStorage
    function updateTdrStorage(address _tdrStorageAddress) public {
        tdrStorageAddress = _tdrStorageAddress;
        tdrStorage = TdrStorage(_tdrStorageAddress);
    }

    function updateDrcStorage(address _drcStorageAddress) public {
        drcStorageAddress = _drcStorageAddress;
        drcStorage = DrcStorage(drcStorageAddress);
    }

    // function to add tdrStorage contract
    function loadUserManager(address _userManagerAddress) public {
        userManagerAddress = _userManagerAddress;
        userManager = UserManager(_userManagerAddress);
    }

    // function to update tdrStorage
    function updateUserManager(address _userManagerAddress) public {
        userManagerAddress = _userManagerAddress;
        userManager = UserManager(_userManagerAddress);
    }

    /**
    @dev Function to create tdr notice
    @param tdrNotice: notice to be created
    @dev Revert if user is not authorized to create notice
    */
    function createNotice(TdrNotice memory tdrNotice) public onlyNoticeCreator {
        emit Logger("START: createNotice");
        tdrStorage.createNotice(tdrNotice);
    }

    /**
    @dev Function to create notice
    @param tdrNotice notice to be updated
    @dev Revert if user is not authorized to create notice
    */
    function updateNotice(TdrNotice memory tdrNotice) public onlyNoticeCreator {
        emit Logger("START: updateNotice");
        tdrStorage.updateNotice(tdrNotice);
    }

    function setZone(bytes32 _applicationId, Zone _zone) public {
        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
        TdrApplication memory application = tdrStorage.getApplication(
            _applicationId
        );

        if (officer.role == Role.ADMIN || officer.role == Role.VC) {
            if (application.applicationId == "") {
                revert("No such application found");
            }
            tdrStorage.setZone(_applicationId, _zone);
        } else {
            revert("User not authorized");
        }
    }

    function getZone(bytes32 _applicationId) public view returns (Zone) {
        TdrApplication memory application = tdrStorage.getApplication(
            _applicationId
        );
        if (application.applicationId == "") {
            revert("No such application found");
        }
        return tdrStorage.getZone(_applicationId);
    }

    /**
    @dev Function to create an application
    @param _tdrApplication TdrApplication memory object representing the application to be created
    @dev Revert if the notice for the application does not exist
    */
    function createApplication(TdrApplication memory _tdrApplication) public {
        emit LogBytes(
            "STARTED create application",
            _tdrApplication.applicationId
        );
        emit LogApplication("application received was ", _tdrApplication);
        // check whether Notice has been created for the application. If not, revert
        TdrNotice memory tdrNotice = tdrStorage.getNotice(
            _tdrApplication.noticeId
        );
        // if notice is empty, create notice.
        if (tdrNotice.noticeId == "") {
            revert("No such notice has been created");
        }

        // Set zone by default as NONE
        tdrStorage.setZone(_tdrApplication.applicationId, Zone.NONE);

        //        // add application in application map
        tdrStorage.createApplication(_tdrApplication);
        emit Logger("application created in storage");
        // add application in the notice
        tdrStorage.addApplicationToNotice(
            _tdrApplication.noticeId,
            _tdrApplication.applicationId
        );
        emit Logger("application added to Notice");
        //        // add user signature to the appliction
        signTdrApplication(_tdrApplication.applicationId);
        emit Logger("application signed by creator");
    }

    /**
     * @dev Function to update an application
     * @param _tdrApplication TdrApplication memory object representing the application to be updated
     * @dev Revert if the notice for the application does not exist
     */
    function updateTdrApplication(
        TdrApplication memory _tdrApplication
    ) public {
        emit LogBytes(
            "STARTED update TDR application",
            _tdrApplication.applicationId
        );
        emit LogApplication("application received was ", _tdrApplication);
        // check whether Notice has been created for the application. If not, revert
        TdrNotice memory tdrNotice = tdrStorage.getNotice(
            _tdrApplication.noticeId
        );
        // if notice is empty, create notice.
        if (tdrNotice.noticeId == "") {
            revert("No such notice has been created");
        }
        TdrApplication memory tdrApplication = tdrStorage.getApplication(
            _tdrApplication.applicationId
        );
        if (tdrApplication.applicationId == "") {
            revert("No such application has been created");
        }
        // application should have status pending or sent back
        require(
            tdrApplication.status == ApplicationStatus.pending ||
                tdrApplication.status ==
                ApplicationStatus.sentBackForCorrection,
            "Application cannot be updated"
        );

        tdrStorage.updateApplication(_tdrApplication);
        emit Logger("application updated in storage");
        // add application in the notice
        tdrStorage.addApplicationToNotice(
            _tdrApplication.noticeId,
            _tdrApplication.applicationId
        );
        emit Logger("application added to Notice");
        signTdrApplication(_tdrApplication.applicationId);
        emit Logger("application signed by creator");
    }

    /**
     * @dev Check if a user has signed a TDR application.
     * @param _applicationId Id of the TDR application
     * @param adrs Address of the user to check
     * @return Boolean indicating if the user has signed the application
     */
    function hasUserSignedApplication(bytes32 _applicationId, address adrs)
        public
        view
        returns (bool)
    {
        // Get the TDR application by its id
        TdrApplication memory application = tdrStorage.getApplication(
            _applicationId
        );
        require(
            application.applicationId != "",
            "TDR application does not exist"
        );

        // Get the user id by the address
        bytes32 userId = userManager.getUserId(adrs);

        // Loop through all applicants in the TDR application
        for (uint256 i = 0; i < application.applicants.length; i++) {
            Signatory memory signatory = application.applicants[i];
            if (signatory.userId == userId) {
                return signatory.hasUserSigned;
            }
        }
        // false otherwise
        return false;
    }

    // This function uses address to see whether the user has signed the application or not
    function getApplicantsPosition(bytes32 _applicationId, address adrs)
        public
        returns (uint256)
    {
        TdrApplication memory application = tdrStorage.getApplication(
            _applicationId
        );
        bytes32 userId = userManager.getUserId(adrs);
        //        emit LogAddress("address quries is ",adrs);
        for (uint256 i = 0; i < application.applicants.length; i++) {
            Signatory memory signatory = application.applicants[i];
            if (signatory.userId == userId) {
                emit LogBytes("user found", userId);
                emit LogAddress("at address", adrs);
                return i + 1;
            }
        }
        return 0;
    }

    function signApplicationAtPos(bytes32 _applicationId, uint256 pos)
        private
        returns (TdrApplication memory)
    {
        if (pos == 0) {
            emit Logger("Applicant not found  in the application");
        }
        TdrApplication memory application = tdrStorage.getApplication(
            _applicationId
        );
        emit LogApplication("application is ", application);
        bytes32 userId = userManager.getUserId(msg.sender);
        Signatory memory applicant = application.applicants[pos - 1];
        if (applicant.userId != userId) {
            revert("user is not sender");
        }
        if (applicant.hasUserSigned) {
            revert("applicant has already signed the application");
        }
        emit LogBytes("modifying application", application.applicationId);
        application.applicants[pos - 1].hasUserSigned = true;
        //        tdrStorage.updateApplication(application);
        emit LogBytes("applicant signed", application.applicants[0].userId);
        return application;
    }

    function getApplication(bytes32 _applicationId)
        public
        returns (TdrApplication memory)
    {
        TdrApplication memory application = tdrStorage.getApplication(
            _applicationId
        );
        emit LogApplication("application fetched", application);
        return application;
    }

    event TdrApplicationSigned(
        bytes32 applicationId,
        bytes32 signerId,
        bytes32[] applicants
    );

    /**
     * @dev Signs the TdrApplication with the given applicationId by the message sender.
     * @param _applicationId The bytes32 representation of the applicationId to be signed.
     */
    function signTdrApplication(bytes32 _applicationId) public {
        // Retrieve the TdrApplication memory object using its applicationId
        TdrApplication memory application = tdrStorage.getApplication(
            _applicationId
        );
        // Get the position of the message sender in the applicants array of the TdrApplication
        uint256 pos = getApplicantsPosition(_applicationId, msg.sender);
        if (pos == 0) {
            emit Logger("ERROR: applicant id not found");
            emit LogAddress("sender is ", msg.sender);
            emit LogBytes(
                "user id for sender is ",
                userManager.getUserId(msg.sender)
            );
            revert("signer is not the part of application");
        }
        //        // Sign the TdrApplication at the given position
        application = signApplicationAtPos(_applicationId, pos);

        // Check if all signatories have signed the TdrApplication
        bool allSignatoriesSign = hasAllUserSignedTdrApplication(application);
        if (allSignatoriesSign) {
            emit Logger("All signatories signed");
            // Mark the TdrApplication as submitted if all signatories have signed
            application.status = ApplicationStatus.SUBMITTED;
            emit TdrApplicationSubmitted(
                _applicationId,
                getApplicantIdsFromTdrApplication(application)
            );
            emit DrcSubmitted(_applicationId);
        }
        // Update the TdrApplication in the tdrStorage
        tdrStorage.updateApplication(application);
        // Emits a log with the final status of the TdrApplication
        emit LogApplication("final status of the application", application);
        //        emit TdrApplicationSigned(_applicationId,
        //                                    application.applicants[pos].userId,
        //                                    getApplicantIdsFromTdrApplication(application));
    }

    /**
     * @dev return whether all the user of the application has signed the application
     * @param application The application to check signature of all applicants
     */
    function hasAllUserSignedTdrApplication(TdrApplication memory application)
        private
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < application.applicants.length; i++) {
            Signatory memory s = application.applicants[i];
            if (!s.hasUserSigned) {
                return false;
            }
        }
        return true;
    }

    // This function mark the application as verified
    function rejectApplication(bytes32 applicationId, string memory reason)
        public
    {
        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
        emit LogOfficer("Officer in action", officer);
        // Check if notice is issued
        TdrApplication memory tdrApplication = tdrStorage.getApplication(
            applicationId
        );
        require(
            tdrApplication.status != ApplicationStatus.APPROVED,
            "Application already approved"
        );
        // No need to check notice, as application can be rejected even when DRC is issued.

        if (
            officer.role == Role.SUPER_ADMIN ||
            officer.role == Role.ADMIN ||
            officer.role == Role.APPROVER ||
            officer.role == Role.VC
        ) {
            if (officer.role == Role.VC) {
                require(
                    tdrApplication.status == ApplicationStatus.SUBMITTED,
                    "Application not in submitted state"
                );
            } if(officer.role == Role.APPROVER){
                require(
                    tdrApplication.status == ApplicationStatus.VERIFIED,
                    "Application not in Approver state"
                );
            }

            tdrApplication.status = ApplicationStatus.REJECTED_DURING_VERIFICATION;
            tdrStorage.updateApplication(tdrApplication);
            emit TdrApplicationRejected(
                applicationId,
                reason,
                getApplicantIdsFromTdrApplication(tdrApplication)
            );
        } else {
            revert("User not authorized");
        }
        // store the reason for rejection of application
    }

    event TdrApplicationApproved(
        KdaOfficer officer,
        bytes32 applicationId,
        bytes32[] applicants
    );

    function approveApplication(bytes32 applicationId) public {
        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
        emit LogOfficer("Officer in action", officer);
        // Check if notice is issued
        TdrApplication memory tdrApplication = tdrStorage.getApplication(
            applicationId
        );

        require(
            tdrApplication.status == ApplicationStatus.VERIFIED,
            "application should be verified before approval"
        );

        TdrNotice memory notice = tdrStorage.getNotice(tdrApplication.noticeId);
        if (notice.status == NoticeStatus.ISSUED) {
            revert("DRC already issued against this notice");
        }
        if (officer.role == Role.ADMIN) {
            if (tdrApplication.status == ApplicationStatus.REJECTED) {
                tdrApplication.status = ApplicationStatus.APPROVED;
            }
        }
        if (
            officer.role == Role.VC
        ) {
            // update Application
            tdrApplication.status = ApplicationStatus.APPROVED;
            tdrStorage.updateApplication(tdrApplication);
            emit TdrApplicationApproved(
                officer,
                applicationId,
                getApplicantIdsFromTdrApplication(tdrApplication)
            );
        } else {
            revert("User not authorized");
        }
    }

    // This function mark the application as verified
    function issueDRC(
        bytes32 applicationId,
        bytes32 newDrcId,
        uint256 farGranted,
        uint256 timeStamp
    ) internal {
        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
        emit LogOfficer("Officer in action", officer);
        // Check if notice is issued
        TdrApplication memory tdrApplication = tdrStorage.getApplication(
            applicationId
        );
        TdrNotice memory notice = tdrStorage.getNotice(tdrApplication.noticeId);
        if (notice.status == NoticeStatus.ISSUED) {
            revert("DRC already issued against this notice");
        }
        if (
            officer.role == Role.SUPER_ADMIN ||
            officer.role == Role.ADMIN ||
            officer.role == Role.VC
        ) {
            // set application status as verified
            tdrApplication.status = ApplicationStatus.DRCISSUED;
            // set notice as issued
            notice.status = NoticeStatus.ISSUED;
            tdrStorage.updateNotice(notice);

            // update Application
            tdrStorage.updateApplication(tdrApplication);
            // issue DRC
            emit Logger("DRC Issue was successful, creating DRC now");
            createDrc(
                tdrApplication,
                farGranted,
                newDrcId,
                timeStamp,
                notice.areaSurrendered,
                notice.circleRateSurrendered
            );
            //             drcManager.issueDRC(tdrApplication, far);
            // emit events
        } else {
            revert("User not authorized");
        }
    }

    function getVerificationStatus(bytes32 applicationId)
        public
        view
        returns (bool)
    {
        VerificationStatus memory status = tdrStorage.getVerificationStatus(
            applicationId
        );
        return status.verified;
    }

    event LogOfficer(string message, KdaOfficer officer);
    event TdrApplicationVerified(
        KdaOfficer officer,
        bytes32 applicationId,
        bytes32[] applicants
    );

    function verifyTdrApplication(bytes32 applicationId) public {
        VerificationStatus memory status = tdrStorage.getVerificationStatus(
            applicationId
        );
        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
        emit LogOfficer("Officer in action", officer);
        // Check if notice is issued
        TdrApplication memory tdrApplication = tdrStorage.getApplication(
            applicationId
        );
        TdrNotice memory notice = tdrStorage.getNotice(tdrApplication.noticeId);
        if (notice.status == NoticeStatus.ISSUED) {
            revert("DRC already issued against this notice");
        }
        if (
            officer.role == Role.VERIFIER || officer.role == Role.SUB_VERIFIER
        ) {
            require(
                officer.zone == tdrStorage.getZone(applicationId),
                "Officer zone needs to be same as application zone"
            );
        }
        if (officer.role == Role.VERIFIER) {
            status.verified = true;
            status.verifierId = officer.userId;
            status.verifierRole = officer.role;

            // update Application
            tdrApplication.status = ApplicationStatus.VERIFIED;
            tdrStorage.updateApplication(tdrApplication);
            emit TdrApplicationVerified(
                officer,
                applicationId,
                getApplicantIdsFromTdrApplication(tdrApplication)
            );
            tdrStorage.storeVerificationStatus(applicationId, status);
        } else if (officer.role == Role.SUB_VERIFIER) {
            if (officer.department == Department.LAND) {
                status.landVerification.isVerified = true;
            } else if (officer.department == Department.PLANNING) {
                status.planningVerification.isVerified = true;
            } else if (officer.department == Department.ENGINEERING) {
                status.engineeringVerification.isVerified = true;
            } else if (officer.department == Department.PROPERTY) {
                status.propertyVerification.isVerified = true;
            } else if (officer.department == Department.SALES) {
                status.salesVerification.isVerified = true;
            } else if (officer.department == Department.LEGAL) {
                status.legalVerification.isVerified = true;
            }
            emit TdrApplicationVerified(
                officer,
                applicationId,
                getApplicantIdsFromTdrApplication(tdrApplication)
            );
            tdrStorage.storeVerificationStatus(applicationId, status);
        } else {
            revert("user not authorized");
        }
    }

    function checkIfAllSubverifiersSigned(
        VerificationStatus memory verificationStatus

    ) internal pure returns (bool) {
        bool allSigned = true;

        // Check the status of each subverifier
        if (!verificationStatus.landVerification.isVerified) {
            allSigned = false;
        }
        if (!verificationStatus.planningVerification.isVerified) {
            allSigned = false;
        }
        if (!verificationStatus.engineeringVerification.isVerified) {
            allSigned = false;
        }
        if (!verificationStatus.propertyVerification.isVerified) {
            allSigned = false;
        }
        if (!verificationStatus.salesVerification.isVerified) {
            allSigned = false;
        }
        if (!verificationStatus.legalVerification.isVerified) {
            allSigned = false;
        }

        return allSigned;
    }

    function getApplicationForUser(bytes32 userId)
        public
        view
        returns (bytes32[] memory)
    {
        return tdrStorage.getApplicationForUser(userId);
    }

    function createDrc(
        TdrApplication memory tdrApplication,
        uint256 farGranted,
        bytes32 newDrcId,
        uint256 timeStamp,
        uint256 areaSurrendered,
        uint256 circleRateSurrendered
    ) public {
        // from the approved application, it creates a drc
        DRC memory drc;
        drc.id = newDrcId;
        drc.noticeId = tdrApplication.noticeId;
        drc.status = DrcStatus.AVAILABLE;
        drc.farCredited = farGranted;
        drc.farAvailable = farGranted;
        drc.areaSurrendered = areaSurrendered; // change it to get the value from notice
        drc.circleRateSurrendered = circleRateSurrendered; // get it from application
        drc.circleRateUtilization = tdrApplication.circleRateUtilized; // get from application
        drc.applicationId = tdrApplication.applicationId;
        drc.owners = new bytes32[](tdrApplication.applicants.length);
        drc.timeStamp = timeStamp;
        for (uint256 i = 0; i < tdrApplication.applicants.length; i++) {
            drc.owners[i] = tdrApplication.applicants[i].userId;
        }
        drcStorage.createDrc(drc);
        emit Logger("issuing DRC without storing");
        emit DrcIssued(drc, getApplicantIdsFromTdrApplication(tdrApplication));
    }

    function getTdrNotice(bytes32 noticeId)
        public
        view
        returns (TdrNotice memory)
    {
        return tdrStorage.getNotice(noticeId);
    }

    /*
    Returns the tdrApplicationIds for notice id
    */
    function getTdrApplicationsIdsForTdrNotice(bytes32 noticeId)
        public
        view
        returns (bytes32[] memory)
    {
        return tdrStorage.getApplicationsForNotice(noticeId);
    }

    function getApplicantIdsFromTdrApplication(
        TdrApplication memory _tdrApplication
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory applicantList = new bytes32[](
            _tdrApplication.applicants.length
        );
        for (uint256 i = 0; i < _tdrApplication.applicants.length; i++) {
            applicantList[i] = _tdrApplication.applicants[i].userId;
        }
        return applicantList;
    }
}
