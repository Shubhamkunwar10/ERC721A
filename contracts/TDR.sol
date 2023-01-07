pragma solidity ^0.8.16;

// Contract to maintain the TDR notice and applications.
// A TdrNotice stores all the applications against a notice. If any of the application is converted to DRC, it stops taking further application against that notice. One should that go to court and get the DRC quashed.
// TDR storage contract
contract TdrStorage {
    // Address of the TDR manager
    address public tdrManager;

    // Address of the contract admin
    address public admin;

    // Mapping from TDR id to TDR data
    mapping(string => TdrNotice) public noticeMap;
    mapping(string => TdrApplication) public applicationMap;

    enum ApplicationStatus {applied, verified, approved, issued}
    enum NoticeStatus{pending, issued}
    // TDR struct definition
    struct TdrApplication {
        string applicationId;
        uint applicationDate;
        string place;
        string noticeId;
        uint noticeDate;
        uint farRequested;
        string khasraOrPlotNo;
        string villageOrWard;
        string Tehsil;
        string district;
        string landUse;
        string masterPlan;
        address[] applicants;
        string description;
        uint expiration;
        ApplicationStatus status;
    }
    struct TdrNotice{
        string noticeId;
        TdrApplication[] applications;
        NoticeStatus status;

    }

    // Event emitted after a TDR is created
    event TDRCreated(string noticeId, string applicationId);

    // Event emitted after a TDR is updated
    event TDRUpdated(string noticeId, string applicationId);

    // Event emitted after a TDR is deleted
    event TDRDeleted(string noticeId);

    // Constructor function to set the initial values of the contract
    constructor(address _admin) {
        // Set the contract admin
        admin = _admin;

        // Set the TDR manager to the contract admin
        tdrManager = admin;
    }

    // Modifier to check if the caller is the TDR manager
    modifier onlyManager() {
        require(msg.sender == tdrManager, "Caller is not the TDR manager");
        _;
    }

    // Modifier to check if the caller is the contract admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the contract admin");
        _;
    }

    // Function to create a new TDR
    function createTDR(TdrApplication memory _tdrApplication) public onlyManager {
        //check whether the notice has been created or not. 
        TdrNotice storage tdrNotice = noticeMap[_tdrApplication.noticeId];
        // if notice is empty, create notice.
        if(!isNoticeCreated(tdrNotice)){
            tdrNotice.noticeId = _tdrApplication.noticeId;
        }
        // add application to the notice
        tdrNotice.applications.push(_tdrApplication);
        // add application to the map
        applicationMap[_tdrApplication.applicationId]=_tdrApplication;
        // Create a new TDR and add it to the mapping

        // Emit the TDRCreated event
        emit TDRCreated(_tdrApplication.noticeId, _tdrApplication.applicationId);
    }

    // Function to read a TDR
    function getApplication(string memory _applicationId) public view returns (TdrApplication memory) {
        // Retrieve the TDR from the mapping
        TdrApplication memory application = applicationMap[_applicationId];

        // Return the TDR data
        return application;
    }
    // function to get a notice
    function getNotice(string memory _noticeId) public view returns (TdrNotice memory) {
        // Retrieve the TDR from the mapping
        TdrNotice memory notice = noticeMap[_noticeId];

        // Return the TDR data
        return notice;
    }
    // Function to update a TDR
    function updateApplicationStatus(string memory _applicationId, ApplicationStatus _status) public onlyManager {
        // fetch the application
        TdrApplication storage application = applicationMap[_applicationId];
        // revert if empty
        if(bytes(application.applicationId).length <=0){
            revert("Application with does not exist");
        }
        // update the application
        application.status = _status;
        // Update the application in the mapping
        applicationMap[_applicationId] = application;
        // check for the notice 
        if(_status == ApplicationStatus.issued){
            TdrNotice storage notice = noticeMap[application.noticeId];
            notice.status= NoticeStatus.issued;
            noticeMap[application.noticeId]=notice;
        }

        // Emit the TDRUpdated event
        emit TDRUpdated(application.noticeId,application.applicationId);
    }

    // // Function to delete a TDR
    // function deleteTDR(uint _tdrId) public onlyManager {
    //     // Delete the TDR from the mapping
    //     delete tdrData[_tdrId];

        // Emit the TDRDeleted event
       
  function isNoticeCreated(TdrNotice memory _tdrNotice) public view returns (bool) {
    // in mapping, default values of all atrributes is zero
    if( bytes(_tdrNotice.noticeId).length >0){
            return true; 
        }
        return false;
  }
}
