pragma solidity ^0.8.16;

// Contract to maintain the TDR notice and applicationIds.
// A TdrNotice stores all the applicationIds against a notice. If any of the application is converted to DRC, it stops taking further application against that notice. One should that go to court and get the DRC quashed.
// Note: This is a storage contract. Job of this contract is not to see the logic of the storage, but to store the values in the blockchain. All the logic and checks should be there in the TdrManager contract
// TDR storage contract
contract TdrStorage {
    // Address of the TDR manager
    address public tdrManager;

    // Address of the contract admin
    address public admin;

    // Mapping from TDR id to TDR data
    mapping(bytes32 => TdrNotice) public noticeMap;
    mapping(bytes32 => TdrApplication) public applicationMap;

    enum ApplicationStatus {applied, verified, approved, issued,rejected}
    enum NoticeStatus{pending, issued}
    // TDR struct definition
    struct TdrApplication {
        bytes32 applicationId;
        uint applicationDate;
        bytes32 place;
        bytes32 noticeId;
        uint farRequested;
        uint farGranted;
        address[] applicants;
        ApplicationStatus status;
    }
    struct TdrNotice{
        bytes32 noticeId;
        uint noticeDate;
        bytes32 khasraOrPlotNo;
        bytes32 villageOrWard;
        bytes32 Tehsil;
        bytes32 district;
        bytes32 landUse;
        bytes32 masterPlan;
        bytes32[] applicationIds;
        NoticeStatus status;

    }

    // Event emitted after a TDR is created
    event ApplicationCreated(bytes32 noticeId, bytes32 applicationId);
    event ApplicationUpdated(bytes32 noticeId, bytes32 applicationId);

    event NoticeCreated(bytes32 noticeId);
    event NoticeUpdated(bytes32 noticeId);


    // Event emitted after a TDR is updated
    event TDRUpdated(bytes32 noticeId, bytes32 applicationId);

    // Event emitted after a TDR is deleted
    event TDRDeleted(bytes32 noticeId);

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
    function createApplication(TdrApplication memory _tdrApplication) public onlyManager {
        // add application to the map
        applicationMap[_tdrApplication.applicationId]=_tdrApplication;
        // Create a new TDR and add it to the mapping

        // Emit the TDRCreated event
        emit ApplicationCreated(_tdrApplication.noticeId, _tdrApplication.applicationId);
    }

    // Function to create a new TDR
    function createNotice(TdrNotice memory _tdrNotice) public onlyManager {
        //check whether the notice has been created or not. 
        TdrNotice storage tdrNotice = noticeMap[_tdrNotice.noticeId];
        // if notice is empty, create notice.
        if(isNoticeCreated(tdrNotice)){
            revert("notice already created");
        }
        tdrNotice.noticeDate = _tdrNotice.noticeDate;
        tdrNotice.khasraOrPlotNo = _tdrNotice.khasraOrPlotNo;
        tdrNotice.villageOrWard = _tdrNotice.villageOrWard;
        tdrNotice.Tehsil = _tdrNotice.Tehsil;
        tdrNotice.district = _tdrNotice.district;
        tdrNotice.landUse = _tdrNotice.landUse;
        tdrNotice.masterPlan = _tdrNotice.masterPlan;
        tdrNotice.status = _tdrNotice.status;
        // add application to the map
        noticeMap[_tdrNotice.noticeId]=tdrNotice;
        // Create a new TDR and add it to the mapping

        // Emit the TDRCreated event
        emit NoticeCreated(_tdrNotice.noticeId);
    }

    function updateNotice(TdrNotice memory _tdrNotice) public {
        TdrNotice storage tdrNotice = noticeMap[_tdrNotice.noticeId];
        // if notice is empty, create notice.
        if(!isNoticeCreated(tdrNotice)){
            revert("no such notice exists, reverting");
        }
        tdrNotice.noticeDate = _tdrNotice.noticeDate;
        tdrNotice.khasraOrPlotNo = _tdrNotice.khasraOrPlotNo;
        tdrNotice.villageOrWard = _tdrNotice.villageOrWard;
        tdrNotice.Tehsil = _tdrNotice.Tehsil;
        tdrNotice.district = _tdrNotice.district;
        tdrNotice.landUse = _tdrNotice.landUse;
        tdrNotice.masterPlan = _tdrNotice.masterPlan;
        tdrNotice.status = _tdrNotice.status;
        // add application to the map
        noticeMap[_tdrNotice.noticeId]=tdrNotice;
        // Create a new TDR and add it to the mapping

        // Emit the TDRCreated event
        emit NoticeCreated(_tdrNotice.noticeId);
    }

    function addApplicationToNotice(bytes32 noticeId, bytes32 applicationId) public {
        TdrNotice storage tdrNotice = noticeMap[noticeId];
        // notice should exist
        if(tdrNotice.noticeId==""){
		    revert("No such notice exist");
	    }
	    tdrNotice.applicationIds.push(applicationId);

    }


    // Function to read a TDR
    function getApplication(bytes32 _applicationId) public view returns (TdrApplication memory) {
        // Retrieve the TDR from the mapping
        TdrApplication memory application = applicationMap[_applicationId];

        // Return the TDR data
        return application;
    }
    // function to get a notice
    function getNotice(bytes32 _noticeId) public view returns (TdrNotice memory) {
        // Retrieve the TDR from the mapping
        TdrNotice memory notice = noticeMap[_noticeId];

        // Return the TDR data
        return notice;
    }
    
    // Function to update a TDR
    function updateApplicationStatus(bytes32 _applicationId, ApplicationStatus _status) public onlyManager {
        // fetch the application
        TdrApplication storage application = applicationMap[_applicationId];
        // revert if empty
        if(application.applicationId==""){
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

    function updateApplication(TdrApplication memory _application) public {
        applicationMap[_application.applicationId]=_application;
        emit ApplicationUpdated(_application.noticeId, _application.applicationId); // emit this event
    }

    // // Function to delete a TDR
    // function deleteTDR(uint _tdrId) public onlyManager {
    //     // Delete the TDR from the mapping
    //     delete tdrData[_tdrId];

        // Emit the TDRDeleted event
       
  function isNoticeCreated(TdrNotice memory _tdrNotice) public pure returns (bool) {
    // in mapping, default values of all atrributes is zero
    if( _tdrNotice.noticeId==""){
            return false; 
        }
        return true;
  }
}
