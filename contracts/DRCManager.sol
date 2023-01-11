pragma solidity ^0.8.16;

import "./DRC.sol";
import "./UserManager.sol";
import "./Application.sol";
import "./UtilizationApplication.sol";

/**
@title TDR Manager for TDR storage
@author Ras Dwivedi
@notice Manager contract for TDR storage: It implements the business logic for the TDR storage
 */
contract DRCManager{
    // Address of the TDR storage contract
    DrcStorage public drcStorage;
    UserManager public userManager;
    DrcTransferApplicationStorage public dtaStorage;
    DuaStorage public duaStorage;
    enum ApplicationStatus {pending, submitted, approved, rejected}

    // Address of the contract admin
    address public admin;
    address public drcStorageAddress;
    address public userManagerAddress;
// Inserts usual admin level stuff
    
    // This function begins the drd transfer application
    function createTransferApplication(bytes32 drcId,bytes32 applicationId, uint far, DrcStorage.DrcOwner[] memory newDrcOwners) public {
        // check drc exists or not
        require(drcStorage.isDrcCreated(drcId),"DRC not created");
        DrcStorage.DRC memory drc = drcStorage.getDrc(drcId);
        // far should be less than available far.
        require(far <= drc.farAvailable, "Transfer area is greater than the available area");
        // add all the owners id from the drc to the mapping

        DrcTransferApplicationStorage.Signatory[] memory dtaSignatories = new DrcTransferApplicationStorage.Signatory[](drc.owners.length);

        // no user has signed yet
        for(uint i=0; i<drc.owners.length; i++){
            DrcTransferApplicationStorage.Signatory memory s;
            s.userId = drc.owners[i].id;
            s.hasUserSigned = false;
            dtaSignatories[i]=s;
        }

        dtaStorage.createApplication(applicationId,drcId,far,dtaSignatories, newDrcOwners, DrcTransferApplicationStorage.Status.pending);

        
        //########
        // drc.applications.push(applicationId);
        drc.farAvailable = drc.farAvailable-far;

    }

    // this function is called by the user to approve the transfer
    function drcTransferApprove(bytes32 applicationId) public {
        DrcTransferApplicationStorage.DrcTransferApplication  memory application = dtaStorage.getApplication(applicationId);
        // make sure the user has not signed the transfer
        for (uint i=0;i<application.signatories.length;i++){
            DrcTransferApplicationStorage.Signatory memory signatory = application.signatories[i];
            if(signatory.userId == userManager.getId(msg.sender)){
                require(!signatory.hasUserSigned,"User have already signed the application");
                signatory.hasUserSigned = true;
            }
        }
        // user signs the application
        // find out whether all the users have signed
        bool allSignatoriesSign = true;
        for (uint i=0;i<application.signatories.length;i++){
            DrcTransferApplicationStorage.Signatory memory s = application.signatories[i];
            if(!s.hasUserSigned){
                allSignatoriesSign = false;
                break;
            }
        }
        // if all the signatories has not signed
        if(allSignatoriesSign){
            //all the signatories has signed
            //change the status of the sub-drc
            application.status = DrcTransferApplicationStorage.Status.submitted;
            // applicationMap[applicationId]=application;
        }
        dtaStorage.updateApplication(application);
    }

    // this function is called by the admin to approve the transfer
    function drcTransferApproveAdmin(bytes32 applicationId) public {
        require(msg.sender == admin,"Only admin can approve the Transfer");
        DrcTransferApplicationStorage.DrcTransferApplication  memory application = dtaStorage.getApplication(applicationId);
        require(application.status != DrcTransferApplicationStorage.Status.approved,"Application already approved");
        require(application.status == DrcTransferApplicationStorage.Status.submitted,"Application is not submitted");
        // change the status of the application
        application.status = DrcTransferApplicationStorage.Status.approved;
        dtaStorage.updateApplication(application);
        // add the new drc
       DrcStorage.DRC memory drc = drcStorage.getDrc(application.drcId);
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
        DrcTransferApplicationStorage.DrcTransferApplication  memory application = dtaStorage.getApplication(applicationId);
        require(application.status != DrcTransferApplicationStorage.Status.approved,"Application is already approved");        
        require(application.status == DrcTransferApplicationStorage.Status.submitted,"Application is not yet submitted");

        // change the status of the application
        application.status = DrcTransferApplicationStorage.Status.rejected;
        dtaStorage.updateApplication(application);
        // applicationMap[applicationId]=application;
        // change the status of the sub-drc
        DrcStorage.DRC memory drc = drcStorage.getDrc(application.drcId);
        drc.farAvailable = drc.farAvailable+application.farTransferred;
        drcStorage.updateDrc(drc.id,drc);
    }

// what other details, like building application are needed fro utilization application
 function createUtilizationApplication(bytes32 drcId,bytes32 applicationId, uint far) public {
        // check drc exists or not
        require(drcStorage.isDrcCreated(drcId),"DRC not created");
        DrcStorage.DRC memory drc = drcStorage.getDrc(drcId);
        // far should be less than available far.
        require(far <= drc.farAvailable, "Utilized area is greater than the available area");
        // add all the owners id from the drc to the mapping

       DuaStorage.Signatory[] memory duaSignatories = new DuaStorage.Signatory[](drc.owners.length);

        // no user has signed yet
        for(uint i=0; i<drc.owners.length; i++){
            DuaStorage.Signatory memory s;
            s.userId = drc.owners[i].id;
            s.hasUserSigned = false;
            duaSignatories[i]=s;
        }



        duaStorage.createApplication(applicationId,drc.id,far,duaSignatories,DuaStorage.Status.pending);
 
        drc.farAvailable = drc.farAvailable-far;


    }

   function drcUtilizationApprove(bytes32 applicationId) public {
        DuaStorage.DUA  memory application = duaStorage.getApplication(applicationId);
        // make sure the user has not signed the transfer
        for (uint i=0;i<application.signatories.length;i++){
            DuaStorage.Signatory memory signatory = application.signatories[i];
            if(signatory.userId == userManager.getId(msg.sender)){
                require(!signatory.hasUserSigned,"User have already signed the application");
                signatory.hasUserSigned = true;
            }
        }
        // user signs the application
        // find out whether all the users have signed
        bool allSignatoriesSign = true;
        for (uint i=0;i<application.signatories.length;i++){
            DuaStorage.Signatory memory s = application.signatories[i];
            if(!s.hasUserSigned){
                allSignatoriesSign = false;
                break;
            }
        }
        // if all the signatories has not signed
        if(allSignatoriesSign){
            //all the signatories has signed
            application.status = DuaStorage.Status.approved;
        }
        duaStorage.updateApplication(application);
     
    }


}