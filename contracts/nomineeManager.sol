//SPDX-License-Identifier: UNLICENSED

/**

UserManager contract is used to map user id to user address, and to manage verifier, approver and issuer addresses.
The contract owner and admin have the authority to update user, verifier, approver and issuer addresses.
*/
pragma solidity ^0.8.16;
import "./DataTypes.sol";
import "./UserManager.sol";
import "./nomineeStorage.sol";
import "./KdaCommon.sol";

contract NomineeManager is KdaCommon{
//    mapping
    mapping(bytes32 => nomineeApplication) public nomineeApplicationMap;

    address public userManagerAddress;
    UserManager public userManager;

    address public nomineeStorageAddress;
    NomineeStorage public nomineeStorage;

    
    event LogOfficer(string message, KdaOfficer officer);

    event NomineeApplicationApproved(bytes32 applicationId, bytes32 applicant);
    event NomineeApplicationRejected(bytes32 applicationId, bytes32 applicant);
    /**
    * @dev Constructor function to set the initial values of the contract.
     * @param _admin The address of the contract admin.
     * @param _manager The address of the TDR manager.
     */

   // Constructor function to set the initial values of the contract
    constructor(address _admin,address _manager) KdaCommon(_admin,_manager) {}

    function loadUserManager(address _userManagerAddress) public {
        userManagerAddress = _userManagerAddress;
        userManager = UserManager(userManagerAddress);
    }

    function updateUserManager(address _userManagerAddress) public {
        userManagerAddress = _userManagerAddress;
        userManager = UserManager(userManagerAddress);
    }

    function loadNomineeStorage(address _nomineeStorageAddress) public {
        nomineeStorageAddress = _nomineeStorageAddress;
        nomineeStorage = NomineeStorage(nomineeStorageAddress);
    }

    function updateNomineeStorage(address _nomineeStorageAddress) public {
        nomineeStorageAddress = _nomineeStorageAddress;
        nomineeStorage = NomineeStorage(nomineeStorageAddress);
    }


    /**
    1. function to allow user to add and update nominee
    2. function to allow admin to add nominee,
    3. function to allow admin to approve nominee
    4. function to allow admin to transfer users drc to nominee


    */

    function addNomineeApplication(bytes32 applicationId, bytes32[] memory _nominees) public {
        if (nomineeStorage.isApplicationCreated(applicationId)){
            revert("application already created");
        }
        bytes32 userId = userManager.getUserId(msg.sender);
        nomineeApplication memory newApplication = nomineeApplication({
        applicationId: applicationId,
        userId: userId,
        nominees: _nominees,
        status: ApplicationStatus.SUBMITTED
        });
        nomineeStorage.createNomineeApplication(newApplication);
        // emit addNomineeApplicationSubmitted(applicationId, userId);
    }

    // function updateNomineeApplication(bytes32 applicationId, bytes32[] memory _nominees) public {
    //     if (!nomineeStorage.isApplicationCreated(applicationId)){
    //         revert("application does not exist");
    //     }
    //     nomineeApplication memory oldApplication = nomineeStorage.getNomineeApplication(applicationId);
    //     if(oldApplication.status==ApplicationStatus.REJECTED) {
    //         revert("application already rejected");
    //     }
    //     if(oldApplication.status==ApplicationStatus.APPROVED) {
    //         revert("application already approved");
    //     }
    //     bytes32 userId = userManager.getUserId(msg.sender);
    //     nomineeApplication memory newApplication = nomineeApplication({
    //     applicationId: applicationId,
    //     userId: userId,
    //     nominees: _nominees,
    //     status: ApplicationStatus.SUBMITTED
    //     });
    //     nomineeStorage.updateNomineeApplication(newApplication);
    //     emit updateNomineeApplicationSubmitted(applicationId, userId);
    // }

    /**
    This function has to be called by the admin. He would create an approve the application at the same time
    */
    function addNomineeByAdmin(bytes32 applicationId, bytes32 userId,bytes32[] memory _nominees) public {
        if (nomineeStorage.isApplicationCreated(applicationId)){
            revert("application already created");
        }
        nomineeApplication memory newApplication = nomineeApplication({
        applicationId: applicationId,
        userId: userId,
        nominees: _nominees,
        status: ApplicationStatus.SUBMITTED
        });
        nomineeStorage.createNomineeApplication(newApplication);
        approveNomineeApplication(applicationId);
        // emit addNomineeApplicationSubmitted(applicationId, userId);
        // nomineeStorage.addNominee(newApplication.applicationId, newApplication.nominees);
    }
    function approveNomineeApplication(bytes32 applicationId) public {
        KdaOfficer memory officer = userManager.getOfficerByAddress(msg.sender);
        //fetch the application
        nomineeApplication memory application = nomineeStorage.getNomineeApplication(applicationId);
        //application should not be already approved
        require(application.status != ApplicationStatus.APPROVED,"Application already approved");
        require(application.status != ApplicationStatus.REJECTED,"Application already rejected");
        require(application.status == ApplicationStatus.SUBMITTED,"Application is not submitted");
        if (userManager.ifOfficerHasRole(officer, Role.ADMIN)){
                application.status = ApplicationStatus.APPROVED;
                nomineeStorage.updateNomineeApplication(application);
                emit NomineeApplicationApproved(applicationId, application.userId);
            } else {
                revert("User not authorized");
            }
        nomineeStorage.addNominee(application.userId, application.nominees);
    }
    function rejectNomineeApplication(bytes32 applicationId) public {
        KdaOfficer memory officer = userManager.getOfficerByAddress(msg.sender);
        //fetch the application
        nomineeApplication memory application = nomineeStorage.getNomineeApplication(applicationId);
        //application should not be already approved
        require(application.status != ApplicationStatus.APPROVED,"Application already approved");
        require(application.status != ApplicationStatus.REJECTED,"Application already rejected");
        require(application.status == ApplicationStatus.SUBMITTED,"Application is not submitted");


    if (userManager.ifOfficerHasRole(officer, Role.ADMIN)) {
            // update Application
            application.status = ApplicationStatus.REJECTED;
            nomineeStorage.updateNomineeApplication(application);
            emit NomineeApplicationRejected(applicationId, application.userId);
        } else {
            revert("User not authorized");
        }
    }
    function getNominees(bytes32 userId) public view returns (bytes32[] memory){
        return nomineeStorage.getNominees(userId);
    }
    function getApplication(bytes32 applicationId) public view returns(nomineeApplication memory){
        return nomineeStorage.getNomineeApplication(applicationId);
    }

}
