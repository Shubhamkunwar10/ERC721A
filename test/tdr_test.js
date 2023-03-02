const TdrStorage = artifacts.require("TdrStorage");
// const DataTypes = artifacts.require("DataTypes");

contract("TdrStorage", (accounts) => {
  let storage;
  let dataTypes;
  const owner = accounts[0];
  const admin = accounts[3];
  const manager = accounts[4];

  beforeEach(async () => {
    // dataTypes = await DataTypes.new({ from: owner });
    // storage = await TdrStorage.new(admin, manager,{ from: owner });
    storage = await TdrStorage.deployed(admin, manager, {from: owner});
    // console.log(storage.address, "address")
    // console.log(await storage.owner(), "owner")
    // await storage.setOwner(owner,{from:owner});
    // console.log(await storage.owner(), "owner")
    // await storage.setXAdmin(admin,{from:owner});
    // await storage.setXManager(manager,{from:owner});
  });

  describe("TdrStorage", () => {
    it("should set admin address", async () => {
      
      await storage.setAdmin(admin, { from: owner });
      const result = await storage.admin();
      assert.equal(result, admin, "Admin address not set correctly");
    });

    it("should set manager address", async () => {
      await storage.setManager(manager, { from: owner });
      const result = await storage.manager();
      assert.equal(result, manager, "Manager address not set correctly");
    });

    it("should create application", async () => {
      const tdrApplication =  {
        applicationId: "0x1234567890123456789012345678901234567890123456789012345678901234",
        applicationDate: "1645996800", // equivalent to February 28th, 2022, 12:00:00 AM UTC
        place: "0x4e657720596f726b000000000000000000000000000000000000000000000000",
        noticeId: "0x9876543210987654321098765432109876543210987654321098765432109876",
        farRequested: "100000",
        applicants: [
             {
                userId: "0x3100000000000000000000000000000000000000000000000000000000000000",
                hasUserSigned: true
            },
             {
                userId: "0x3200000000000000000000000000000000000000000000000000000000000000",
                hasUserSigned: true
            }
        ],
        status: 0
    };
      // console.log(tdrApplication, "tdrApplication")
      await storage.createApplication(tdrApplication, { from: manager });
      let result;
      // console.log(result, "result-1")
      result = await storage.getApplication(tdrApplication.applicationId);
      // console.log(result, "result-2")
      assert.equal(result.noticeId, tdrApplication.noticeId, "Notice ID not set correctly");
      assert.equal(result.status, tdrApplication.status, "Status not set correctly");
    });   

    it("should create notice", async () => {
    const tdrNotice ={
         noticeId: "0x9876543210987654321098765432109876543210987654321098765432109876",
         noticeDate: "1645996800",
         landInfo : {
           khasraOrPlotNo: "0x4e657720596f726b000000000000000000000000000000000000000000000000",
           villageOrWard:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           Tehsil:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           district:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
      },
         masterPlanInfo:{
          landUse:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          masterPlan:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          roadWidth:"100",
          areaType: "0",
         },
         areaSurrendered: "100",
         circleRateSurrendered: "100",
         status: 0

    }
      await storage.createNotice(tdrNotice, { from: manager });
      const result = await storage.getNotice(tdrNotice.noticeId);
      assert.equal(result.status, tdrNotice.status, "Status not set correctly");
    });

    it("should update notice", async () => {
      const tdrNotice = {
        noticeId: "0x3132000000000000000000000000000000000000000000000000000000000000",
         noticeDate: "1645996800",
         landInfo : {
           khasraOrPlotNo: "0x4e657720596f726b000000000000000000000000000000000000000000000000",
           villageOrWard:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           Tehsil:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           district:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
      },
         masterPlanInfo:{
          landUse:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          masterPlan:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          roadWidth:"100",
          areaType: "0",
         },
         areaSurrendered: "100",
         circleRateSurrendered: "100",
         status: 0

      };
      await storage.createNotice(tdrNotice, { from: manager });
      const updatedNotice = {
        noticeId: "0x3132000000000000000000000000000000000000000000000000000000000000",
         noticeDate: "1645996800",
         landInfo : {
           khasraOrPlotNo: "0x4e657720596f726b000000000000000000000000000000000000000000000000",
           villageOrWard:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           Tehsil:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           district:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
      },
         masterPlanInfo:{
          landUse:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          masterPlan:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          roadWidth:"100",
          areaType: "0",
         },
         areaSurrendered: "100",
         circleRateSurrendered: "100",
         status: 0

      };
      await storage.updateNotice(updatedNotice, { from: manager });
      const result = await storage.getNotice(updatedNotice.noticeId);
      assert.equal(result.status, updatedNotice.status, "Status not updated correctly");
    });

    it("should add application to notice", async () => {
      const tdrNotice = {
        noticeId: "0x3133000000000000000000000000000000000000000000000000000000000000",
         noticeDate: "1645996800",
         landInfo : {
           khasraOrPlotNo: "0x4e657720596f726b000000000000000000000000000000000000000000000000",
           villageOrWard:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           Tehsil:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           district:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
      },
         masterPlanInfo:{
          landUse:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          masterPlan:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          roadWidth:"100",
          areaType: "0",
         },
         areaSurrendered: "100",
         circleRateSurrendered: "100",
         status: 0

      };
      await storage.createNotice(tdrNotice, { from: manager });
      const tdrApplication = {
        applicationId: "0x3130320000000000000000000000000000000000000000000000000000000000",
        applicationDate: "1645996800", // equivalent to February 28th, 2022, 12:00:00 AM UTC
        place: "0x4e657720596f726b000000000000000000000000000000000000000000000000",
        noticeId: "0x9876543210987654321098765432109876543210987654321098765432109876",
        farRequested: "100000",
        applicants: [
             {
                userId: "0x3100000000000000000000000000000000000000000000000000000000000000",
                hasUserSigned: true
            },
             {
                userId: "0x3200000000000000000000000000000000000000000000000000000000000000",
                hasUserSigned: true
            }
        ],
        status: 0
      };
      await storage.createApplication(tdrApplication, { from: manager });
      await storage.addApplicationToNotice(tdrNotice.noticeId, tdrApplication.applicationId, { from: manager });
      const result = await storage.noticeApplicationMap(tdrNotice.noticeId,0);
      assert.equal(result, tdrApplication.applicationId, "Application not added to notice correctly");
    });
   
   
    it("should get all notices", async () => {
      const tdrNotice1 = {
        noticeId: "0x3134000000000000000000000000000000000000000000000000000000000000",
         noticeDate: "1645996800",
         landInfo : {
           khasraOrPlotNo: "0x4e657720596f726b000000000000000000000000000000000000000000000000",
           villageOrWard:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           Tehsil:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           district:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
      },
         masterPlanInfo:{
          landUse:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          masterPlan:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          roadWidth:"100",
          areaType: "0",
         },
         areaSurrendered: "100",
         circleRateSurrendered: "100",
         status: 0

      };
      const tdrNotice2 = {
        noticeId: "0x3135000000000000000000000000000000000000000000000000000000000000",
         noticeDate: "1645996800",
         landInfo : {
           khasraOrPlotNo: "0x4e657720596f726b000000000000000000000000000000000000000000000000",
           villageOrWard:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           Tehsil:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           district:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
      },
         masterPlanInfo:{
          landUse:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          masterPlan:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          roadWidth:"100",
          areaType: "0",
         },
         areaSurrendered: "100",
         circleRateSurrendered: "100",
         status: 0

      };
      await storage.createNotice(tdrNotice1, { from: manager });
      await storage.createNotice(tdrNotice2, { from: manager });
      const result1 = await storage.noticeMap(tdrNotice1.noticeId);
      const result2 = await storage.noticeMap(tdrNotice2.noticeId);
      assert.equal(result1.noticeId, tdrNotice1.noticeId, "Notice ID not returned correctly");
      assert.equal(result2.noticeId, tdrNotice2.noticeId, "Notice ID not returned correctly");
    });

    it("should get all applications for notice", async () => {
      const tdrNotice = {
        noticeId: "0x3137000000000000000000000000000000000000000000000000000000000000",
         noticeDate: "1645996800",
         landInfo : {
           khasraOrPlotNo: "0x4e657720596f726b000000000000000000000000000000000000000000000000",
           villageOrWard:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           Tehsil:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
           district:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
      },
         masterPlanInfo:{
          landUse:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          masterPlan:"0x4e657720596f726b000000000000000000000000000000000000000000000000",
          roadWidth:"100",
          areaType: "0",
         },
         areaSurrendered: "100",
         circleRateSurrendered: "100",
         status: 0

      }
      const tdrApplication1 = {
        applicationId: "0x3130330000000000000000000000000000000000000000000000000000000000",
        applicationDate: "1645996800", // equivalent to February 28th, 2022, 12:00:00 AM UTC
        place: "0x4e657720596f726b000000000000000000000000000000000000000000000000",
        noticeId: "0x9876543210987654321098765432109876543210987654321098765432109876",
        farRequested: "100000",
        applicants: [
             {
                userId: "0x3100000000000000000000000000000000000000000000000000000000000000",
                hasUserSigned: true
            },
             {
                userId: "0x3200000000000000000000000000000000000000000000000000000000000000",
                hasUserSigned: true
            }
        ],
        status: 0
    };
      const tdrApplication2 = {
        applicationId: "0x3130340000000000000000000000000000000000000000000000000000000000",
        applicationDate: "1645996800", // equivalent to February 28th, 2022, 12:00:00 AM UTC
        place: "0x4e657720596f726b000000000000000000000000000000000000000000000000",
        noticeId: "0x9876543210987654321098765432109876543210987654321098765432109876",
        farRequested: "100000",
        applicants: [
             {
                userId: "0x3100000000000000000000000000000000000000000000000000000000000000",
                hasUserSigned: true
            },
             {
                userId: "0x3200000000000000000000000000000000000000000000000000000000000000",
                hasUserSigned: true
            }
        ],
        status: 0
    };
          await storage.createNotice(tdrNotice, { from: manager });
      await storage.createApplication(tdrApplication1, { from: manager });
      await storage.createApplication(tdrApplication2, { from: manager });
      await storage.addApplicationToNotice(tdrNotice.noticeId, tdrApplication1.applicationId, { from: manager });
      await storage.addApplicationToNotice(tdrNotice.noticeId, tdrApplication2.applicationId, { from: manager });
      const result1 = await storage.noticeApplicationMap(tdrNotice.noticeId, 0);
      const result2 = await storage.noticeApplicationMap(tdrNotice.noticeId, 1);
      assert.equal(result1, tdrApplication1.applicationId, "Application ID not returned correctly");
      assert.equal(result2, tdrApplication2.applicationId, "Application ID not returned correctly");
    });
  });
});

