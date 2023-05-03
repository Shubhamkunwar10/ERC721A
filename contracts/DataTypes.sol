// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
//import "./TDR.sol";
   enum DrcStatus {
    AVAILABLE,
    LOCKED_FOR_TRANSFER,
    LOCKED_FOR_UTILIZATION,
    TRANSFERRED,
    UTILIZED
}

    enum ApplicationStatus {
    PENDING,
    SUBMITTED,
    APPROVED,
    REJECTED,
    DRCISSUED,
    VERIFIED,
    VERIFICATION_REJECTED,
    SENT_BACK_FOR_CORRECTION
}

    enum NoticeStatus{
        PENDING,
        ISSUED,
        CANCELLED
    }

    enum AreaType {
                    DEVELOPED,
                    UNDEVELOPED,
                    NEWLY_DEVELOPED,
                    BUILT
                }

    enum LandUse {
        GROUP_HOUSING,
        OFFICES_INSITITUTIONS_AND_COMMUNITY_FACILITIES,
        MIXED_USE,
        COMMERCIAL,
        AGRICULTURAL,
        RECREATIONAL,
        PLOTTED_RESIDENTIAL,
        INDUSTRIAL
    }
    // DRC would be stored in this struct. knowing this DRC one should know the owner of the DRC,
    //  area and the status of the DRC
    // Everything else, is static data, not to be interpreted by blockchain.
    struct DRC {
        bytes32 id;
        bytes32 applicationId; // application that lead to creation of drc
        bytes32 noticeId;
        DrcStatus status;
        uint farCredited;
        uint farAvailable;
        uint areaSurrendered;
        uint circleRateSurrendered;
        uint circleRateUtilization;
        bytes32[] owners;
        uint timeStamp;
        bool hasPrevious;
        bytes32 previousDRC;
    }
// DRC Utilization Certificate
    struct DUC {
        bytes32 id;
        bytes32 applicationId; // application id of application in BPAS
        bytes32 noticeId;
        uint farUtilized;
        uint circleRateSurrendered;
        uint circleRateUtilization;
        bytes32[] owners;
        uint timeStamp;
    }
    struct DrcOwner{
        bytes32 userId;
        uint area;
    }

    struct Attribute{
    string name;
    string value;
    string mimeType;
    }

    struct DrcTransferApplication {
        bytes32 applicationId;
        bytes32 drcId;
        uint farTransferred;
        Signatory[] applicants;
//        DrcOwner[] newDrcOwner;
        bytes32[] buyers;
        ApplicationStatus status;
        uint timeStamp;
    }

    struct Signatory {
        bytes32 userId;
        bool hasUserSigned;
    }


    struct DUA {
        bytes32 applicationId;
        bytes32 drcId;
        uint farUtilized;
        Signatory[] signatories;
        ApplicationStatus status;
        uint timeStamp;

    }

    struct TdrApplication {
        bytes32 applicationId;
        uint timeStamp;
        bytes32 place;
        bytes32 noticeId;
        uint farRequested;
        uint circleRateUtilized;
        Signatory[] applicants; // this should be applicants user id and then account should be taken from some mapping
        ApplicationStatus status;
    }
    struct TdrNotice{
        bytes32 noticeId;
        uint timeStamp;
        LandInfo landInfo;
        MasterPlanInfo masterPlanInfo;
        uint areaSurrendered;
        uint circleRateSurrendered;

        NoticeStatus status;

    }
    struct LandInfo {
        bytes32 khasraOrPlotNo;
        bytes32 villageOrWard;
        Zone zone;
        bytes32 district;
    }
    struct MasterPlanInfo {
        LandUse landUse;
        bytes32 masterPlan;
        uint roadWidth;
        AreaType areaType;
    }

    enum Role {
        NONE,
        ADMIN,
        VERIFIER,
        SUB_VERIFIER,
        VC,
        APPROVER,
        CHIEF_TOWN_AND_COUNTRY_PLANNER,
        CHIEF_ENGINEER,
        DM
    }

    enum Department {
        NONE,
        LAND,
        PLANNING,
        ENGINEERING,
        PROPERTY,
        SALES,
        LEGAL
    }
    enum Zone {
        NONE,
        ZONE_1,
        ZONE_2,
        ZONE_3,
        ZONE_4
    }

    struct KdaOfficer {
        bytes32 userId;
        Role role;
        Department department;
        Zone zone;
    }
    
    struct SubVerificationStatus {
        Department dep;
        bytes32 officerId;
        bool isVerified;
        string comment;
    }

    struct VerificationStatus {
        bool verified;
        bytes32 verifierId;
        string verifierComment;
        SubVerificationStatus landVerification;
        SubVerificationStatus planningVerification;
        SubVerificationStatus engineeringVerification;
        SubVerificationStatus propertyVerification;
        SubVerificationStatus salesVerification;
        SubVerificationStatus legalVerification;
    }
    struct DtaVerificationStatus {
        bool verified;
        bytes32 verifierId;
        string verifierComment;
    }

    struct nomineeApplication {
        bytes32 applicationId;
        bytes32 userId;
        bytes32[] nominees;
        ApplicationStatus status;
    }
    struct ApprovalStatus {
        bool approved;
        bool hasTownPlannerApproved;
        bool hasChiefEngineerApproved;
        bool hasDMApproved;
    }
