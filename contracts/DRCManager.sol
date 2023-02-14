pragma solidity ^0.8.16;

import "./DRC.sol";
import "./UserManager.sol";
import "./Application.sol";
import "./UtilizationApplication.sol";
import "./DataTypes.sol";

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


    // Address of the contracts
    address public drcStorageAddress;
    address public userManagerAddress;
    address public dtaStorageAddress;
    address public duaStorageAddress;

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


    // This function begins the drd transfer application
    function createTransferApplication(bytes32 drcId,bytes32 applicationId, uint far, DrcOwner[] memory newDrcOwners) public {
        // check drc exists or not
        require(drcStorage.isDrcCreated(drcId),"DRC not created");
        DRC memory drc = drcStorage.getDrc(drcId);
        // far should be less than available far.
        require(far <= drc.farAvailable, "Transfer area is greater than the available area");
        // add all the owners id from the drc to the mapping

        Signatory[] memory dtaSignatories = new Signatory[](drc.owners.length);

        // no user has signed yet
        for(uint i=0; i<drc.owners.length; i++){
            Signatory memory s;
            s.userId = drc.owners[i].userId;
            s.hasUserSigned = false;
            dtaSignatories[i]=s;
        }
        signDrcTransferApplication(applicationId);
        dtaStorage.createApplication(applicationId,drcId,far,dtaSignatories, newDrcOwners, ApplicationStatus.pending);
        addApplicationToDrc(drc.id,applicationId,far);
    }

    // this function is called by the user to approve the transfer
    function signDrcTransferApplication(bytes32 applicationId) public {
        DrcTransferApplication  memory application = dtaStorage.getApplication(applicationId);
        // make sure the user has not signed the transfer
        for (uint i=0;i<application.signatories.length;i++){
            Signatory memory signatory = application.signatories[i];
            if(signatory.userId == userManager.getUserId(msg.sender)){
                require(!signatory.hasUserSigned,"User have already signed the application");
                signatory.hasUserSigned = true;
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
            //change the status of the sub-drc
            application.status = ApplicationStatus.submitted;
            // applicationMap[applicationId]=application;
        }
        dtaStorage.updateApplication(application);
    }

    // this function is called by the admin to approve the transfer
    function verifyDta(bytes32 applicationId) public {
//        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
//        emit LogOfficer("Officer in action",officer);
//        if (officer.role == Role.SUPER_ADMIN ||
//        officer.role== Role.ADMIN ||
//        officer.role==Role.VERIFIER ||
//            officer.role==Role.VC) {
//            //
//        }

        require(msg.sender == admin,"Only admin can approve the Transfer");
        DrcTransferApplication  memory application = dtaStorage.getApplication(applicationId);
        require(application.status != ApplicationStatus.approved,"Application already approved");
        require(application.status == ApplicationStatus.submitted,"Application is not submitted");
        // change the status of the application
        application.status = ApplicationStatus.approved;
        dtaStorage.updateApplication(application);
        // add the new drc
        DRC memory drc = drcStorage.getDrc(application.drcId);
        DRC memory newDrc;
        newDrc.id = applicationId;
        newDrc.noticeId = drc.noticeId;
        newDrc.status = DrcStatus.available;
        newDrc.farCredited = application.farTransferred;
        newDrc.farAvailable = application.farTransferred;
        newDrc.owners = application.newDrcOwner;
        drcStorage.createDrc(newDrc);
    }
    // this function is called by the admin to approve the transfer
    function drcTransferApproveAdmin(bytes32 applicationId) public {
        require(msg.sender == admin,"Only admin can approve the Transfer");
        DrcTransferApplication  memory application = dtaStorage.getApplication(applicationId);
        require(application.status != ApplicationStatus.approved,"Application already approved");
        require(application.status == ApplicationStatus.submitted,"Application is not submitted");
        // change the status of the application
        application.status = ApplicationStatus.approved;
        dtaStorage.updateApplication(application);
        // add the new drc
       DRC memory drc = drcStorage.getDrc(application.drcId);
        DRC memory newDrc;
        newDrc.id = applicationId;
        newDrc.noticeId = drc.noticeId;
        newDrc.status = DrcStatus.available;
        newDrc.farCredited = application.farTransferred;
        newDrc.farAvailable = application.farTransferred;
        newDrc.owners = application.newDrcOwner;
        drcStorage.createDrc(newDrc);
    }

    // this function is called by the admin to reject the transfer
    function drcTransferReject(bytes32 applicationId) public {
        require(msg.sender == admin,"Only admin can reject the Transfer");
        DrcTransferApplication  memory application = dtaStorage.getApplication(applicationId);
        require(application.status != ApplicationStatus.approved,"Application is already approved");        
        require(application.status == ApplicationStatus.submitted,"Application is not yet submitted");

        // change the status of the application
        application.status = ApplicationStatus.rejected;
        dtaStorage.updateApplication(application);
        // applicationMap[applicationId]=application;
        // change the status of the sub-drc
        DRC memory drc = drcStorage.getDrc(application.drcId);
        drc.farAvailable = drc.farAvailable+application.farTransferred;
        drcStorage.updateDrc(drc.id,drc);
    }

// what other details, like building application are needed fro utilization application
 function createUtilizationApplication(bytes32 drcId,bytes32 applicationId, uint far) public {
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
            s.userId = drc.owners[i].userId;
            s.hasUserSigned = false;
            duaSignatories[i]=s;
        }
        drcUtilizationApprove(applicationId);
        duaStorage.createApplication(applicationId,drc.id,far,duaSignatories,ApplicationStatus.pending);
        addApplicationToDrc(drc.id,applicationId,far);
    }

   function drcUtilizationApprove(bytes32 applicationId) public {
        DUA  memory application = duaStorage.getApplication(applicationId);
        // make sure the user has not signed the transfer
        for (uint i=0;i<application.signatories.length;i++){
            Signatory memory signatory = application.signatories[i];
            if(signatory.userId == userManager.getUserId(msg.sender)){
                require(!signatory.hasUserSigned,"User have already signed the application");
                signatory.hasUserSigned = true;
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
        }
        duaStorage.updateApplication(application);
     
    }

    function addApplicationToDrc(bytes32 drcId,bytes32 applicationId, uint farConsumed) internal {
        DRC memory drc = drcStorage.getDrc(drcId);
        drc.farAvailable = drc.farAvailable - farConsumed;
        bytes32[] memory newApplications = new bytes32[](drc.applications.length+1);
        for (uint i=0; i< drc.applications.length; i++){
            newApplications[i]=drc.applications[i];
        }
        newApplications[drc.applications.length]=applicationId;
        drcStorage.updateDrc(drc.id,drc);

    }

}
