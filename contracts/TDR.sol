pragma solidity ^0.8.16;
import "./DataTypes.sol";

// Contract to maintain the TDR notice and applicationIds.
// A TdrNotice stores all the applicationIds against a notice. If any of the application is converted to DRC, it stops taking further application against that notice. One should that go to court and get the DRC quashed.
// Note: This is a storage contract. Job of this contract is not to see the logic of the storage, but to store the values in the blockchain. All the logic and checks should be there in the TdrManager contract
// TDR storage contract
contract TdrStorage {
    // Address of the TDR manager
    address public tdrManager;


    // Mapping from TDR id to TDR data
    mapping(bytes32 => TdrNotice) public noticeMap;
    mapping(bytes32 => TdrApplication) public applicationMap;
    // Map to store the applications against the notice
    mapping(bytes32 => bytes32[]) public noticeApplicationMap;
    mapping(bytes32 => VerificationStatus) public verificationStatusMap;
    // enum ApplicationStatus {applied, verified, approved, issued,rejected}
    // TDR struct definition


    // Event emitted after a TDR is created
    event ApplicationCreated(bytes32 noticeId, bytes32 applicationId);
    event ApplicationUpdated(bytes32 noticeId, bytes32 applicationId);

    event NoticeCreated(bytes32 noticeId);
    event NoticeUpdated(bytes32 noticeId);


    // Event emitted after a TDR is updated
    event TDRUpdated(bytes32 noticeId, bytes32 applicationId);

    // Event emitted after a TDR is deleted
    event TDRDeleted(bytes32 noticeId);
    event Logger(string log);
    event LogAddress(string addressInfo, address _address);
    event LogBytes(string messgaeInfo, bytes32 _bytes);
    event LogApplication(string message, TdrApplication application);


    address owner;
    address admin;
    address manager;


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

    function setAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function setManager(address _manager) public {
        require (msg.sender == owner ||  msg.sender == admin);
        manager = _manager;
    }

    // Function to create a new TDR
    function createApplication(TdrApplication memory _tdrApplication) public onlyManager {
        // check that an application have not been created earlier
        if(isApplicationCreated(_tdrApplication.applicationId)){
            revert("application with same id has already been created");
        }
        // add application to the map
        addApplicationToMap(_tdrApplication);
//        applicationMap[_tdrApplication.applicationId]=_tdrApplication;
        // Create a new TDR and add it to the mapping

        // Emit the TDRCreated event
        emit ApplicationCreated(_tdrApplication.noticeId, _tdrApplication.applicationId);
    }

    // Function to create a new TDR
    function createNotice(bytes32 _noticeId,uint _noticeDate,  bytes32 _khasraOrPlotNo,  bytes32 _villageOrWard,  bytes32 _Tehsil,  bytes32 _district,  bytes32 _landUse,  bytes32 _masterPlan, NoticeStatus _status) public onlyManager{
        emit Logger("START createNotice");
        emit LogAddress("message.sender",msg.sender);
        //check whether the notice has been created or not. i1
        TdrNotice storage tdrNotice = noticeMap[_noticeId];
        // if notice is empty, create notice.
        if(isNoticeCreated(tdrNotice)){
            revert("notice already created");
        }
        tdrNotice.noticeId = _noticeId;
        tdrNotice.noticeDate = _noticeDate;
        tdrNotice.khasraOrPlotNo = _khasraOrPlotNo;
        tdrNotice.villageOrWard = _villageOrWard;
        tdrNotice.Tehsil = _Tehsil;
        tdrNotice.district = _district;
        tdrNotice.landUse = _landUse;
        tdrNotice.masterPlan = _masterPlan;
        tdrNotice.status=_status;
        // add application to the map
        noticeMap[_noticeId]=tdrNotice;
        // Create a new TDR and add it to the mapping

        // Emit the TDRCreated event
        emit NoticeCreated(_noticeId);
    }
    function updateNotice(bytes32 _noticeId,uint _noticeDate,  bytes32 _khasraOrPlotNo,  bytes32 _villageOrWard,  bytes32 _Tehsil,  bytes32 _district,  bytes32 _landUse,  bytes32 _masterPlan, NoticeStatus _status) public onlyManager {
        TdrNotice storage tdrNotice = noticeMap[_noticeId];
        emit Logger("START: updateNotice");
        emit LogAddress("message.sender",msg.sender);
        // if notice is empty, create notice.
        if(!isNoticeCreated(tdrNotice)){
            revert("no such notice exists, reverting");
        }
        tdrNotice.noticeId = _noticeId;
        tdrNotice.noticeDate = _noticeDate;
        tdrNotice.khasraOrPlotNo = _khasraOrPlotNo;
        tdrNotice.villageOrWard = _villageOrWard;
        tdrNotice.Tehsil = _Tehsil;
        tdrNotice.district = _district;
        tdrNotice.landUse = _landUse;
        tdrNotice.masterPlan = _masterPlan;
        tdrNotice.status=_status;
        // add application to the map
        noticeMap[_noticeId]=tdrNotice;
        // Create a new TDR and add it to the mapping

        // Emit the TDRCreated event
        emit NoticeUpdated(_noticeId);
    }

    function updateNotice(TdrNotice memory _tdrNotice) public {
        updateNotice(_tdrNotice.noticeId, _tdrNotice.noticeDate, _tdrNotice.khasraOrPlotNo,_tdrNotice.villageOrWard,_tdrNotice.Tehsil,_tdrNotice.district,_tdrNotice.landUse,_tdrNotice.masterPlan,_tdrNotice.status);
    }
//        TdrNotice storage tdrNotice = noticeMap[_noticeId];
//        // if notice is empty, create notice.
//        if(!isNoticeCreated(tdrNotice)){
//            revert("no such notice exists, reverting");
//        }
//        tdrNotice.noticeId = _noticeId;
//        tdrNotice.noticeDate = _noticeDate;
//        tdrNotice.khasraOrPlotNo = _khasraOrPlotNo;
//        tdrNotice.villageOrWard = _villageOrWard;
//        tdrNotice.Tehsil = _Tehsil;
//        tdrNotice.district = _district;
//        tdrNotice.landUse = _landUse;
//        tdrNotice.masterPlan = _masterPlan;
//        tdrNotice.status=_status;
//        // add application to the map
//        noticeMap[_noticeId]=tdrNotice;
//        // Create a new TDR and add it to the mapping
//
//        // Emit the TDRCreated event
//        emit NoticeUpdated(_noticeId);
//    }

    /**
     * @dev Adds an application to a notice specified by its noticeId.
    * @param noticeId The bytes32 identifier of the notice to which the application is to be added.
    * @param applicationId The bytes32 identifier of the application to be added to the notice.
    * @dev Revert if no notice exists with the given noticeId.
    */
    function addApplicationToNotice(bytes32 noticeId, bytes32 applicationId) public {
        TdrNotice storage tdrNotice = noticeMap[noticeId];
        // notice should exist
        if(tdrNotice.noticeId==""){
		    revert("No such notice exist");
	    }
        bytes32[] storage applications = noticeApplicationMap[noticeId];
        applications.push(applicationId);
        noticeApplicationMap[noticeId]=applications;
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
        if(_status == ApplicationStatus.drcIssued){
            TdrNotice storage notice = noticeMap[application.noticeId];
            notice.status= NoticeStatus.issued;
            noticeMap[application.noticeId]=notice;
        }

        // Emit the TDRUpdated event
        emit TDRUpdated(application.noticeId,application.applicationId);
    }

    function updateApplication(TdrApplication memory _application) public {
        emit LogBytes("begin update application",_application.applicationId);
        TdrApplication storage application = applicationMap[_application.applicationId];
        if(! isApplicationCreated(_application.applicationId)){
            revert("Application does not exist");
        }
        addApplicationToMap(_application);
        emit ApplicationUpdated(_application.noticeId, _application.applicationId); // emit this event
    }

    /**
    * @dev Adds an application to the applicationMap.
    * @param _application The TdrApplication memory object to be added to the applicationMap.
    */
    function addApplicationToMap(TdrApplication memory _application) public {
        emit Logger("Adding application to map");
        // Retrieve the application in storage using its applicationId
        TdrApplication storage application = applicationMap[_application.applicationId];
        // Copy the properties of the input _application to the storage application
        application.applicationId = _application.applicationId;
        application.applicationDate = _application.applicationDate;
        application.place = _application.place;
        application.noticeId = _application.noticeId;
        application.farRequested = _application.farRequested;
        application.farGranted = _application.farGranted;
        application.status = _application.status;
        delete application.applicants;

        // Copy the applicants array from the input _application to the storage application
        for (uint i=0; i<_application.applicants.length;i++){
            // possible bug here over then length of the applicants.
            application.applicants.push(_application.applicants[i]);
            // application.applicants[i] = _application.applicants[i];
        }
        // Add the storage application to the applicationMap using its applicationId
        applicationMap[_application.applicationId]=application;
        emit LogBytes("successfully added application to map", _application.applicationId);
    }


    // // Function to delete a TDR
    // function deleteTDR(uint _tdrId) public onlyManager {
    //     // Delete the TDR from the mapping
    //     delete tdrData[_tdrId];

        // Emit the TDRDeleted event
       
  function isNoticeCreated(TdrNotice memory _tdrNotice) public returns (bool) {
    emit Logger("notice check was called");
    // in mapping, default values of all atrributes is zero
    TdrNotice memory _noticeFromMap = noticeMap[_tdrNotice.noticeId];
    if( _noticeFromMap.noticeId==""){
            emit Logger("notice has not been created");

            return false; 
        }
    emit Logger("notice has been created");
        return true;
  }

  function isApplicationCreated(bytes32 _applicationId) public returns (bool) {
    emit Logger("application check was called");
    // in mapping, default values of all atrributes is zero
      TdrApplication memory application = applicationMap[_applicationId];
    if( application.applicationId==""){
        emit Logger("application has not been created");
        return false;
        }
    emit Logger("application has been created");
      return true;
  }
    function storeVerificationStatus(bytes32 id, VerificationStatus memory status) public {
        verificationStatusMap[id] = status;
    }
    function getVerificationStatus(bytes32 applicationId) public view returns(VerificationStatus memory) {
        return verificationStatusMap[applicationId];
    }

}
