pragma solidity ^0.8.16;
//import "./TDR.sol";
enum DrcStatus {
    AVAILABLE,
    LOCKED_FOR_TRANSFER,
    LOCKED_FOR_UTILIZATION,
    TRANSFERRED,
    UTILIZED,
}

enum ApplicationStatus {
    PENDING,
    SUBMITTED,
    APPROVED,
    REJECTED,
    DRCISSUED,
    VERIFIED
}

enum NoticeStatus {
    PENDING,
    ISSUED
}

enum AreaType {
    DEVELOPED,
    UNDEVELOPED,
    NEWLY_DEVELOPED
}

// DRC would be stored in this struct. knowing this DRC one should know the owner of the DRC, area and the status of the DRC
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
}

struct DrcOwner {
    bytes32 userId;
    uint area;
}

struct Attribute {
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
    Signatory[] applicants; // this should be applicants user id and then account should be taken from some mapping
    ApplicationStatus status;
}
struct TdrNotice {
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
    bytes32 Tehsil;
    bytes32 district;
}
struct MasterPlanInfo {
    bytes32 landUse;
    bytes32 masterPlan;
    uint roadWidth;
    AreaType areaType;
}

enum Role {
    NONE,
    SUPER_ADMIN,
    ADMIN,
    VERIFIER,
    SUB_VERIFIER,
    VC,
    APPROVER
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
    bytes32 verifierId;
    Role verifierRole;
    SubVerifierStatus subVerifierStatus;
}
