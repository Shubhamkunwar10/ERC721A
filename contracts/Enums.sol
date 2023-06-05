// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;
   enum DrcStatus {
    AVAILABLE,
    LOCKED_FOR_TRANSFER,
    LOCKED_FOR_UTILIZATION,
    TRANSFERRED,
    UTILIZED,
    DRC_CANCELLED_BY_UTILIZATION,
    DRC_CANCELLED_BY_AUTHORITY,
    DRC_CANCELLATION_PROCESS_STARTED
}

    enum ApplicationStatus {
    PENDING,
    SUBMITTED,
    APPROVED,
    REJECTED,
    DRC_ISSUED,
    VERIFIED,
    VERIFICATION_REJECTED,
    SENT_BACK_FOR_CORRECTION,
    DOCUMENTS_MATCHED_WITH_SCANNED,
    DOCUMENTS_DID_NOT_MATCHED_WITH_SCANNED

}
    enum VerificationValues{
        PENDING,
        VERIFIED,
        REJECTED,
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
        VC,
        SUB_VERIFIER,
        TOWN_PLANNER,
        SECRETARY,
        ADDITIONAL_SECRETARY,
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
        TDR_NOTICE_MANAGER,            //create or update TDR Notice
        TDR_APPLICATION_VERIFIER,
        TDR_APPLICATION_SUB_VERIFIER,
        TDR_APPLICATION_APPROVER_CHIEF_TOWN_AND_COUNTRY_PLANNER,
        TDR_APPLICATION_APPROVER_CHIEF_ENGINEER,
        TDR_APPLICATION_APPROVER_DM,
        DRC_ISSUER,                         //issue drc
        DTA_VERIFIER,
        DTA_APPROVER,
        DUA_VERIFIER,
        DUA_APPROVER,
        DRC_MANAGER, // manages drc after issuance
        DRC_CANCELLER,
        NOMINEE_MANAGER,
        DOCUMENT_VERIFIER
    }



//    enum Zone {
//        NONE,
//        ZONE_1,
//        ZONE_2,
//        ZONE_3,
//        ZONE_4
//    }