pragma solidity ^0.8.16;

import "./DRC.sol";
import "./UserManager.sol";
import "./Application.sol";
import "./UtilizationApplication.sol";
import "./DataTypes.sol";
import "./nomineeManager.sol";

/**
@title TDR Manager for TDR storage
@author Ras Dwivedi
@notice Manager contract for TDR storage: It implements the business logic for the TDR storage
 */
contract DRCManager{
    // contracts
    DrcStorage public drcStorage;
    UserManager public userManager;
    DrcTransferApplicationStorage public dtaStorage;
    DuaStorage public duaStorage;
    NomineeManager public nomineeManager;


    // Address of the contracts
    address public drcStorageAddress;
    address public userManagerAddress;
    address public dtaStorageAddress;
    address public duaStorageAddress;
    address public nomineeManagerAddress;

// admin address
    address owner;
    address admin;
    address manager;
    address tdrManager;

    event Logger(string log);
    event LogAddress(string addressInfo, address _address);
    event LogBytes(string messgaeInfo, bytes32 _bytes);
    event LogBool(string messageInfo, bool message);
    event LogApplication(string message, TdrApplication application);
    event LogOfficer(string message, KdaOfficer officer);
    event DtaApplicationVerified(KdaOfficer officer, bytes32 applicationId, bytes32[] applicants, bytes32[] buyers);
    event DtaApplicationApproved(KdaOfficer officer, bytes32 applicationId,bytes32[] applicants, bytes32[] buyers);
    event DtaApplicationRejected(bytes32 applicationId, string reason, bytes32[] applicants, bytes32[] buyers);
    event DuaSigned(bytes32 applicationId, bytes32 signer, bytes32[] applicants);
    event DuaApproved(bytes32 applicationId, bytes32[] applicants);
    event DtaCreated(bytes32 drcId, bytes32 applicationId, uint far, bytes32[] applicants, bytes32[] buyers);
    event DtaSigned(bytes32 applicationId, bytes32 signer, bytes32[] applicants);
    event DtaSubmitted (bytes32 applicationId, bytes32[] applicants, bytes32[] buyers);
    event DrcIssuedByTransfer(bytes32 applicationId, bytes32[] applicants, bytes32[] buyers);
    event DuaCreated(bytes32 applicationId, uint far, bytes32[] applicants);

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
        require(msg.sender == admin || msg.sender == owner, "Only the admin or owner can perform this action.");
        _;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager, admin, or owner can perform this action.");
        _;
    }
    modifier onlyTdrManager() {
        require(msg.sender == tdrManager, "Only the manager, admin, or owner can perform this action.");
        _;
    }

    function setAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function setManager(address _manager) public {
        require (msg.sender == owner ||  msg.sender == admin);
        manager = _manager;
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
    // This function begins the drd transfer application
    function createTransferApplication(bytes32 drcId,bytes32 applicationId, uint far, uint timeStamp,bytes32[] memory buyers) public {
        // check drc exists or not
        require(drcStorage.isDrcCreated(drcId),"DRC not created");
        DRC memory drc = drcStorage.getDrc(drcId);
        // far should be less than available far.
        require(far <= drc.farAvailable, "Transfer area is greater than the available area");
        // add all the owners id from the drc to the mapping

        Signatory[] memory applicants = new Signatory[](drc.owners.length);

        // no user has signed yet
        for(uint i=0; i<drc.owners.length; i++){
            Signatory memory s;
            s.userId = drc.owners[i];
            s.hasUserSigned = false;
            applicants[i]=s;
        }
        dtaStorage.createApplication(applicationId,drcId,far, applicants, buyers, timeStamp, ApplicationStatus.pending);
        signDrcTransferApplication(applicationId);
        drcStorage.addDtaToDrc(drc.id,applicationId);
        emit DtaCreated(drcId,applicationId,far,getApplicantIdsFromApplicants(applicants),buyers);
    }


    // this function is called by the user to approve the transfer
    function signDrcTransferApplication(bytes32 applicationId) public {
        DrcTransferApplication  memory application = dtaStorage.getApplication(applicationId);
        // make sure the user has not signed the transfer
        for (uint i=0;i<application.applicants.length;i++){
            Signatory memory signatory = application.applicants[i];
            if(signatory.userId == userManager.getUserId(msg.sender)){
                require(!signatory.hasUserSigned,"User have already signed the application");
                signatory.hasUserSigned = true;
                emit DtaSigned(applicationId, signatory.userId, application.buyers );

            }
        }
        // user signs the application
        // find out whether all the users have signed
        bool allSignatoriesSign = true;
        for (uint i=0;i<application.applicants.length;i++){
            Signatory memory s = application.applicants[i];
            if(!s.hasUserSigned){
                allSignatoriesSign = false;
                break;
            }
        }
        // if all the signatories has not signed
        if(allSignatoriesSign){
            //all the signatories has signed
            //change the status of the sub-drc
            application.status = ApplicationStatus.submitted;
            emit DtaSubmitted(applicationId,getApplicantIdsFromApplicants(application.applicants), application.buyers);
            // applicationMap[applicationId]=application;
        }
        dtaStorage.updateApplication(application);
    }

    // this function is called by the admin to approve the transfer
    function verifyDrcApplication(bytes32 applicationId) public {
        VerificationStatus memory status = dtaStorage.getVerificationStatus(applicationId);
        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
        emit LogOfficer("Officer in action",officer);
        // fetch application. Reverts if application is not created
        DrcTransferApplication memory dta = dtaStorage.getApplication(applicationId);
        require(dta.status == ApplicationStatus.submitted,"Application is not submitted");
        if (officer.role == Role.SUPER_ADMIN ||
        officer.role== Role.ADMIN ||
        officer.role==Role.VERIFIER ||
            officer.role==Role.VC) {
            status.verified = true;
            status.verifierId = officer.userId;
            status.verifierRole = officer.role;
            // update Application
            dta.status = ApplicationStatus.verified;
            dtaStorage.updateApplication(dta);
            emit DtaApplicationVerified(officer, applicationId, getApplicantIdsFromApplicants(dta.applicants), dta.buyers);
            dtaStorage.storeVerificationStatus(applicationId,status);

        } else {
            emit Logger("User is not authorized");
        }
    }
    // this function is called by the admin to approve the transfer
    function approveDta(bytes32 applicationId) public {
        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
        emit LogOfficer("Officer in action",officer);
        //fetch the application
        DrcTransferApplication  memory application = dtaStorage.getApplication(applicationId);
        //application should not be already approved
        require(application.status != ApplicationStatus.approved,"Application already approved");

        if (officer.role == Role.SUPER_ADMIN || officer.role== Role.ADMIN ||
        officer.role==Role.APPROVER || officer.role==Role.VC) {
            // update Application
            application.status = ApplicationStatus.approved;
            dtaStorage.updateApplication(application);
            emit DtaApplicationApproved(officer, applicationId,getApplicantIdsFromApplicants(application.applicants), application.buyers );
            // one drc transfer is approved, new drc should be created
            genNewDrcFromApplication(application);
        } else {
            emit Logger("User not authorized");
        }
        emit DrcIssuedByTransfer(applicationId, getApplicantIdsFromApplicants(application.applicants), application.buyers);
    }
    /**
    Creates a new DRC from a DRC transfer application
    @dev The function generates a new DRC from a provided DRC transfer application. The new DRC inherits the noticeId from the original DRC and is set as available with the far credited and far available equal to the transferred far. The newDrcOwner array in the application is assigned to the owners of the new DRC.
    @param application The DRC transfer application to create a new DRC from
    */

    function genNewDrcFromApplication(DrcTransferApplication memory application ) internal {
        DRC memory drc = drcStorage.getDrc(application.drcId);
        emit LogBytes("id of the drc fetched in gen new drc is",drc.id);
        emit LogBytes("id of the application fetched in gen new drc is",application.drcId);
        DRC memory newDrc;
        newDrc.id = application.applicationId;
        newDrc.applicationId = application.applicationId;
        newDrc.noticeId = drc.noticeId;
        newDrc.status = DrcStatus.available;
        newDrc.farCredited = application.farTransferred;
        newDrc.farAvailable = application.farTransferred;
        newDrc.owners = application.buyers;
        drcStorage.createDrc(newDrc);
        // need to reduce the available area of the old drc
        drc.farAvailable = drc.farAvailable - application.farTransferred;
        drcStorage.updateDrc(drc.id,drc);
    }

    // this function is called by the admin to reject the transfer
    function rejectDrcTransfer(bytes32 applicationId, string memory reason) public {
        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
        emit LogOfficer("Officer in action",officer);
        // Check if notice is issued
        DrcTransferApplication  memory application = dtaStorage.getApplication(applicationId);
        require(application.status != ApplicationStatus.approved,"Application is already approved");
        require(application.status == ApplicationStatus.submitted,"Application is not yet submitted");

        // No need to check notice, as application can be rejected even when DRC is issued.
        if (officer.role == Role.SUPER_ADMIN || officer.role== Role.ADMIN ||
        officer.role==Role.APPROVER || officer.role==Role.VC) {
            // update Application
            application.status = ApplicationStatus.rejected;
            dtaStorage.updateApplication(application);
            emit DtaApplicationRejected(applicationId, reason, getApplicantIdsFromApplicants(application.applicants), application.buyers);
        } else {
            emit Logger("User not authorized");
        }
    }

    function hasUserSignedDta(bytes32 _applicationId, address _address) public returns (bool){
        DrcTransferApplication memory application = dtaStorage.getApplication(_applicationId);
        require(application.applicationId != "", "Drc transfer application does not exist");
            // Get the user id by the address
        bytes32 userId = userManager.getUserId(_address);

            // Loop through all applicants in the TDR application
        for (uint i = 0; i < application.applicants.length ; i++) {
            Signatory memory signatory = application.applicants[i];
            if (signatory.userId == userId) {
                 return signatory.hasUserSigned;
            }
        }
            // false otherwise
        return false;
    }


    function hasUserSignedDua(bytes32 applicationId, address _address) public returns (bool){
        DUA memory application = duaStorage.getApplication(applicationId);
        require(application.applicationId != "", "Drc transfer application does not exist");
        // Get the user id by the address
        bytes32 userId = userManager.getUserId(_address);

        // Loop through all applicants in the TDR application
        for (uint i = 0; i < application.signatories.length ; i++) {
            Signatory memory signatory = application.signatories[i];
            if (signatory.userId == userId) {
                return signatory.hasUserSigned;
            }
        }
        // false otherwise
        return false;
    }

    function getDta(bytes32 _applicationId) public view returns (DrcTransferApplication memory) {
        // Retrieve the dta from the mapping
        DrcTransferApplication memory application = dtaStorage.getApplication(_applicationId);
        return application;
    }
    function getDua(bytes32 _applicationId) public view returns (DUA memory) {
        // Retrieve the dta from the mapping
        DUA memory application = duaStorage.getApplication(_applicationId);
        return application;
    }
    function getDtaVerificationStatus(bytes32 applicationId) public view returns(bool) {
        VerificationStatus memory status = dtaStorage.getVerificationStatus(applicationId);
        return status.verified;
    }
    // I need to create two different get application method and then merge it
    function getDtaForUser(bytes32 userId) public returns (bytes32[] memory){
        return dtaStorage.getApplicationForUser(userId);
    }
    function getDuaForUser(bytes32 userId) public returns (bytes32[] memory){
        return duaStorage.getApplicationForUser(userId);
    }
    function getDtaIdsForDrc(bytes32 drcId) public returns (bytes32[] memory){
        return drcStorage.getDtaIdsForDrc(drcId);
    }
    function getDuaIdsForDrc(bytes32 drcId) public returns (bytes32[] memory){
        return drcStorage.getDuaIdsForDrc(drcId);
    }
    function getDrc(bytes32 drcId) public returns (DRC memory){
        return drcStorage.getDrc(drcId);
    }
    function getDrcIdsForUser(bytes32 userId) public returns(bytes32[] memory){
        return drcStorage.getDrcIdsForUser(userId);
    }



// what other details, like building application are needed fro utilization application
    function createUtilizationApplication(bytes32 drcId,bytes32 applicationId, uint far, uint timeStamp) public {
        // check drc exists or not
        require(drcStorage.isDrcCreated(drcId),"DRC not created");
        DRC memory drc = drcStorage.getDrc(drcId);
        // far should be less than available far.
        require(far <= drc.farAvailable, "Utilized area is greater than the available area");
        // add all the owners id from the drc to the mapping

       Signatory[] memory duaSignatories = new Signatory[](drc.owners.length);

        // no user has signed yet
        for(uint i=0; i<drc.owners.length; i++){
            Signatory memory s;
            s.userId = drc.owners[i];
            s.hasUserSigned = false;
            duaSignatories[i]=s;
        }
        duaStorage.createApplication(applicationId,drc.id,far,duaSignatories, timeStamp, ApplicationStatus.pending);
        signDrcUtilizationApplication(applicationId);
        drcStorage.addDuaToDrc(drc.id,applicationId);
        emit DuaCreated(applicationId,far,getApplicantIdsFromApplicants(duaSignatories));
    }

    function signDrcUtilizationApplication(bytes32 applicationId) public {
        DUA  memory application = duaStorage.getApplication(applicationId);
        // make sure the user has not signed the transfer
        for (uint i=0;i<application.signatories.length;i++){
            Signatory memory signatory = application.signatories[i];
            if(signatory.userId == userManager.getUserId(msg.sender)){
                require(!signatory.hasUserSigned,"User have already signed the application");
                signatory.hasUserSigned = true;
                emit DuaSigned(applicationId, signatory.userId, getApplicantIdsFromApplicants(application.signatories));
            }
        }
        // user signs the application
        // find out whether all the users have signed
        bool allSignatoriesSign = true;
        for (uint i=0;i<application.signatories.length;i++){
            Signatory memory s = application.signatories[i];
            if(!s.hasUserSigned){
                allSignatoriesSign = false;
                break;
            }
        }
        // if all the signatories has not signed
        if(allSignatoriesSign){
            //all the signatories has signed
            application.status = ApplicationStatus.approved;
            emit DuaApproved(applicationId, getApplicantIdsFromApplicants(application.signatories));
            // reduce drc
        }
        duaStorage.updateApplication(application);
    }

    function getApplicantIdsFromApplicants(Signatory[] memory applicants)
                                        internal view returns(bytes32[] memory) {
        bytes32[] memory applicantList = new bytes32[](applicants.length) ;
        for(uint i=0; i < applicants.length; i++){
            applicantList[i]= applicants[i].userId;
        }
        return applicantList;

    }
    /**
    transfers all drc to the nominee of the user
    deletes the owner from  owner map
    */
    function transferAllDrcToNominees(bytes32 userId) public {
        // check whether the role is admin or application
        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
        emit LogOfficer("Officer in action",officer);
        if (officer.role == Role.SUPER_ADMIN || officer.role== Role.ADMIN ||
        officer.role==Role.APPROVER || officer.role==Role.VC) {
            // fetch all replaceUserByNominees
            bytes32[] memory nominees = nomineeManager.getNominees(userId);
            // fetch all drc id
            bytes32[] memory drcIds = drcStorage.getDrcIdsForUser(userId);
            for (uint i=0; i < drcIds.length; i++){
                transferDrcToNominee(drcIds[i], userId, nominees);
            }
        }else {
            revert("user not authorized");
        }
        drcStorage.deleteDrcIdsOfOwner(userId);
        emit Logger("All drc successfully transferred to nominees");
    }
    event DrcTransferredToNominees(bytes32 drcId, bytes32 userId, bytes32[] nominees);
    /**
    WARNING: This function does not delete the drc from original owner list
    */
    function transferDrcToNominee(bytes32 drcId, bytes32 userId, bytes32[] memory nominees) public {
        //fetch the drc
        DRC memory drc = drcStorage.getDrc(drcId);
        // replace the user with the nominee
        drc.owners = replaceUserByNominees(drc.owners, userId,nominees);
        drcStorage.updateDrc(drcId, drc);
        emit DrcTransferredToNominees(drcId, userId, nominees);
    }
    function replaceUserByNominees(bytes32[] memory owners, bytes32 user, bytes32[] memory nominees) public returns (bytes32[] memory){
        bytes32[] memory ownersWithoutUser = deleteUserFromList(owners,user);
        bytes32[] memory ownersWithNominees = mergeArrays(ownersWithoutUser, nominees);
//        bytes32[] memory ownersWithNominees = mergeArrays(owners, nominees);
        return ownersWithNominees;
    }
    function mergeArrays(bytes32[] memory arr1, bytes32[] memory arr2) public pure returns (bytes32[] memory) {
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
    function deleteUserFromList(bytes32[] memory owners, bytes32 user) public returns (bytes32[] memory){
        uint index = findIndex(owners, user);
        if (index == owners.length){
            revert("user not found in owner list");
        }
        for (uint i=index; i< owners.length-1; i++){
            owners[i]= owners[i+1];
        }
        return deleteLastElement(owners);
    }
    function findIndex(bytes32[] memory arr, bytes32 element) public pure returns(uint) {
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == element) {
                return i;
            }
        }
        return arr.length;
    }
    function deleteLastElement(bytes32[] memory arr) public pure returns (bytes32[] memory){
        bytes32[] memory tempArray = new bytes32[](arr.length -1);
        for (uint i=0; i< tempArray.length; i++){
            tempArray[i]=arr[i];
        }
        return tempArray;
    }

}
