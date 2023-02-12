pragma solidity ^0.8.16;
//import "./TDR.sol";
    enum DrcStatus {
                    available,
                    locked_for_transfer, 
                    locked_for_utilization, 
                    transferred, 
                    utilized
                }

    enum ApplicationStatus {
                            pending, 
                            submitted, 
                            approved, 
                            rejected,
                            drcIssued,
                            verified
                        }

    enum NoticeStatus{pending, issued}

    // DRC would be stored in this struct. knowing this DRC one should know the owner of the DRC, area and the status of the DRC
    // Everything else, is static data, not to be interpreted by blockchain.
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
        Signatory[] applicants; // this should be applicants user id and then account should be taken from some mapping
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
//        bytes32[] applicationIds;
        NoticeStatus status;

    }

    enum Role {
        SUPER_ADMIN,
        ADMIN,
        VERIFIER,
        SUB_VERIFIER,
        VC,
        APPROVER
    }

    enum Department {
        LAND,
        PLANNING,
        ENGINEERING,
        PROPERTY,
        SALES,
        LEGAL,
        ALL,
        NONE
    }
    enum Zone {
        ZONE_1,
        ZONE_2,
        ZONE_3,
        ZONE_4
    }

    struct KdaOfficer {
        bytes32 id;
        Role role;
        Department department;
        Zone zone;
    }
    struct SubVerifierStatus {
        bool land;
        bool planning;
        bool engineering;
        bool property;
        bool sales;
        bool legal;
    }
    struct VerificationStatus {
        bool verified;
        bool verifiedByAdmin;
        bool verifiedBySuperAdmin;
        SubVerifierStatus subVerifierStatus;
    }
