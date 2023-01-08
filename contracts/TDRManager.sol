pragma solidity ^0.8.16;

import "./TdrStorage.sol";

// TDR manager contract
contract TDRManager {
    // Address of the TDR storage contract
    TdrStorage public tdrStorage;

    // Address of the contract admin
    address public admin;

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

    // Function to create a new TDR notice
    function createNotice(TdrNotice memory _tdrNotice) public {
        // Call the TDR storage contract's createNotice function
        tdrStorage.createNotice(_tdrNotice);
    }

    // Function to create a new TDR application
    function createApplication(TdrApplication memory _tdrApplication) public {
        // check whether Notice has been created for the application. If not, revert
        TdrNotice storage tdrNotice = tdrStorage.getNotice(_tdrApplication.noticeId);
        // if notice is empty, create notice.
        if(tdrNotice.noticeId==""){
            revert("No such notice has been created");
        }   
        // add application in application map
        tdrStorage.createApplication(_tdrApplication);

        // add application in the notice 
        tdrStorage.addApplicationToNotice(_tdrApplication.noticeId,_tdrApplication);
        // Call the TDR storage contract's createApplication function
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

    // Function to change the TDR manager
    function changeTDRManager(address _newTDRManager) public onlyAdmin {
        // Set the new TDR manager
        tdrStorage.tdrManager = _newTDRManager;
    }


    /*
    1. Apply TDR
    2. Verify TDR
    3. Approve TDR
    4. Issue DRC
    */
}
