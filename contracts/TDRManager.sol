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
2. UserManager.sol: UserManager manages the users on the blockchain. It keeps the records of the user, issuer, verifier and the approvers on the blockchain.
 */
pragma solidity ^0.8.16;

import "./TDR.sol";
import "./UserManager.sol";

/**
@title TDR Manager for TDR storage
@author Ras Dwivedi
@notice Manager contract for TDR storage: It implements the business logic for the TDR storage
 */
contract TDRManager {
    // Address of the TDR storage contract
    TdrStorage public tdrStorage;
    UserManager public userManager;


    // Address of the contract admin
    address public tdrStorageAddress;
    address public userManagerAddress;
    event ApplicationRejected(bytes32 applicationId, string reason);
    event Logger(string log);
    event LogAddress(string addressInfo, address _address);
    event LogBytes(string messgaeInfo, bytes32 _bytes);
    event LogBool(string messageInfo, bool message);



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

    // Import all the contracts
    // function to add tdrStorage contract 
    function loadTdrStorage(address _tdrStorageAddress) public {
        tdrStorageAddress = _tdrStorageAddress;
        tdrStorage = TdrStorage(tdrStorageAddress);

    }
    // function to update tdrStorage
    function updateTdrStorage(address _tdrStorageAddress) public {
        tdrStorageAddress = _tdrStorageAddress;
        tdrStorage = TdrStorage(_tdrStorageAddress);

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


    // // Function to create a new TDR notice
    // function createNotice(TdrNotice memory _tdrNotice) public {
    //     // Call the TDR storage contract's createNotice function
    //     tdrStorage.createNotice(_tdrNotice);
    // }
    function createNotice(bytes32 _noticeId,uint _noticeDate,  bytes32 _khasraOrPlotNo,  bytes32 _villageOrWard,  bytes32 _Tehsil,  bytes32 _district,  bytes32 _landUse,  bytes32 _masterPlan) public {
        // Call the TDR storage contract's createNotice function
        emit Logger("START: createNotice");

        tdrStorage.createNotice(_noticeId, _noticeDate,  _khasraOrPlotNo,  _villageOrWard,  _Tehsil,  _district,  _landUse,  _masterPlan, NoticeStatus.pending);
        // return _tdrNotice;
    }

    function updateNotice(bytes32 _noticeId,uint _noticeDate,  bytes32 _khasraOrPlotNo,  bytes32 _villageOrWard,  bytes32 _Tehsil,  bytes32 _district,  bytes32 _landUse,  bytes32 _masterPlan, NoticeStatus _status) public {
        // Call the TDR storage contract's createNotice function
        emit Logger("START: updateNotice");

        tdrStorage.updateNotice(_noticeId, _noticeDate,  _khasraOrPlotNo,  _villageOrWard,  _Tehsil,  _district,  _landUse,  _masterPlan, _status);
        // return _tdrNotice;
    }


    /**
    @dev Function to create an application
    @param _tdrApplication TdrApplication memory object representing the application to be created
    @dev Revert if the notice for the application does not exist
    */
    function createApplication(TdrApplication memory _tdrApplication) public {
      emit Logger("STARTED: create application");
        emit LogBytes("Begin create application", _tdrApplication.applicationId);
        // check whether Notice has been created for the application. If not, revert
        TdrNotice memory tdrNotice = tdrStorage.getNotice(_tdrApplication.noticeId);
        // if notice is empty, create notice.
        if(tdrNotice.noticeId==""){
            revert("No such notice has been created");
        }   
        // add application in application map
        tdrStorage.createApplication(_tdrApplication);
        emit Logger("application created in storage");
        // add application in the notice 
        tdrStorage.addApplicationToNotice(_tdrApplication.noticeId,_tdrApplication.applicationId);
        emit Logger("application added to Notice");
        // add user signature to the appliction
//        signTdrApplication(_tdrApplication.applicationId);
//        emit Logger("application signed");
        // who is signing this application
    }

    // This function uses address to see whether the user has signed the application or not
    function hasUserSignedApplication(bytes32 _applicationId,address adrs) public returns(bool){
        TdrApplication memory  application = tdrStorage.getApplication(_applicationId);
        bytes32 userId = userManager.getUserId(adrs);
        for (uint i=0;i<application.applicants.length;i++){
            Signatory memory signatory = application.applicants[i];
            if(signatory.userId==userId) {
                return signatory.hasUserSigned;
            }
        }
        return false;
    }

    // This function uses address to see whether the user has signed the application or not
    function getApplicantsPosition(bytes32 _applicationId,address adrs) public returns(uint){
        TdrApplication memory  application = tdrStorage.getApplication(_applicationId);
        bytes32 userId = userManager.getUserId(adrs);
        for (uint i=0;i<application.applicants.length;i++){
            Signatory memory signatory = application.applicants[i];
            if(signatory.userId==userId) {
                return i+1;
            }
        }
        return 0;
    }

    function getApplication(bytes32 _applicationId) public returns(TdrApplication memory){
        TdrApplication memory  application = tdrStorage.getApplication(_applicationId);
        emit LogApplication("application fetched", application);
        return application;
    }
    event LogApplication(string message, TdrApplication application);
    function signApplication(bytes32 _applicationId) public{
        TdrApplication memory  application = tdrStorage.getApplication(_applicationId);
        bytes32 userId = userManager.getUserId(msg.sender);
        emit LogBytes("modifying application", application.applicationId);
        emit LogApplication("application before modification", application);
        application.applicants[0].hasUserSigned=true;
        emit LogApplication("application before updating to map", application);
        tdrStorage.updateApplication(application);
        emit LogApplication("application after modification", application);
        emit LogBytes("changed status of applicant", application.applicants[0].userId);

        //        for (uint i=0;i<application.applicants.length;i++){
//            Signatory memory signatory = application.applicants[i];
//            if(signatory.userId==userId) {
//                emit LogBool("has user signed", signatory.hasUserSigned);
////                application.applicants[i].hasUserSigned = true;
////                tdrStorage.updateApplication(application);
//            return signatory.hasUserSigned;
//            }
//        }
//        return false;
    }

    // This function takes user consent to create application and then sign it. 
    function signTdrApplication(bytes32 _applicationId) public {
        TdrApplication memory  application = tdrStorage.getApplication(_applicationId);
        // make sure the user has not signed the transfer
        bool isUserFound = false;
        bytes32 userId = userManager.getUserId(msg.sender);
        emit LogBytes("user id from manager is ", userId);
        for (uint i=0;i<application.applicants.length;i++){
                Signatory memory signatory = application.applicants[i];
            // since this is a call in same method, msg.sender is orignal source
            emit LogBytes("signatory user id is ",signatory.userId);
//            emit LogBytes("user id from manager is ", userManager.getIssuerId(msg.sender));
            bool isSame = signatory.userId==userId;
            emit LogBool("Is the signer and user id equal?", isSame);
            if(isSame) {
                emit Logger("the values were same in if loop");
            }
            if(signatory.userId==userId) {
//                require(!signatory.hasUserSigned,"User have already signed the application");
//                application.applicants[i].hasUserSigned = true;
//                emit Logger("user in application was found");
//                isUserFound=true;
                // reflect this change in applicton
            }
        }
//        if(!isUserFound){
//            revert("Signer is not in the applicants list");
//        }
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
            // applicationMap[applicationId]=application;
        }
        tdrStorage.updateApplication(application);
    }

// This function mark the application as verified
    function verifyApplication(bytes32 applicationId) public{
    assert(userManager.isVerifier(msg.sender)|| userManager.isAdmin(msg.sender));
    // get application
    TdrApplication memory tdrApplication = tdrStorage.getApplication(applicationId);
    // ensure that the notice is not finalized
    TdrNotice memory notice = tdrStorage.getNotice(tdrApplication.noticeId);
    if(notice.status == NoticeStatus.issued){
        revert("DRC already issued against this notice");
    }

    // set application status as verified
    tdrApplication.status = ApplicationStatus.verified;
    // update Application
    tdrStorage.updateApplication(tdrApplication);
    }

// This function mark the application as verified
    function rejectApplication(bytes32 applicationId,string memory reason) public {
    assert(userManager.isApprover(msg.sender)||userManager.isVerifier(msg.sender)||userManager.isIssuer(msg.sender)||userManager.isAdmin(msg.sender)); //what about admin
    // get application
    TdrApplication memory tdrApplication = tdrStorage.getApplication(applicationId);
    // No need to check notice, as application can be rejected even when DRC is issued.
    // set application status as verified
    tdrApplication.status = ApplicationStatus.rejected;
    // update Application
    tdrStorage.updateApplication(tdrApplication);
    emit ApplicationRejected(applicationId, reason);
    }

   function approveApplication(bytes32 applicationId) public {
    assert(userManager.isApprover(msg.sender)||userManager.isAdmin(msg.sender));
    // get application
    TdrApplication memory tdrApplication = tdrStorage.getApplication(applicationId);
    // ensure that the notice is not finalized
    TdrNotice memory notice = tdrStorage.getNotice(tdrApplication.noticeId);
    if(notice.status == NoticeStatus.issued){
        revert("DRC already issued against this notice");
    }

    // set application status as verified
    tdrApplication.status = ApplicationStatus.approved;
    // update Application
    tdrStorage.updateApplication(tdrApplication);
    }

// This function mark the application as verified
    function issueDRC(bytes32 applicationId, uint far) public {
    assert(userManager.isIssuer(msg.sender)|| userManager.isAdmin(msg.sender));
    // get application
    TdrApplication memory tdrApplication = tdrStorage.getApplication(applicationId);
    // ensure that the notice is not finalized
    TdrNotice memory notice = tdrStorage.getNotice(tdrApplication.noticeId);
    if(notice.status == NoticeStatus.issued){
        revert("DRC already issued against this notice");
    }

    // set application status as verified
    tdrApplication.status = ApplicationStatus.drcIssued;
    // update FAR in application
    tdrApplication.farGranted=far;
    // set notice as issued
    notice.status = NoticeStatus.issued;
    tdrStorage.updateNotice(notice);

    // update Application
    tdrStorage.updateApplication(tdrApplication);
    // issue DRC
    // drcManager.issueDRC(tdrApplication, far);
    // emit events
    }

}
