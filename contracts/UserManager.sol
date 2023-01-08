pragma solidity ^0.8.0;

contract UserManager {
    // Mapping from user id to user address
    mapping(bytes32 => address) public userMap;

    // List of verifier addresses
    mapping(bytes32 => address) public verifierMap;

    // List of approver addresses
    mapping(bytes32 => address) public approverMap;

    // List of issuer addresses
    mapping(bytes32 => address) public issuerMap;

    // Address of the contract owner
    address public owner;

    // Address of the contract admin
    address public admin;

    // Address of the Vice-chairman
    address public vc;
     
    // Event emitted after a user is updated   
    event UserAdded(bytes32 userId, address userAddress);
    // Event emitted after a user is updated
    event UserUpdated(bytes32 userId, address userAddress);

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

    // Constructor function to set the initial values of the contract
    constructor(address _admin) {
        // Set the contract owner to the caller
        owner = msg.sender;

        // Set the contract admin
        admin = _admin;
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
 * @dev Function to add a user
 * @param userId 12 bit uint id of the user
 * @param userAddress address of the user
 */
    function addUser(bytes32 userId, address userAddress) public onlyAdmin {
        // check is user already does not exist
        if(userMap[userId]!=address(0)){
            revert("User already exists, instead try updating the address");
        }
        // Update the user in the mapping
        userMap[userId] = userAddress;

        // Emit the UserAdded event
        emit UserAdded(userId, userAddress);
    }

/**
 * @dev Function to update a user
 * @param userId 12 bit uint id of the user
 * @param userAddress address of the user
 */
    function updateUser(bytes32 userId, address userAddress) public onlyAdmin {
        // check if user already exists
        if(userMap[userId]==address(0)){
            revert("user does not exist");
        }

        // Update the user in the mapping
        userMap[userId] = userAddress;

        // Emit the UserUpdated event
        emit UserUpdated(userId, userAddress);
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
        delete(verifierMap[id]);

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
        delete(approverMap[id]);

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
        delete(issuerMap[id]);

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

}