//SPDX-License-Identifier: UNLICENSED

/**

UserManager contract is used to map user id to user address, and to manage verifier, approver and issuer addresses.
The contract owner and admin have the authority to update user, verifier, approver and issuer addresses.
*/
pragma solidity ^0.8.16;
import "./DataTypes.sol";

contract UserManager {
    // Mapping from user id to user address
    mapping(bytes32 => address) public userMap;
    mapping(address => bytes32) public reverseUserMap;

    // List of verifier addresses
    mapping(bytes32 => KdaOfficer) public officerMap;
    mapping(bytes32 => address) public officerAddressMap;
    mapping(address => bytes32) public reverseOfficerMap;

    // List of verifier addresses
    mapping(bytes32 => address) public verifierMap;
    mapping(address => bytes32) public reverseVerifierMap;

    // List of approver addresses
    mapping(bytes32 => address) public approverMap;
    mapping(address => bytes32) public reverseApproverMap;


    // List of issuer addresses
    mapping(bytes32 => address) public issuerMap;
    mapping(address => bytes32) public reverseIssuerMap;


    // Address of the contract owner
    address public owner;

    // Address of the contract admin
    address public admin;

    // address of the manager of the contract
    address public manager;
    // Address of the Vice-chairman
    address public vc;


    // Event emitted after a user is updated
    event UserAdded(bytes32 userId, address userAddress);
    // Event emitted after a user is updated
    event UserUpdated(bytes32 userId, address userAddress);

    // Event emitted after a officer is added
    event OfficerAdded(bytes32 officerId, address officerAddress);
    // Event emitted after a officer is updated
    event OfficerUpdated(bytes32 officerId, address officerAddress);
    // Event emitted after a officer is deleted
    event OfficerDeleted(bytes32 officerId);

    // Event emitted after a verifier is added
    event VerifierAdded(bytes32 verifierId, address verifierAddress);
    // Event emitted after a verifier is updated
    event VerifierUpdated(bytes32 verifierId, address verifierAddress);
   // Event emitted after a verifier is deleted
    event VerifierDeleted(bytes32 verifierId);


    // Event emitted after a approver is added
    event ApproverAdded(bytes32 approverId, address approverAddress);
    // Event emitted after a approver is updated
    event ApproverUpdated(bytes32 approverId, address approverAddress);
   // Event emitted after a approver is deleted
    event ApproverDeleted(bytes32 approverId);


    // Event emitted after a issuer is added
    event IssuerAdded(bytes32 issuerId, address issuerAddress);
    // Event emitted after a issuer is updated
    event IssuerUpdated(bytes32 issuerId, address issuerAddress);
   // Event emitted after a issuer is deleted
    event IssuerDeleted(bytes32 issuerId);

    // Event emitted after an issuer list is updated
    event IssuerListUpdated(address[] issuerAddresses);

    event Logger(string log);
    event LogAddress(string addressInfo, address _address);
    event LogBytes(string messgaeInfo, bytes32 _bytes);

    // Constructor function to set the initial values of the contract
    constructor(address _admin, address _manager) {
        // Set the contract owner to the caller
        owner = msg.sender;

        // Set the contract admin
        admin = _admin;
        manager = _manager;
    }

/**
 * @dev Modifier to check if the caller is the contract owner
 */
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the contract owner");
        _;
    }

/**
 * @dev Modifier to check if the caller is the contract admin
 */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the contract admin");
        _;
    }

/**
 * @dev Modifier to check if the caller is the contract admin
 */
    modifier onlyManager() {
        require(msg.sender == manager, "Caller is not the contract manager");
        _;
    }
    function setAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function setManager(address _manager) public {
        require (msg.sender == owner ||  msg.sender == admin);
        manager = _manager;
    }

/**
 * @dev Function to add a user
 * @param userId 12 bit uint id of the user
 * @param userAddress address of the user
 */
    function addUser(bytes32 userId, address userAddress) public onlyManager {
        // check is user already does not exist
        if(userMap[userId]!=address(0)){
            revert("User already exists, instead try updating the address");
        }
        // Update the user in the mapping
        userMap[userId] = userAddress;
        reverseUserMap[userAddress]=userId;

        // Emit the UserAdded event
        emit UserAdded(userId, userAddress);
    }

/**
 * @dev Function to update a user
 * @param userId 12 bit uint id of the user
 * @param userAddress address of the user
 */
    function updateUser(bytes32 userId, address userAddress) public onlyManager {
        // check if user already exists
        if(userMap[userId]==address(0)){
            revert("user does not exist");
        }

        // Update the user in the mapping
        userMap[userId] = userAddress;
        reverseUserMap[userAddress]=userId;


        // Emit the UserUpdated event
        emit UserUpdated(userId, userAddress);
    }


    /**
     * Adds a new Officer to the mapping of KdaOfficers.
     * @param officer The Officer to add to the mapping.
     * @dev The method will only allow an Admin to add a new Officer. If the Officer already exists in the mapping,address
     * the method will revert with an error message. If the Officer is added successfully, the method will emit
     * the OfficerAdded event.
     */
    function addOfficer (KdaOfficer memory officer) public {
        address officerAddress = userMap[officer.userId];
        // check role of the user should be admin only if not manager
        if(msg.sender != manager){
            require(officerMap[reverseOfficerMap[tx.origin]].role == Role.ADMIN, "Officer is not an admin");
            // check for user role is not admin or super admin
            require(officer.role != Role.ADMIN || officer.role != Role.SUPER_ADMIN, "Officer role is not valid");
        }
        // check is user already does not exist
        if(officerAddressMap[officer.userId]!=address(0)){
            revert("Officer already exist, instead try updating the address");
        }
        // Update the verifier in the mapping
        officerMap[officer.userId] = officer;
        officerAddressMap[officer.userId]=officerAddress;
        reverseOfficerMap[officerAddress]=officer.userId;


        // Emit the verifierAdded event
        emit OfficerAdded(officer.userId, officerAddress);
    }

    /**
     * Updates an existing Officer in the mapping of KdaOfficers.
     * @param officer The Officer to update in the mapping.
     * @dev The method will only allow an Admin to update an existing Officer. If the Officer does not exist in the
     * mapping, the method will revert with an error message. If the Officer is updated successfully, the method will
     * emit the OfficerUpdated event.
     */
    function updateOfficer (KdaOfficer memory officer) public {
        address officerAddress = userMap[officer.userId];
        // check role of the user should be admin only
        if(msg.sender != manager){
            require(officerMap[reverseOfficerMap[tx.origin]].role == Role.ADMIN, "Officer is not an admin");
            require(officer.role != Role.ADMIN || officer.role != Role.SUPER_ADMIN, "Officer role is not valid");
        }
        // check is user already does not exist
        if(officerAddressMap[officer.userId]==address(0)){
            revert("Officer does not exist, instead try adding the address");
        }
        // Update the verifier in the mapping
        officerMap[officer.userId] = officer;
        officerAddressMap[officer.userId]=officerAddress;
        reverseOfficerMap[officerAddress]=officer.userId;


        // Emit the verifierAdded event
        emit OfficerUpdated(officer.userId, officerAddress);
    }

    /**
     * Deletes an Officer from the mapping of KdaOfficers.
     * @param id The ID of the Officer to delete from the mapping.
     * @dev The method will only allow an Admin to delete an existing Officer. If the Officer does not exist in the
     * mapping, the method will revert with an error message. If the Officer is deleted successfully, the method will
     * emit the OfficerDeleted event.
     */
    function deleteOfficer(bytes32 id) public {
        // check role of the user should be admin only
        if(msg.sender != manager){
            require(officerMap[reverseOfficerMap[tx.origin]].role == Role.ADMIN, "Officer is not an admin");
        }
        // check if verifier already exists
        if(officerAddressMap[id]==address(0)){
            revert("officer does not exist");
        }
        // Delete the verifier in the mapping
        address _address = officerAddressMap[id];
        delete(officerMap[id]);
        delete(officerAddressMap[id]);
        delete(reverseOfficerMap[_address]);

        // Emit the verifierUpdated event
        emit OfficerDeleted(id);
    }

/**
 * @dev Function to add an verifier
 * @param id bytes32 id of the verifier
 * @param _address address of the verifier
 */
    function addVerifier(bytes32 id, address _address) public onlyAdmin {
        // check is user already does not exist
        if(verifierMap[id]!=address(0)){
            revert("verifier already exist, instead try updating the address");
        }
        // Update the verifier in the mapping
        verifierMap[id] = _address;
        reverseVerifierMap[_address]=id;


        // Emit the verifierAdded event
        emit VerifierAdded(id, _address);
    }
/**
 * @dev Function to update the verifier address in the map
 * @param id bytes32 id of the verifier
 * @param _address address of the verifier
 */
    function updateVerifier(bytes32 id, address _address) public onlyAdmin {
        // check if verifier already exists
        if(verifierMap[id]==address(0)){
            revert("Verifier does not exist");
        }
        // Update the verifier in the mapping
        verifierMap[id] = _address;
        reverseVerifierMap[_address]=id;

        // Emit the verifierUpdated event
        emit VerifierUpdated(id, _address);
    }
/**
 * @dev Function to delete the verifier address in the map
 * @param id bytes32 id of the verifier
 */
   // Function to delete the verifier address in the map
    function deleteVerifier(bytes32 id) public onlyAdmin {
        // check if verifier already exists
        if(verifierMap[id]==address(0)){
            revert("Verifier does not exist");
        }
        // Delete the verifier in the mapping
        address _address = verifierMap[id];
        delete(verifierMap[id]);
        delete(reverseVerifierMap[_address]);

        // Emit the verifierUpdated event
        emit VerifierDeleted(id);
    }
/**
 * @dev Function to get the issuer address from the id
 * @param id bytes32 id of the issuer
 * @return address of the issuer
 */
    function getVerifier(bytes32 id) public view returns (address) {
        return verifierMap[id];
    }



/**
 * @dev Function to add an approver
 * @param id bytes32 id of the approver
 * @param _address address of the approver
 */
    function addApprover(bytes32 id, address _address) public onlyAdmin {
        // check if user already does not exist
        if(approverMap[id]!=address(0)){
            revert("approver already exists, instead try updating the address");
        }
        // Update the approver in the mapping
        approverMap[id] = _address;
        reverseApproverMap[_address]=id;


        // Emit the ApproverAdded event
        emit ApproverAdded(id, _address);
    }

/**
 * @dev Function to update the approver address in the map
 * @param id bytes32 id of the approver
 * @param _address address of the approver
 */
    function updateApprover(bytes32 id, address _address) public onlyAdmin {
        // check if approver already exists
        if(approverMap[id]==address(0)){
            revert("Approver does not exist");
        }
        // Update the approver in the mapping
        approverMap[id] = _address;
        reverseVerifierMap[_address]=id;

        // Emit the ApproverUpdated event
        emit ApproverUpdated(id, _address);
    }

/**
 * @dev Function to delete the approver address in the map
 * @param id bytes32 id of the approver
 */
    function deleteApprover(bytes32 id) public onlyAdmin {
        // check if approver already exists
        if(approverMap[id]==address(0)){
            revert("Approver does not exist");
        }
        // Delete the approver in the mapping
        address _address = approverMap[id];
        delete(approverMap[id]);
        delete(reverseVerifierMap[_address]);

        // Emit the ApproverDeleted event
        emit ApproverDeleted(id);
    }
/**
 * @dev Function to get the issuer address from the id
 * @param id bytes32 id of the issuer
 * @return address of the issuer
 */
    function getApprover(bytes32 id) public view returns (address) {
        return approverMap[id];
    }





/**
 * @dev Function to add an issuer
 * @param id bytes32 id of the issuer
 * @param _address address of the issuer
 */
    function addIssuer(bytes32 id, address _address) public onlyAdmin {
        // check if issuer already does not exist
        if(issuerMap[id]!=address(0)){
            revert("issuer already exists, instead try updating the address");
        }
        // Update the issuer in the mapping
        issuerMap[id] = _address;
        reverseIssuerMap[_address]=id;

        // Emit the IssuerAdded event
        emit IssuerAdded(id, _address);
    }

/**
 * @dev Function to update the issuer address in the map
 * @param id bytes32 id of the issuer
 * @param _address address of the issuer
 */
    function updateIssuer(bytes32 id, address _address) public onlyAdmin {
        // check if issuer already exists
        if(issuerMap[id]==address(0)){
            revert("Issuer does not exist");
        }
        // Update the issuer in the mapping
        issuerMap[id] = _address;
        reverseIssuerMap[_address]=id;

        // Emit the IssuerUpdated event
        emit IssuerUpdated(id, _address);
    }

/**
 * @dev Function to delete the issuer address in the map
 * @param id bytes32 id of the issuer
 */
    function deleteIssuer(bytes32 id) public onlyAdmin {
        // check if issuer already exists
        if(issuerMap[id]==address(0)){
            revert("Issuer does not exist");
        }
        // Delete the issuer in the mapping
        address _address = approverMap[id];
        delete(issuerMap[id]);
        delete(reverseIssuerMap[_address]);
        // Emit the Issuer Deleted event
        emit IssuerDeleted(id);
    }

/**
 * @dev Function to get the issuer address from the id
 * @param id bytes32 id of the issuer
 * @return address of the issuer
 */
    function getIssuer(bytes32 id) public view returns (address) {
        return issuerMap[id];
    }

/// public functions to know whether the user is an issuer, verifier, approver or admin.
    /**

    @dev Function to check if an address is an issuer
    @param _address address to be checked
    @return bool true if the address is an issuer, false otherwise
    */
    function isIssuer(address _address) public view returns (bool) {
    return reverseIssuerMap[_address]!="";
    }
    /**

    @dev Function to check if an address is a verifier
    @param _address address to be checked
    @return bool true if the address is a verifier, false otherwise
    */
    function isVerifier(address _address) public view returns (bool) {
    return reverseVerifierMap[_address]!="";
    }
    /**

    @dev Function to check if an address is an approver
    @param _address address to be checked
    @return bool true if the address is an approver, false otherwise
    */
    function isApprover(address _address) public view returns (bool) {
    return reverseApproverMap[_address]!="";
    }
    function isAdmin(address _address) public view returns (bool) {
    return admin == _address;
    }
    // This method would @return empty address in case address is not found
    function getUserId (address _address) public view returns (bytes32){
        return reverseUserMap[_address];
    }
    function getVerifierId (address _address) view public returns (bytes32){
        return reverseVerifierMap[_address];
    }
    function getIssuerId (address _address) view public returns (bytes32){
        return reverseIssuerMap[_address];
    }

    function getRole(bytes32 id) view public returns(KdaOfficer memory){
        return officerMap[id];
    }
    function getRoleByAddress(address _address) view public returns(KdaOfficer memory){
        bytes32 id = reverseOfficerMap[_address];
        return officerMap[id];
    }



}
