pragma solidity ^0.8.0;
import "./TDR.sol";
    enum DrcStatus {available,locked_for_transfer, locked_for_utilization, transferred, utilized}
    enum ApplicationStatus {pending, submitted, approved, rejected,drcIssued,verified}
    enum NoticeStatus{pending, issued}

    // DRC would be stored in this struct. knowing this DRC one should know the owner of the DRC, area and the status of the DRC
    // Everything else, is static data, not to be interpretted by blockchain.
    struct DRC {
        bytes32 id;
        TdrNotice notice;
        DrcStatus status;
        uint farCredited;
        uint farAvailable;
        uint areaSurrendered;
        uint circleRateSurrendered;
        uint circleRateUtilization;
        bytes32[] applications; 
        DrcOwner[] owners;
        Attribute[] attributes; //keep this field for the future attributes
        // string issueDate;
    }

    struct DrcOwner{
        bytes32 id;
        uint area;
    }

    struct Attribute{
    string name;
    string value;
    string mimeType;
    }

    struct DrcTransferApplication {
        bytes32 id;
        bytes32 drcId;
        uint farTransferred;
        Signatory[] signatories;
        DrcOwner[] newDrcOwner;
        ApplicationStatus status;
    }

    struct Signatory {
        bytes32 userId;
        bool hasUserSigned;
    }


    struct DUA {
        bytes32 id;
        bytes32 drcId;
        uint farUtilized;
        Signatory[] signatories;
        ApplicationStatus status;
    }

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
