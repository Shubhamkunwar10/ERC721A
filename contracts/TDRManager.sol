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
    event Logger(string s);

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
        // check whether Notice has been created for the application. If not, revert
        TdrNotice memory tdrNotice = tdrStorage.getNotice(_tdrApplication.noticeId);
        // if notice is empty, create notice.
        if(tdrNotice.noticeId==""){
            revert("No such notice has been created");
        }   
        // add application in application map
        tdrStorage.createApplication(_tdrApplication);

        // add application in the notice 
        tdrStorage.addApplicationToNotice(_tdrApplication.noticeId,_tdrApplication.applicationId); 
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
