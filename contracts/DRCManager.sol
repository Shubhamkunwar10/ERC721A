// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "./DRC.sol";
import "./UserManager.sol";
import "./Application.sol";
import "./UtilizationApplication.sol";
import "./DataTypes.sol";
import "./nomineeManager.sol";
import "./KdaCommon.sol";
import "./DucStorage.sol";
/**
@title TDR Manager for TDR storage
@author Ras Dwivedi
@notice Manager contract for TDR storage: It implements the business logic for the TDR storage
 */
contract DRCManager is KdaCommon {
    // contracts
    DrcStorage public drcStorage;
    UserManager public userManager;
    DrcTransferApplicationStorage public dtaStorage;
    DuaStorage public duaStorage;
    NomineeManager public nomineeManager;
    DucStorage public ducStorage;

    // Address of the contracts
    address public drcStorageAddress;
    address public userManagerAddress;
    address public dtaStorageAddress;
    address public duaStorageAddress;
    address public nomineeManagerAddress;
    address public ducStorageAddress;

    // admin address
    
    address tdrManager;

    
    event LogOfficer(string message, KdaOfficer officer);
    event DtaVerified(
        KdaOfficer officer,
        bytes32 applicationId,
        bytes32[] applicants,
        bytes32[] buyers
    );
    event DtaSentBack(
        KdaOfficer officer,
        bytes32 applicationId,
        string reason,
        bytes32[] applicants,
        bytes32[] buyers
    );
    event DtaApproved(
        KdaOfficer officer,
        bytes32 applicationId,
        bytes32[] applicants,
        bytes32[] buyers
    );
    event DtaRejected(
        KdaOfficer officer,
        bytes32 applicationId,
        string reason,
        bytes32[] applicants,
        bytes32[] buyers
    );
    event DtaVerificationRejected(
        KdaOfficer officer,
        bytes32 applicationId,
        string reason,
        bytes32[] applicants,
        bytes32[] buyers
    );
    event DuaSigned(
        bytes32 applicationId,
        bytes32 signer,
        bytes32[] applicants
    );
    event DuaApproved(bytes32 applicationId, bytes32[] applicants);
    event DtaCreated(
        bytes32 drcId,
        bytes32 applicationId,
        uint256 far,
        bytes32[] applicants,
        bytes32[] buyers
    );
    event DtaSigned(
        bytes32 applicationId,
        bytes32 signer,
        bytes32[] applicants
    );
    event DtaSubmitted(
        bytes32 applicationId,
        bytes32[] applicants,
        bytes32[] buyers
    );
    event DrcIssuedByTransfer(
        bytes32 applicationId,
        bytes32[] applicants,
        bytes32[] buyers
    );
    event DuaCreated(bytes32 applicationId, uint256 far, bytes32[] applicants);
    event DrcUtilized(bytes32 applicationId, uint256 farUtilized);
    event genDRCFromApplication(DRC application);
    event DrcCancelled(bytes32 drcId, bytes32[] applicants);
   // Constructor function to set the initial values of the contract
    constructor(address _admin,address _manager) KdaCommon(_admin,_manager) {} 

    modifier onlyTdrManager() {
        require(
            msg.sender == tdrManager,
            "Only the manager, admin, or owner can perform this action."
        );
        _;
    }

    function loadDrcStorage(address _drcStorageAddress) public {
        drcStorageAddress = _drcStorageAddress;
        drcStorage = DrcStorage(drcStorageAddress);
    }

    function updateDrcStorage(address _drcStorageAddress) public {
        drcStorageAddress = _drcStorageAddress;
        drcStorage = DrcStorage(drcStorageAddress);
    }

    function loadUserManager(address _userManagerAddress) public {
        userManagerAddress = _userManagerAddress;
        userManager = UserManager(userManagerAddress);
    }

    function updateUserManager(address _userManagerAddress) public {
        userManagerAddress = _userManagerAddress;
        userManager = UserManager(userManagerAddress);
    }

    function loadDtaStorage(address _dtaStorageAddress) public {
        dtaStorageAddress = _dtaStorageAddress;
        dtaStorage = DrcTransferApplicationStorage(dtaStorageAddress);
    }

    function updateDtaStorage(address _dtaStorageAddress) public {
        dtaStorageAddress = _dtaStorageAddress;
        dtaStorage = DrcTransferApplicationStorage(dtaStorageAddress);
    }
    function loadDucStorage(address _ducStorageAddress) public {
        ducStorageAddress = _ducStorageAddress;
        ducStorage = DucStorage(ducStorageAddress);
    }

    function updateDucStorage(address _ducStorageAddress) public {
        ducStorageAddress = _ducStorageAddress;
        ducStorage = DucStorage(ducStorageAddress);
    }



    function loadDuaStorage(address _duaStorageAddress) public {
        duaStorageAddress = _duaStorageAddress;
        duaStorage = DuaStorage(duaStorageAddress);
    }

    function updateDuaStorage(address _duaStorageAddress) public {
        duaStorageAddress = _duaStorageAddress;
        duaStorage = DuaStorage(duaStorageAddress);
    }

    function loadNomineeManager(address _nomineeManagerAddress) public {
        nomineeManagerAddress = _nomineeManagerAddress;
        nomineeManager = NomineeManager(nomineeManagerAddress);
    }

    function updateNomineeManager(address _nomineeManagerAddress) public {
        nomineeManagerAddress = _nomineeManagerAddress;
        nomineeManager = NomineeManager(nomineeManagerAddress);
    }

    // event FarUpdated(
    //     bytes32 indexed drcId,
    //     uint256 indexed farCredited,
    //     uint256 indexed farAvailable
    // );

    function updateFar(
        bytes32 _drcId,
        uint256 _farCredited,
        uint256 _farAvailable
    ) public {
        KdaOfficer memory officer = userManager.getOfficerByAddress(msg.sender);
        if (userManager.isOfficerDrcManager(msg.sender)) {
            DRC memory drc = drcStorage.getDrc(_drcId);
            require(drcStorage.isDrcCreated(_drcId), "DRC not created");
            drc.farCredited = _farCredited;
            drc.farAvailable = _farAvailable;
            drcStorage.updateDrc(_drcId, drc);
            // Since DRC update event is already emitted
            // emit FarUpdated(_drcId, _farCredited, _farAvailable);
        } else {
            revert("Only VC can change the FAR of DRC");
        }
    }

    function addOwnerToDrc(bytes32 _drcId, bytes32[] memory ownerList) public {
        KdaOfficer memory officer = userManager.getOfficerByAddress(msg.sender);

        require(userManager.isOfficerDrcManager(msg.sender), "Only VC can change the owner of DRC");
        for (uint i =0; i < ownerList.length; i++){
            drcStorage.addDrcOwner(_drcId, ownerList[i]);
        }
    }
    function deleteOwnerFromDrc(bytes32 _drcId, bytes32[] memory ownerList) public {
        KdaOfficer memory officer = userManager.getOfficerByAddress(msg.sender);

        require(userManager.isOfficerDrcManager(msg.sender), "Only VC can change the owner of DRC");
        for (uint i =0; i < ownerList.length; i++){
            drcStorage.deleteOwner(_drcId, ownerList[i]);
        }
    }
    // cancel DRC to be done by admin only
    function cancelDrc(bytes32 drcId, string memory reason) public {
        // check whether the role is admin or application
        KdaOfficer memory officer = userManager.getOfficerByAddress(msg.sender);
        emit LogOfficer("Officer in action",officer);
        if(userManager.isOfficerDrcManager(msg.sender)){
            DRC memory drc = drcStorage.getDrc(drcId);
            if (!drcStorage.isDrcCreated(drcId)){
                revert("DRC not creted");
            }
            // increase the available drc count
            drc.status = DrcStatus.CANCELLED;
            drcStorage.updateDrc(drcId,drc);
            emit DrcCancelled(drcId, drc.owners);
            drcStorage.storeDrcCancellationReason(drcId, reason);
        }else {
            revert("user not authorized");
        }
    }
    function getDrcCancellationReason(bytes32 drcId) public returns(string memory){
        return drcStorage.getDrcCancellationReason(drcId);
    }

    // This function begins the drd transfer application

    function createTransferApplication(
        bytes32 drcId,
        bytes32 applicationId,
        uint256 far,
        uint256 timestamp,
        bytes32[] memory buyers,
        bytes32 applicantId
    ) public {
        // check drc exists or not
        // require(drcStorage.isDrcCreated(drcId),"DRC not created");
        DRC memory drc = drcStorage.getDrc(drcId);

        require(drcStorage.isDrcCreated(drcId), "DRC not created");

        // far should be less than available far.
        require(
            far <= drc.farAvailable,
            "Transfer area is greater than the available area"
        );
        // require(drcStorage.isOwnerInDrc(drc,userManager.getOfficerIdByAddress(msg.sender)),"Applicant is not the owner of the DRC");

        // Signatory[] memory applicants = new Signatory[](drc.owners.length);

        if (drc.owners.length <= 0) {
            revert("DRC has 0 owners");
        } else if (buyers.length <= 0) {
            revert("DRC has 0 buyers");
        }

        Signatory[] memory applicants = new Signatory[](drc.owners.length);

        // add all the owners id from the drc to the mapping
        for (uint256 i = 0; i < drc.owners.length; i++) {
            Signatory memory s;
            s.userId = drc.owners[i];
            s.hasUserSigned = false;
            applicants[i] = s;
        }
        dtaStorage.createApplication(
            applicationId,
            drcId,
            far,
            applicants,
            buyers,
            timestamp,
            ApplicationStatus.PENDING,
            applicantId
        );
        // signs the drc transfer application and checks whether all owners have signed it or not
        signDrcTransferApplication(applicationId);
        drcStorage.addDtaToDrc(drc.id, applicationId);
    }

    // this function is called by the user to approve the transfer
    function signDrcTransferApplication(bytes32 applicationId) public {
        DrcTransferApplication memory application = dtaStorage.getApplication(
            applicationId
        );
        bool isUserSignatory = false;
        // make sure the user has not signed the transfer
        for (uint256 i = 0; i < application.applicants.length; i++) {
            Signatory memory signatory = application.applicants[i];
            if (signatory.userId == userManager.getUserId(msg.sender)) {
                isUserSignatory =true;
                require(
                    !signatory.hasUserSigned,
                    "User have already signed the application"
                );
                signatory.hasUserSigned = true;
                emit DtaSigned(
                    applicationId,
                    signatory.userId,
                    application.buyers
                );
            }
        }
        if (isUserSignatory ==false){
            revert("Applicant is not the part of application");
        }
        // user signs the application
        // find out whether all the users have signed
        bool allSignatoriesSign = true;
        for (uint256 i = 0; i < application.applicants.length; i++) {
            Signatory memory s = application.applicants[i];
            if (!s.hasUserSigned) {
                allSignatoriesSign = false;
                break;
            }
        }
        // if all the signatories has not signed
        if (allSignatoriesSign) {
            //all the signatories has signed
            //change the status of the sub-drc
            application.status = ApplicationStatus.SUBMITTED;
            emit DtaSubmitted(
                applicationId,
                getApplicantIdsFromApplicants(application.applicants),
                application.buyers
            );
            // applicationMap[applicationId]=application;
        }
        dtaStorage.updateApplication(application);
    }

    // this function is called by the admin to verify the transfer
        // VerificationStatus memory status = dtaStorage.getVerificationStatus(
        //     applicationId
        // );
    function verifyDTA(bytes32 applicationId) public {
        DtaVerificationStatus memory status = dtaStorage.getVerificationStatus(
            applicationId
        );
        KdaOfficer memory officer = userManager.getOfficerByAddress(msg.sender);
        emit LogOfficer("Officer in action", officer);
        // fetch application. Reverts if application is not created
        DrcTransferApplication memory dta = dtaStorage.getApplication(
            applicationId
        );
        if(dta.status == ApplicationStatus.VERIFIED){
            revert("Application already verified");
        }
        if(dta.status == ApplicationStatus.REJECTED){
            revert("Application already rejected");
        }
        require(
            dta.status == ApplicationStatus.SUBMITTED,
            "Application is not submitted"
        );
        if (userManager.isOfficerDtaVerifier(msg.sender)) {
            status.verified = VerificationValues.VERIFIED;
            status.verifierId = officer.userId;
            // status.verifierRole = officer.role;
            // update Application
            dta.status = ApplicationStatus.VERIFIED;
            dtaStorage.updateApplication(dta);
            emit DtaVerified(
                officer,
                applicationId,
                getApplicantIdsFromApplicants(dta.applicants),
                dta.buyers
            );
            dtaStorage.storeVerificationStatus(applicationId, status);
        } else {
            revert("User not authorized");
        }
    }

    function rejectVerificationDTA(bytes32 applicationId, string memory reason) public {
        DtaVerificationStatus memory status = dtaStorage.getVerificationStatus(
            applicationId
        );
        KdaOfficer memory officer = userManager.getOfficerByAddress(msg.sender);
        emit LogOfficer("Officer in action", officer);
        // fetch application. Reverts if application is not created
        DrcTransferApplication memory dta = dtaStorage.getApplication(
            applicationId
        );
        if(dta.status == ApplicationStatus.VERIFIED){
            revert("Application already verified");
        }
        if(dta.status == ApplicationStatus.REJECTED){
            revert("Application already rejected");
        }
        require(
            dta.status == ApplicationStatus.SUBMITTED,
            "Application is not submitted"
        );
        if (userManager.isOfficerDtaVerifier(msg.sender)) {
            status.verified = VerificationValues.REJECTED;
            status.verifierId = officer.userId;
            // status.verifierRole = officer.role;
            // update Application
            dta.status = ApplicationStatus.REJECTED;
            dtaStorage.updateApplication(dta);
            emit DtaVerificationRejected(
                officer,
                applicationId,
                reason,
                getApplicantIdsFromApplicants(dta.applicants),
                dta.buyers
            );
            dtaStorage.storeVerificationStatus(applicationId, status);
        } else {
            revert("User not authorized");
        }
    }

    function sendBackDTA(bytes32 applicationId, string memory reason) public {
        DtaVerificationStatus memory status = dtaStorage.getVerificationStatus(
            applicationId
        );
        KdaOfficer memory officer = userManager.getOfficerByAddress(msg.sender);
        emit LogOfficer("Officer in action", officer);
        // fetch application. Reverts if application is not created
        DrcTransferApplication memory dta = dtaStorage.getApplication(
            applicationId
        );
        if(dta.status == ApplicationStatus.VERIFIED){
            revert("Application already verified");
        }
        if(dta.status == ApplicationStatus.REJECTED){
            revert("Application already rejected");
        }
        require(
            dta.status == ApplicationStatus.SUBMITTED,
            "Application is not submitted"
        );
        if (userManager.isOfficerDtaVerifier(msg.sender)) {
            status.verified = VerificationValues.SENT_BACK_FOR_CORRECTION;
            status.verifierId = officer.userId;
            // status.verifierRole = officer.role;
            // update Application
            dta.status = ApplicationStatus.SENT_BACK_FOR_CORRECTION;
            dtaStorage.updateApplication(dta);
            emit DtaSentBack(
                officer,
                applicationId,
                reason,
                getApplicantIdsFromApplicants(dta.applicants),
                dta.buyers
            );
            dtaStorage.storeVerificationStatus(applicationId, status);
        } else {
            revert("User not authorized");
        }
    }


    // this function is called by the admin to approve the transfer
    function approveDta(bytes32 applicationId, bytes32 newDrcId) public {
        KdaOfficer memory officer = userManager.getOfficerByAddress(msg.sender);
        emit LogOfficer("Officer in action", officer);
        //fetch the application
        DrcTransferApplication memory application = dtaStorage.getApplication(
            applicationId
        );
        //application should not be already approved
        if(userManager.isOfficerDtaApprover(msg.sender)){
        require(
            application.status == ApplicationStatus.VERIFIED ||
            application.status == ApplicationStatus.REJECTED,
            "Application should be verified or rejected");
        } else if(userManager.isOfficerDtaApprover(msg.sender)){
            require(application.status == ApplicationStatus.VERIFIED);
        } else {
            revert("User not authorized");
        }
        application.status = ApplicationStatus.APPROVED;
        dtaStorage.updateApplication(application);
        emit DtaApproved(
            officer,
            applicationId,
            getApplicantIdsFromApplicants(application.applicants),
            application.buyers
        );
        // one drc transfer is approved, new drc should be created
        genNewDrcFromApplication(application, newDrcId);
        emit DrcIssuedByTransfer(
            applicationId,
            getApplicantIdsFromApplicants(application.applicants),
            application.buyers
        );
    }

    /**
    Creates a new DRC from a DRC transfer application
    @dev The function generates a new DRC from a provided DRC transfer application.
     The new DRC inherits the noticeId from the original DRC and is set as available with the 
     far credited and far available equal to the transferred far.
     The newDrcOwner array in the application is assigned to the owners of the new DRC.
    @param application The DRC transfer application to create a new DRC from
    */

    function genNewDrcFromApplication(
        DrcTransferApplication memory application,
        bytes32 newDrcId
    ) internal {
        DRC memory drc = drcStorage.getDrc(application.drcId);
        emit LogBytes("id of the drc fetched in gen new drc is", drc.id);
        emit LogBytes(
            "id of the application fetched in gen new drc is",
            application.drcId
        );
        DRC memory newDrc;
        newDrc.id = newDrcId;
        newDrc.noticeId = drc.noticeId;
        newDrc.status = DrcStatus.AVAILABLE;
        newDrc.farCredited = application.farTransferred;
        newDrc.farAvailable = application.farTransferred;
        newDrc.owners = application.buyers;
        newDrc.applicationId = application.applicationId;
        newDrc.areaSurrendered = drc.areaSurrendered;
        newDrc.circleRateSurrendered = drc.circleRateSurrendered;
        newDrc.circleRateUtilization = drc.circleRateUtilization;
        newDrc.hasPrevious = true;
        newDrc.previousDRC = drc.id;
        newDrc.timeStamp = block.timestamp;
        drcStorage.createDrc(newDrc);
        // need to reduce the available area of the old drc
        drc.farAvailable = drc.farAvailable - application.farTransferred;
        if (drc.farAvailable == 0) {
            drc.status = DrcStatus.TRANSFERRED;
        }
        drcStorage.updateDrc(drc.id, drc);
        emit genDRCFromApplication(newDrc);
    }

    // this function is called by the admin to reject the transfer
    function rejectDrcTransfer(bytes32 applicationId, string memory reason)
        public
    {
        KdaOfficer memory officer = userManager.getOfficerByAddress(msg.sender);
        emit LogOfficer("Officer in action", officer);
        // Check if notice is issued
        DrcTransferApplication memory application = dtaStorage.getApplication(
            applicationId
        );
        //application should not be already approved
        if(userManager.isOfficerDtaApprover(msg.sender)){
            require(
                application.status == ApplicationStatus.VERIFIED,
                "Only verified applications can be rejected"
            );
        } else {
            revert("User not authorized");
        }
        // No need to check notice, as application can be rejected even when DRC is issued.
            // update Application
        application.status = ApplicationStatus.REJECTED;
        dtaStorage.updateApplication(application);
        emit DtaRejected(
            officer,
            applicationId,
            reason,
            getApplicantIdsFromApplicants(application.applicants),
            application.buyers
        );
    }

    function hasUserSignedDta(bytes32 _applicationId, address _address)
        public
        view
        returns (bool)
    {
        DrcTransferApplication memory application = dtaStorage.getApplication(
            _applicationId
        );
        require(
            application.applicationId != "",
            "Drc transfer application does not exist"
        );
        // Get the user id by the address
        bytes32 userId = userManager.getUserId(_address);

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

    function hasUserSignedDua(bytes32 applicationId, address _address)
        public
        view
        returns (bool)
    {
        DUA memory application = duaStorage.getApplication(applicationId);
        require(
            application.applicationId != "",
            "Drc transfer application does not exist"
        );
        // Get the user id by the address
        bytes32 userId = userManager.getUserId(_address);

        // Loop through all applicants in the TDR application
        for (uint256 i = 0; i < application.signatories.length; i++) {
            Signatory memory signatory = application.signatories[i];
            if (signatory.userId == userId) {
                return signatory.hasUserSigned;
            }
        }
        // false otherwise
        return false;
    }

    function getDta(bytes32 _applicationId)
        public
        view
        returns (DrcTransferApplication memory)
    {
        // Retrieve the dta from the mapping
        DrcTransferApplication memory application = dtaStorage.getApplication(
            _applicationId
        );
        return application;
    }

    function getDua(bytes32 _applicationId) public view returns (DUA memory) {
        // Retrieve the dta from the mapping
        DUA memory application = duaStorage.getApplication(_applicationId);
        return application;
    }

    function getDtaVerificationStatus(bytes32 applicationId)
        public
        view
        returns (DtaVerificationStatus memory)
    {
        DtaVerificationStatus memory status = dtaStorage.getVerificationStatus(
            applicationId
        );
        return status;
//        return (status.verified == VerificationValues.VERIFIED);
    }

    // I need to create two different get application method and then merge it
    function getDtaForUser(bytes32 userId)
        public
        view
        returns (bytes32[] memory)
    {
        return dtaStorage.getApplicationForUser(userId);
    }

    function getDuaForUser(bytes32 userId)
        public
        view
        returns (bytes32[] memory)
    {
        return duaStorage.getApplicationForUser(userId);
    }

    function getDtaIdsForDrc(bytes32 drcId)
        public
        view
        returns (bytes32[] memory)
    {
        return drcStorage.getDtaIdsForDrc(drcId);
    }

    function getDuaIdsForDrc(bytes32 drcId)
        public
        view
        returns (bytes32[] memory)
    {
        return drcStorage.getDuaIdsForDrc(drcId);
    }

    function getDrc(bytes32 drcId) public view returns (DRC memory) {
        return drcStorage.getDrc(drcId);
    }

    function getDrcIdsForUser(bytes32 userId)
        public
        view
        returns (bytes32[] memory)
    {
        return drcStorage.getDrcIdsForUser(userId);
    }


    // what other details, like building application are needed fro utilization application
    function createUtilizationApplication(
        bytes32 drcId,
        bytes32 applicationId,
        uint256 farUtilized,
        uint256 farPermitted,
        uint256 timestamp,
        DrcUtilizationDetails memory drcUtilizationDetails,
        LocationInfo memory locationInfo,
        bytes32 applicantId
    ) public {
        // check drc exists or not
        require(drcStorage.isDrcCreated(drcId), "DRC not created");
        DRC memory drc = drcStorage.getDrc(drcId);

        // farUtilized should be less than available far available.
        require(
            farUtilized <= drc.farAvailable,
            "Utilized area is greater than the available area"
        );
        // add all the owners id from the drc to the mapping

        Signatory[] memory duaSignatories = new Signatory[](drc.owners.length);
        // no user has signed yet
        for (uint256 i = 0; i < drc.owners.length; i++) {
            Signatory memory s;
            s.userId = drc.owners[i];
            s.hasUserSigned = false;
            duaSignatories[i] = s;
        }
        
        duaStorage.createApplication(
            applicationId,
            drc.id,
            farUtilized,
            farPermitted,
            duaSignatories,
            ApplicationStatus.PENDING,
            timestamp,
            drcUtilizationDetails,
            locationInfo,
            applicantId
        );
        signDrcUtilizationApplication(applicationId);
        drcStorage.addDuaToDrc(drc.id, applicationId);
        // emit DuaCreated(
        //     applicationId,
        //     far,
        //     getApplicantIdsFromApplicants(duaSignatories)
        // );
    }

    function signDrcUtilizationApplication(bytes32 applicationId) public {
        DUA memory application = duaStorage.getApplication(applicationId);
        // require application Signatories.length != 0
        require(application.signatories.length != 0, "No signatories found");
        // make sure the user has not signed the transfer
        bool isUserSignatory = false;
        for (uint256 i = 0; i < application.signatories.length; i++) {
            Signatory memory signatory = application.signatories[i];
            if (signatory.userId == userManager.getUserId(msg.sender)) {
                isUserSignatory=true;
                require(
                    !signatory.hasUserSigned,
                    "User have already signed the application"
                );
                signatory.hasUserSigned = true;
                emit DuaSigned(
                    applicationId,
                    signatory.userId,
                    getApplicantIdsFromApplicants(application.signatories)
                );
            }
        }
        if (isUserSignatory==false){
            revert("Applicant is not the part of application");
        }
        // user signs the application
        // find out whether all the users have signed
        bool allSignatoriesSign = true;
        for (uint256 i = 0; i < application.signatories.length; i++) {
            Signatory memory s = application.signatories[i];
            if (!s.hasUserSigned) {
                allSignatoriesSign = false;
                break;
            }
        }
        // if all the signatories has not signed
        if (allSignatoriesSign) {
            //all the signatories has signed
            application.status = ApplicationStatus.APPROVED;
            emit DuaApproved(applicationId, getApplicantIdsFromApplicants(application.signatories));
            // reduce drc once Application is approved, and update the drc
            DRC memory drc = drcStorage.getDrc(application.drcId);
            // need to create unique Id
            createDucFromDrc(drc, application );
        }
        duaStorage.updateApplication(application);
    }

    function getApplicantIdsFromApplicants(Signatory[] memory applicants)
        internal
        view
        returns (bytes32[] memory)
    {
        bytes32[] memory applicantList = new bytes32[](applicants.length);
        for (uint256 i = 0; i < applicants.length; i++) {
            applicantList[i] = applicants[i].userId;
        }
        return applicantList;
    }

    /**
    transfers all drc to the nominee of the user
    deletes the owner from  owner map
    */
    function transferAllDrcToNominees(bytes32 userId) public {
        // check whether the role is admin or application
        KdaOfficer memory officer = userManager.getOfficerByAddress(msg.sender);
        emit LogOfficer("Officer in action", officer);
        require(userManager.isOfficerDrcManager(msg.sender), "Only VC can transfer DRC to nominee");
        // fetch all replaceUserByNominees
        bytes32[] memory nominees = nomineeManager.getNominees(userId);
        // fetch all drc id
        bytes32[] memory drcIds = drcStorage.getDrcIdsForUser(userId);
        for (uint256 i = 0; i < drcIds.length; i++) {
            transferDrcToNominee(drcIds[i], userId, nominees);
        }
        drcStorage.deleteDrcIdsOfOwner(userId);
        emit Logger("All drc successfully transferred to nominees");
    }

    event DrcTransferredToNominees(
        bytes32 drcId,
        bytes32 userId,
        bytes32[] nominees
    );

    /**
    WARNING: This function does not delete the drc from original owner list
    */
    function transferDrcToNominee(
        bytes32 drcId,
        bytes32 userId,
        bytes32[] memory nominees
    ) internal {
        //fetch the drc
        DRC memory drc = drcStorage.getDrc(drcId);
        // replace the user with the nominee
        drc.owners = replaceUserByNominees(drc.owners, userId, nominees);
        drcStorage.updateDrc(drcId, drc);
        emit DrcTransferredToNominees(drcId, userId, nominees);
    }

    function replaceUserByNominees(
        bytes32[] memory owners,
        bytes32 user,
        bytes32[] memory nominees
    ) public returns (bytes32[] memory) {
        bytes32[] memory ownersWithoutUser = deleteUserFromList(owners, user);
        bytes32[] memory ownersWithNominees = mergeArrays(
            ownersWithoutUser,
            nominees
        );
        //        bytes32[] memory ownersWithNominees = mergeArrays(owners, nominees);
        return ownersWithNominees;
    }

    function mergeArrays(bytes32[] memory arr1, bytes32[] memory arr2)
        public
        pure
        returns (bytes32[] memory)
    {
        uint256 arr1Len = arr1.length;
        uint256 arr2Len = arr2.length;
        bytes32[] memory result = new bytes32[](arr1Len + arr2Len);
        uint256 i;
        for (i = 0; i < arr1Len; i++) {
            result[i] = arr1[i];
        }
        for (i = 0; i < arr2Len; i++) {
            result[arr1Len + i] = arr2[i];
        }
        return result;
    }

    function deleteUserFromList(bytes32[] memory owners, bytes32 user)
        public
        returns (bytes32[] memory)
    {
        uint256 index = findIndex(owners, user);
        if (index == owners.length) {
            revert("user not found in owner list");
        }
        for (uint256 i = index; i < owners.length - 1; i++) {
            owners[i] = owners[i + 1];
        }
        return deleteLastElement(owners);
    }

    function findIndex(bytes32[] memory arr, bytes32 element)
        internal
        pure
        returns (uint256)
    {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == element) {
                return i;
            }
        }
        return arr.length;
    }

    function deleteLastElement(bytes32[] memory arr)
        public
        pure
        returns (bytes32[] memory)
    {
        bytes32[] memory tempArray = new bytes32[](arr.length - 1);
        for (uint256 i = 0; i < tempArray.length; i++) {
            tempArray[i] = arr[i];
        }
        return tempArray;
    }

    function createDucFromDrc (DRC memory drc, DUA memory dua) internal {
//uint farPermitted, uint tdrConsumed,DrcUtilizationDetails memory drcUtilizationDetails, bytes32 id) internal{
        DUC memory newDuc;
        newDuc.id = dua.applicationId;
        newDuc.noticeId = drc.noticeId;
        newDuc.farPermitted = dua.farPermitted;
        newDuc.owners = drc.owners;
        newDuc.circleRateSurrendered= drc.circleRateSurrendered;
        newDuc.drcUtilizationDetails = dua.drcUtilizationDetails;
        newDuc.tdrConsumed = dua.farUtilized;
        newDuc.locationInfo = dua.locationInfo;
        ducStorage.createDuc(newDuc);
        // need to reduce the available area of the old drc
        drc.farAvailable = drc.farAvailable - dua.farUtilized;
        if(drc.farAvailable==0){
            drc.status=DrcStatus.UTILIZED;
        }
        drcStorage.updateDrc(drc.id,drc);

    }
    function getDuc(bytes32 id) public returns(DUC memory){
        return ducStorage.getDuc(id);
    }
    function getDucIdsForUser(bytes32 userId) public returns (bytes32[] memory){
        return ducStorage.getDucIdsForUser(userId);
    }
    function linkDucToApplication(bytes32 ducId, bytes32 applicationId) public onlyManager{
        DUC memory duc = ducStorage.getDuc(ducId);
        if (duc.id =="") {
            revert("no such DRC utilization certificate exists");
        }
        if(duc.applicationId !=""){
            emit LogBytes("application already used", duc.applicationId );
            revert("application already used in another application");
        }
        duc.applicationId=applicationId;
        ducStorage.updateDuc(duc);
        ducStorage.addDucToApplication(ducId,applicationId);
    }

    //Aim of this funciton is to get the last 10 DRC from the drc id
    /*
    Aim of this function is to get the last 10 DRC.
    */
    function getDrcHistory(bytes32 currentDrcId) public view returns (DRC[] memory) {
        DRC[] memory history = new DRC[](10); // set maximum history length to 10
        uint i = 0;
        while (currentDrcId != bytes32(0) && i < 10) {
            DRC memory drc = drcStorage.getDrc(currentDrcId);
            history[i] = drc;
            currentDrcId = drc.previousDRC;
            i++;
        }
        return history;
    }

}
