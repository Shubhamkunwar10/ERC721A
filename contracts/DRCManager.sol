pragma solidity ^0.8.16;

import "./DRC.sol";
import "./UserManager.sol";

/**
@title TDR Manager for TDR storage
@author Ras Dwivedi
@notice Manager contract for TDR storage: It implements the business logic for the TDR storage
 */
contract DRCManager{
    // Address of the TDR storage contract
    DrcStorage public drcStorage;
    UserManager public userManager;
    enum ApplicationStatus {pending, submitted, approved, rejected}

    struct DrcTransferApplication {
        bytes32 id;
        bytes32 drcId;
        uint farTransferred;
        Signatory[] signatories;
        DrcStorage.DrcOwner[] newDrcOwner;
        ApplicationStatus status;
        
    }
    struct Signatory {
        bytes32 userId;
        bool hasUserSigned;
    }

    mapping (bytes32 => DrcTransferApplication) public applicationMap;

    // Address of the contract admin
    address public admin;
    address public drcStorageAddress;
    address public userManagerAddress;
// Inserts usual admin level stuff
    
    // This function begins the drd transfer application
    function drcTransferInit(bytes32 drcId,bytes32 applicationId, uint far, DrcStorage.DrcOwner[] memory newDrcOwners) public {
        // check drc exists or not
        require(drcStorage.isDrcCreated(drcId),"DRC not created");
        DrcStorage.DRC memory drc = drcStorage.getDrc(drcId);
        // far should be less than available far.
        require(far <= drc.farAvailable, "Transfer area is greater than the available area");
        // add all the owners id from the drc to the mapping
        DrcTransferApplication storage application = applicationMap[applicationId];
        application.id = applicationId;
        application.drcId = drcId;

        for(uint i=0; i<drc.owners.length; i++){
            Signatory memory s;
            s.userId = drc.owners[i].id;
            if(userManager.getId(msg.sender)==drc.owners[i].id){
                s.hasUserSigned=true;
            } else {
                s.hasUserSigned = false;
            }
            application.signatories.push(s);
        }
        for (uint i=0; i< newDrcOwners.length;i++){
            application.newDrcOwner.push(newDrcOwners[i]);
        }
        application.status = ApplicationStatus.pending;
        applicationMap[applicationId]=application;
        uint sNo = drc.subDrcs.length;
        DrcStorage.SubDrc memory subDrc;
        subDrc.sNo = sNo+1;
        subDrc.far = far;
        subDrc.status = DrcStorage.SubDrcStatus.locked_for_transfer;
        subDrc.linkedDrcId = applicationId;
        // drc.subDrcs.push(subDrc); // This statement is not available in memory. so lets create a new subDrc array, and then transfer it to Drc;
        DrcStorage.SubDrc[] memory newSubDrcs = new DrcStorage.SubDrc[](drc.subDrcs.length+1);
        for (uint i=0; i< drc.subDrcs.length; i++){
            newSubDrcs[i]=drc.subDrcs[i];
        }
        newSubDrcs[drc.subDrcs.length]=(subDrc);
        drc.subDrcs = newSubDrcs;
        drc.farAvailable = drc.farAvailable-far;


        // see the caller of the copntract is one of the owner
        // save all the new owners
        // make sure that all the subsequent request have the same data
        //lock the DRC
        // change the signatories of the DRC

    }

    // this function is called by the user to approve the transfer
    function drcTransferApprove(bytes32 applicationId) public {
        DrcTransferApplication storage application = applicationMap[applicationId];
        // make sure the user has not signed the transfer
        for (uint i=0;i<application.signatories.length;i++){
            Signatory memory signatory = application.signatories[i];
            if(signatory.userId == userManager.getId(msg.sender)){
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
            applicationMap[applicationId]=application;
        }
    }

    // this function is called by the admin to approve the transfer
    function drcTransferApproveAdmin(bytes32 applicationId) public {
        require(msg.sender == admin,"Only admin can approve the Transfer");
        DrcTransferApplication storage application = applicationMap[applicationId];
        require(application.status == ApplicationStatus.submitted,"Application is not yet submitted");
        // change the status of the application
        application.status = ApplicationStatus.approved;
        applicationMap[applicationId]=application;
        // change the owner of the new drc
        DrcStorage.SubDrc memory subDrc;
        DrcStorage.DRC memory drc = drcStorage.getDrc(application.drcId);
        
        for (uint i=0;i<drc.subDrcs.length;i++){
            DrcStorage.SubDrc memory sd = drc.subDrcs[i];
            if(sd.linkedDrcId == applicationId){
                sd.status = DrcStorage.SubDrcStatus.transferred;
                subDrc = sd;
                break;
            }
        }
        drc.subDrcs[subDrc.sNo-1] = subDrc;
        drcStorage.updateDrc(drc.id,drc);
     
        // add the new drc
        DrcStorage.DRC memory newDrc;
        newDrc.id = applicationId;
        newDrc.notice = drc.notice;
        newDrc.status = DrcStorage.DrcStatus.available;
        newDrc.farCredited = application.farTransferred;
        newDrc.farAvailable = application.farTransferred;
        newDrc.owners = application.newDrcOwner;
        drcStorage.createDRC(newDrc);
    }

    // this function is called by the admin to reject the transfer
    function drcTransferReject(bytes32 applicationId) public {
        require(msg.sender == admin,"Only admin can reject the Transfer");
        DrcTransferApplication storage application = applicationMap[applicationId];
        require(application.status == ApplicationStatus.submitted,"Application is not yet submitted");
        // change the status of the application
        application.status = ApplicationStatus.rejected;
        applicationMap[applicationId]=application;
        // change the status of the sub-drc
        DrcStorage.DRC memory drc = drcStorage.getDrc(application.drcId);
        for (uint i=0;i<drc.subDrcs.length;i++){
            DrcStorage.SubDrc memory sd = drc.subDrcs[i];
            if(sd.linkedDrcId == applicationId){
                sd.status = DrcStorage.SubDrcStatus.rejected;
                break;
            }
        }
        drc.farAvailable = drc.farAvailable+application.farTransferred;
    }

    // constructor(address _drcStorageAddress, address _userManagerAddress) public {
    //     drcStorageAddress = _drcStorageAddress;
    //     userManagerAddress = _userManagerAddress;
    //     drcStorage = DrcStorage(drcStorageAddress);
    //     userManager = UserManager(userManagerAddress);
    //     admin = msg.sender;
    // }

}