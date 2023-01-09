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
    address public admin;
    address public tdrStorageAddress;
    address public userManagerAddress;

    // Constructor function to set the initial values of the contract
    constructor(TdrStorage _tdrStorage, address _admin) {
        // Set the TDR storage contract
        tdrStorage = _tdrStorage;

        // Set the contract admin
        admin = _admin;
    }

    // Modifier to check if the caller is the contract admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the contract admin");
        _;
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


    // Function to create a new TDR notice
    function createNotice(TdrStorage.TdrNotice memory _tdrNotice) public {
        // Call the TDR storage contract's createNotice function
        tdrStorage.createNotice(_tdrNotice);
    }

    /**
    @dev Function to create an application
    @param _tdrApplication TdrApplication memory object representing the application to be created
    @dev Revert if the notice for the application does not exist
    */
    function createApplication(TdrStorage.TdrApplication memory _tdrApplication) public {
        // check whether Notice has been created for the application. If not, revert
        TdrStorage.TdrNotice memory tdrNotice = tdrStorage.getNotice(_tdrApplication.noticeId);
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
    TdrStorage.TdrApplication memory tdrApplication = tdrStorage.getApplication(applicationId);
    // ensure that the notice is not finalized
    TdrStorage.TdrNotice memory notice = tdrStorage.getNotice(tdrApplication.noticeId);
    if(notice.status == TdrStorage.NoticeStatus.issued){
        revert("DRC already issued against this notice");
    }

    // set application status as verified
    tdrApplication.status = TdrStorage.ApplicationStatus.verified;
    // update Application
    tdrStorage.updateApplication(tdrApplication);
    }

// This function mark the application as verified
    function rejectApplication(bytes32 applicationId,string memory reason) public {
    assert(userManager.isApprover(msg.sender)||userManager.isVerifier(msg.sender)||userManager.isIssuer(msg.sender)||userManager.isAdmin(msg.sender)); //what about admin
    // get application
    TdrStorage.TdrApplication memory tdrApplication = tdrStorage.getApplication(applicationId);
    // No need to check notice, as application can be rejected even when DRC is issued.
    // set application status as verified
    tdrApplication.status = TdrStorage.ApplicationStatus.rejected;
    // update Application
    tdrStorage.updateApplication(tdrApplication);
    }

   function approveApplication(bytes32 applicationId) public {
    assert(userManager.isApprover(msg.sender)||userManager.isAdmin(msg.sender));
    // get application
    TdrStorage.TdrApplication memory tdrApplication = tdrStorage.getApplication(applicationId);
    // ensure that the notice is not finalized
    TdrStorage.TdrNotice memory notice = tdrStorage.getNotice(tdrApplication.noticeId);
    if(notice.status == TdrStorage.NoticeStatus.issued){
        revert("DRC already issued against this notice");
    }

    // set application status as verified
    tdrApplication.status = TdrStorage.ApplicationStatus.approved;
    // update Application
    tdrStorage.updateApplication(tdrApplication);
    }

// This function mark the application as verified
    function issueDRC(bytes32 applicationId, uint far) public {
    assert(userManager.isIssuer(msg.sender)|| userManager.isAdmin(msg.sender));
    // get application
    TdrStorage.TdrApplication memory tdrApplication = tdrStorage.getApplication(applicationId);
    // ensure that the notice is not finalized
    TdrStorage.TdrNotice memory notice = tdrStorage.getNotice(tdrApplication.noticeId);
    if(notice.status == TdrStorage.NoticeStatus.issued){
        revert("DRC already issued against this notice");
    }

    // set application status as verified
    tdrApplication.status = TdrStorage.ApplicationStatus.issued;
    // update FAR in application
    tdrApplication.farGranted=far;
    // set notice as issued
    notice.status = TdrStorage.NoticeStatus.issued;
    tdrStorage.updateNotice(notice);

    // update Application
    tdrStorage.updateApplication(tdrApplication);
    // issue DRC
    // drcManager.issueDRC(tdrApplication, far);
    // emit events
    }

    // // Function to update a TDR application
    // function updateApplication(TdrApplication memory _tdrApplication) public {
    //     // Call the TDR storage contract's updateApplication function
    //     tdrStorage.updateApplication(_tdrApplication);
    // }

    // // Function to delete a TDR application
    // function deleteApplication(bytes32 _applicationId) public {
    //     // Call the TDR storage contract's deleteApplication function
    //     tdrStorage.deleteApplication(_applicationId);
    // }

    // // Function to change the TDR manager
    // function changeDRCManager(address _newDRCManager) public onlyAdmin {
    //     // Set the new TDR manager
    //     tdrStorage.tdrManager = _newDRCManager;
    // }


    /*
    1. Apply TDR
    2. approve TDR
    3. Approve TDR
    4. Issue DRC
    */
}
