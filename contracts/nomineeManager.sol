//SPDX-License-Identifier: UNLICENSED

/**

UserManager contract is used to map user id to user address, and to manage verifier, approver and issuer addresses.
The contract owner and admin have the authority to update user, verifier, approver and issuer addresses.
*/
pragma solidity ^0.8.16;
import "./DataTypes.sol";
import "./UserManager.sol";
import "./nomineeStorage.sol";

contract NomineeManager {
//    mappun
    mapping(bytes32 => nomineeApplication) public nomineeApplicationMap;

    address owner;
    address admin;
    address manager;


    address public userManagerAddress;
    UserManager public userManager;

    address public nomineeStorageAddress;
    NomineeStorage public nomineeStorage;

    event Logger(string log);
    event LogAddress(string addressInfo, address _address);
    event LogBytes(string messgaeInfo, bytes32 _bytes);
    event LogBool(string messageInfo, bool message);
    event LogApplication(string message, TdrApplication application);
    event LogOfficer(string message, KdaOfficer officer);

    event addNomineeApplicationSubmitted(bytes32 applicationId, bytes32 userId);
    event updateNomineeApplicationSubmitted(bytes32 applicationId, bytes32 userId);
    event NomineeApplicationApproved(bytes32 applicationId, bytes32 userId);
    event NomineeApplicationRejected(bytes32 applicationId, bytes32 userId);
    /**
    * @dev Constructor function to set the initial values of the contract.
     * @param _admin The address of the contract admin.
     * @param _manager The address of the TDR manager.
     */

    constructor(address _admin, address _manager) {
        // Set the contract owner to the caller
        owner = msg.sender;

        // Set the contract admin
        admin = _admin;
        manager = _manager;
    }
    /**
     * @dev Modifier to check if the caller is the TDR manager.
     */    modifier onlyOwner() {
    require(msg.sender == owner, "Caller is not the owner of the contract");
    _;
}
    /**
    * @dev Modifier to check if the caller is the contract admin.
    */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the contract admin");
        _;
    }
    /**
    * @dev Modifier to check if the caller is the contract manager.
    */
    modifier onlyManager() {
        require(msg.sender == manager, "Caller is not the contract manager");
        _;
    }

    /**
    * @dev Updates the address of the contract admin. Can only be called by the owner
     * @param _newAdmin The new address of the contract admin.
     */
    function setAdmin(address _newAdmin) onlyOwner public{
        admin = _newAdmin;
    }

    /**
     * @dev Updates the address of the contract owner. Can only be called by the owner
     * @param _newOwner The new address of the contract owner.
     */
    function setOwner(address _newOwner) onlyOwner public {
        owner = _newOwner;
    }

    /**
     * @dev Updates the address of the TDR manager. Can only be called by the User manager.
     * @param _newManager The new address of the TDR manager.
     */
    function setManager(address _newManager) onlyOwner public {
        manager = _newManager;
    }
    /**
* @dev returns the address of the contract admin.
     */
    function getAdmin() public view returns (address){
        return admin;
    }

    /**
     * @dev returns the address of the contract owner.
     */
    function getOwner() public view returns (address) {
        return owner;
    }

    /**
     * @dev returns the address of the TDR manager.
     */
    function getManager() public view returns (address) {
        return manager;
    }


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
        emit addNomineeApplicationSubmitted(applicationId, userId);
    }

    function updateNomineeApplication(bytes32 applicationId, bytes32[] memory _nominees) public {
        if (!nomineeStorage.isApplicationCreated(applicationId)){
            revert("application does not exist");
        }
        nomineeApplication memory oldApplication = nomineeStorage.getNomineeApplication(applicationId);
        if(oldApplication.status==ApplicationStatus.REJECTED) {
            revert("application already rejected");
        }
        if(oldApplication.status==ApplicationStatus.APPROVED) {
            revert("application already approved");
        }
        bytes32 userId = userManager.getUserId(msg.sender);
        nomineeApplication memory newApplication = nomineeApplication({
        applicationId: applicationId,
        userId: userId,
        nominees: _nominees,
        status: ApplicationStatus.SUBMITTED
        });
        nomineeStorage.updateNomineeApplication(newApplication);
        emit updateNomineeApplicationSubmitted(applicationId, userId);
    }

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
        status: ApplicationStatus.APPROVED
        });
        nomineeStorage.createNomineeApplication(newApplication);
        emit addNomineeApplicationSubmitted(applicationId, userId);
        nomineeStorage.addNominee(newApplication.applicationId, newApplication.nominees);
    }
    function approveNomineeApplication(bytes32 applicationId) public {
        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
        //fetch the application
        nomineeApplication memory application = nomineeStorage.getNomineeApplication(applicationId);
        //application should not be already approved
        require(application.status != ApplicationStatus.APPROVED,"Application already approved");
        require(application.status != ApplicationStatus.REJECTED,"Application already rejected");
        require(application.status == ApplicationStatus.SUBMITTED,"Application is not submitted");
        if (officer.role == Role.SUPER_ADMIN || officer.role== Role.ADMIN ||
            officer.role==Role.APPROVER || officer.role==Role.VC) {
                // update Application
                application.status = ApplicationStatus.APPROVED;
                nomineeStorage.updateNomineeApplication(application);
                emit NomineeApplicationApproved(applicationId, application.userId);
            } else {
                emit Logger("User not authorized");
                revert("User not authorized");
            }
        nomineeStorage.addNominee(application.userId, application.nominees);
    }
    function rejectNomineeApplication(bytes32 applicationId) public {
        KdaOfficer memory officer = userManager.getRoleByAddress(msg.sender);
        //fetch the application
        nomineeApplication memory application = nomineeStorage.getNomineeApplication(applicationId);
        //application should not be already approved
        require(application.status != ApplicationStatus.APPROVED,"Application already approved");
        require(application.status != ApplicationStatus.REJECTED,"Application already rejected");
        require(application.status == ApplicationStatus.SUBMITTED,"Application is not submitted");


    if (officer.role == Role.SUPER_ADMIN || officer.role== Role.ADMIN ||
        officer.role==Role.APPROVER || officer.role==Role.VC) {
            // update Application
            application.status = ApplicationStatus.REJECTED;
            nomineeStorage.updateNomineeApplication(application);
            emit NomineeApplicationApproved(applicationId, application.userId);
        } else {
            emit Logger("User not authorized");
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
