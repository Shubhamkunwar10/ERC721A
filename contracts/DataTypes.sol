// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
//import "./TDR.sol";
   enum DrcStatus {
    AVAILABLE,
    LOCKED_FOR_TRANSFER,
    LOCKED_FOR_UTILIZATION,
    TRANSFERRED,
    UTILIZED,
    CANCELLED
}

    enum ApplicationStatus {
    PENDING,
    SUBMITTED,
    APPROVED,
    REJECTED,
    DRC_ISSUED,
    VERIFIED,
    VERIFICATION_REJECTED,
    SENT_BACK_FOR_CORRECTION
}
    enum VerificationValues{
        PENDING,
        REJECTED,
        VERIFIED,
        SENT_BACK_FOR_CORRECTION
    }
    enum ApprovalValues{
        PENDING,
        APPROVED,
        REJECTED,
        SENT_BACK_FOR_CORRECTION
    }
    enum NoticeStatus{
        PENDING,
        ISSUED,
        CANCELLED
    }

    enum AreaType {
                    NONE,
                    DEVELOPED,
                    UNDEVELOPED,
                    NEWLY_DEVELOPED,
                    BUILT
                }

    enum LandUse {
        NONE,
        GROUP_HOUSING,
        OFFICES_INSTITUTIONS_AND_COMMUNITY_FACILITIES,
        MIXED_USE,
        COMMERCIAL,
        AGRICULTURAL,
        RECREATIONAL,
        PLOTTED_RESIDENTIAL,
        INDUSTRIAL
    }


    enum TdrType {
        NONE,
        HERITAGE,
        RESERVATION,
        SLUM,
        NEW_ROAD,
        EXISTING_ROAD,
        AMENITY,
        AGRICULTURE,
        OTHER
    }

    enum Designation {
        NONE,
        ADMIN,
        VERIFIER,
        SUB_VERIFIER,
        VC,
        APPROVER,
        CHIEF_TOWN_AND_COUNTRY_PLANNER,
        CHIEF_ENGINEER,
        DM,
        OTHER
    }

    enum Department {
        NONE,
        LAND,
        PLANNING,
        ENGINEERING,
        PROPERTY,
        SALES,
        LEGAL,
        OTHER
    }

    enum Role{

        NONE,
        USER_MANAGER,                       //add, update, delete KDA officer
        KDA_REGISTRAR,                      //KDA  Registeration

        TDR_NOTICE_MANAGER,            //create or update TDR Notice
        TDR_APPLICATION_VERIFIER,
        TDR_APPLICATION_SUB_VERIFIER,
        TDR_APPLICATION_APPROVER_CHIEF_TOWN_AND_COUNTRY_PLANNER,
        TDR_APPLICATION_APPROVER_CHIEF_ENGINEER,
        TDR_APPLICATION_APPROVER_DM,
        TDR_APPLICATION_ZONE_SETTER,
        DRC_ISSUER,                         //issue drc
        DTA_VERIFIER,
        DTA_APPROVER,

        DRC_MANAGER, // manages drc after issuance
        NOMINEE_MANAGER


    }



    enum Zone {
        NONE,
        ZONE_1,
        ZONE_2,
        ZONE_3,
        ZONE_4
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
        bytes32 applicantId;
    }


    struct Signatory {
        bytes32 userId;
        bool hasUserSigned;
    }

    struct DrcUtilizationDetails {
        LandUse landUse;
        AreaType areaType;
        uint roadWidth;
        uint purchasableFar;
        uint basicFar;
        uint circleRateUtilization;
    }

    struct DUA {
        bytes32 applicationId;
        bytes32 drcId;
        uint farUtilized;
        uint farPermitted;
        Signatory[] signatories;
        ApplicationStatus status;
        uint timeStamp;
        DrcUtilizationDetails drcUtilizationDetails;
        LocationInfo locationInfo;
        bytes32 applicantId;
    }

// DRC Utilization Certificate
    struct DUC {
        bytes32 id;
        bytes32 applicationId; // application id of application in BPAS
        bytes32 noticeId;
        uint farPermitted;
        uint circleRateSurrendered; //  from notice
        bytes32[] owners;
        uint timeStamp;
        uint tdrConsumed;
        DrcUtilizationDetails drcUtilizationDetails;
        LocationInfo locationInfo;
    }

    struct TdrApplication {
        bytes32 applicationId;
        uint timeStamp;
        bytes32 place;
        bytes32 noticeId;
        uint farRequested;
        uint circleRate;
        Signatory[] applicants; // this should be applicants user id and then account should be taken from some mapping
        ApplicationStatus status;
        bytes32 applicantId;
    }
    struct TdrNotice{
        bytes32 noticeId;
        uint timeStamp;
        LocationInfo locationInfo;
        PropertyInfo propertyInfo;
        TdrInfo tdrInfo;
        NoticeStatus status;
        ConstructionDetails constructionDetails; // Warning for floating
        PropertyOwner[] owners;
        bytes32 propertyId;
    }
    struct LocationInfo {
        bytes32 khasraOrPlotNo;
        bytes32 villageOrWard;
        bytes32 Tehsil;
        bytes32 district;
    }
    struct PropertyInfo {
        bytes32 masterPlan;
        uint roadWidth;
        AreaType areaType;
        LandUse landUse;
    }
    struct TdrInfo {
        uint areaAffected;
        uint circleRate;
        uint farProposed;
        TdrType tdrType;
    }
// note since solidity does not have floating point number, it is in multiple of hundres
    struct ConstructionDetails {
        uint256 landArea;
        uint256 buildUpArea;
        uint256 carpetArea;
        uint256 numFloors;
    }

    struct KdaOfficer {
        bytes32 userId;
        Role[] roles;
        Department department;
        Zone zone;
        Designation designation;
    }



    struct SubVerificationStatus {
        bytes32 officerId;
        VerificationValues verified;
        string comment;
    }

    struct VerificationStatus {
        VerificationValues verified;
        SubVerificationStatus landVerification;
        SubVerificationStatus planningVerification;
        SubVerificationStatus engineeringVerification;
        SubVerificationStatus propertyVerification;
        SubVerificationStatus salesVerification;
        SubVerificationStatus legalVerification;
        SubVerificationStatus townplanneVerification;
    }
    struct DtaVerificationStatus {
        VerificationValues verified;
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
        ApprovalValues approved;
        ApprovalValues hasTownPlannerApproved;
        ApprovalValues hasChiefEngineerApproved;
        ApprovalValues hasDMApproved;
        string townPlannerComment;
        string chiefEngineerComment;
        string DMComment;
    }
    struct PropertyOwner {
        string name;
        string soWo;
        uint age;
        string phone;
        string email;
        string ownerAddress;
    }