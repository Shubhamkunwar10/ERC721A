const DRCManager = artifacts.require("DRCManager");
const DrcStorage = artifacts.require("DrcStorage");
const TdrStorage = artifacts.require("TdrStorage");
const truffleAssertion = require(`truffle-assertions`);

const StoH = (value) => {
  return web3.utils.asciiToHex(value).padEnd(66, "0");
};

contract(`DRCManager`, async (accounts) => {
  let drcManagerInstance;
  let drcStorageInstance;
  let tdrStorageInstance;
  let ownerAddress = accounts[0];
  let adminAddress = accounts[1];
  let managerAddress = accounts[2];
  let updatedAdminAddress = accounts[3];
  let updatedManagerAddress = accounts[4];
  let drcStorageAddress = accounts[5];
  let updateDrcStorageAddress = accounts[6];
  let userManagerAddress = accounts[7];
  let updateUserManagerAddress = accounts[8];
  let dtaStorageAddress = accounts[9];
  let updateDtaStorageAddress = accounts[8];
  let duaStorageAddress = accounts[7];
  let updateDuaStorageAddress = accounts[6];

  let drcId = StoH("12345");
  let applicationId = StoH("app001");
  let buyer = [StoH(`user1`), StoH(`user2`)];

  beforeEach(async () => {
    drcStorageInstance = await DrcStorage.deployed(
      adminAddress,
      managerAddress,
      { from: ownerAddress }
    );
    tdrStorageInstance = await TdrStorage.deployed(
      adminAddress,
      managerAddress,
      { from: ownerAddress }
    );
    drcManagerInstance = await DRCManager.deployed(
      adminAddress,
      managerAddress,
      { from: ownerAddress }
    );
  });

  it(`1. Function to set Admin address`, async () => {
    await drcManagerInstance.setAdmin(updatedAdminAddress, {
      from: ownerAddress,
    });
    assert.equal(
      await drcManagerInstance.admin(),
      updatedAdminAddress,
      "Unable to set admin address"
    );
  });

  it(`2. Function to set Manager address`, async () => {
    await drcManagerInstance.setManager(updatedManagerAddress);
    assert.equal(
      await drcManagerInstance.manager(),
      updatedManagerAddress,
      "Unable to set manager address"
    );
  });

  it(`3. Function to Load DRC storage`, async () => {
    await drcManagerInstance.loadDrcStorage(drcStorageAddress);
    assert.equal(
      await drcManagerInstance.drcStorageAddress(),
      drcStorageAddress,
      " Load DRC storage address not same"
    );
  });

  it(`4. Function to update DRC storage address`, async () => {
    await drcManagerInstance.updateDrcStorage(updateDrcStorageAddress);
    assert.equal(
      await drcManagerInstance.drcStorageAddress(),
      updateDrcStorageAddress,
      "Update DRC storage not run "
    );
  });

  it(`5. Function to load User Manager address`, async () => {
    await drcManagerInstance.loadUserManager(userManagerAddress);
    assert.equal(
      await drcManagerInstance.userManagerAddress(),
      userManagerAddress,
      "Load User Manager address not same"
    );
  });

  it(`6. Function to update User Manager address`, async () => {
    await drcManagerInstance.updateUserManager(updateUserManagerAddress);
    assert.equal(
      await drcManagerInstance.userManagerAddress(),
      updateUserManagerAddress,
      "Unable to update User manager address"
    );
  });

  it(`7. Function to load DTA Storage address`, async () => {
    await drcManagerInstance.loadDtaStorage(dtaStorageAddress);
    assert.equal(
      await drcManagerInstance.dtaStorageAddress(),
      dtaStorageAddress,
      "Unable to load DTA storage address"
    );
  });

  it(`8. Function to Update DTA Storage address`, async () => {
    await drcManagerInstance.updateDtaStorage(updateDtaStorageAddress);
    assert.equal(
      await drcManagerInstance.dtaStorageAddress(),
      updateDtaStorageAddress,
      "Unable to update DTA Storage Address"
    );
  });

  it(`9. Function to load DUA Storage address`, async () => {
    await drcManagerInstance.loadDuaStorage(duaStorageAddress);
    assert.equal(
      await drcManagerInstance.duaStorageAddress(),
      duaStorageAddress,
      "Unable to load DUA Storage address"
    );
  });

  it(`10. Function to update DUA Storage address`, async () => {
    await drcManagerInstance.updateDuaStorage(updateDuaStorageAddress);
    assert.equal(
      await drcManagerInstance.duaStorageAddress(),
      updateDuaStorageAddress,
      "Unable to update DUA Storage Address"
    );
  });

  it(`11. Function to Create Transfer Application`, async () => {
    // const newApplication = {
    //   applicationId: StoH(`app001`),
    //   applicationDate: "1645996800", // equivalent to February 28th, 2022, 12:00:00 AM UTC
    //   place: StoH(`Kanpur`),
    //   noticeId: StoH(`notice001`),
    //   farRequested: "100000",
    //   applicants: [
    //     {
    //       userId: StoH(`user1`),
    //       hasUserSigned: true,
    //     },
    //     {
    //       userId: StoH(`user2`),
    //       hasUserSigned: true,
    //     },
    //   ],
    //   status: 0,
    // };

    // const newNotice = {
    //   noticeId: StoH("notice001"),
    //   noticeDate: "1645996800",
    //   landInfo: {
    //     khasraOrPlotNo:
    //       "0x4e657720596f726b000000000000000000000000000000000000000000000000",
    //     villageOrWard:
    //       "0x4e657720596f726b000000000000000000000000000000000000000000000000",
    //     Tehsil:
    //       "0x4e657720596f726b000000000000000000000000000000000000000000000000",
    //     district:
    //       "0x4e657720596f726b000000000000000000000000000000000000000000000000",
    //   },
    //   masterPlanInfo: {
    //     landUse:
    //       "0x4e657720596f726b000000000000000000000000000000000000000000000000",
    //     masterPlan:
    //       "0x4e657720596f726b000000000000000000000000000000000000000000000000",
    //     roadWidth: "100",
    //     areaType: "0",
    //   },
    //   areaSurrendered: "100",
    //   circleRateSurrendered: "100",
    //   status: 0,
    // };

    const newDrc = {
      id: drcId,
      applicationId: applicationId,
      noticeId: StoH("notice001"),
      status: 0, // DrcStatus.available
      farCredited: 100,
      farAvailable: 150,
      areaSurrendered: 10,
      circleRateSurrendered: 1000,
      circleRateUtilization: 1000,
      //   owners: [StoH("user001"), StoH("user002")],
      owners: buyer,
    };

    // let applicationCreated = await tdrStorageInstance.createApplication(newApplication, {
    //   from: managerAddress,
    // });

    // let noticeCreated = await tdrStorageInstance.createNotice(newNotice, { from: managerAddress });

    // await tdrStorageInstance.addApplicationToNotice(
    //   newNotice.noticeId,
    //   newApplication.applicationId,
    //   { from: managerAddress }
    // );
    // const result = await tdrStorageInstance.noticeApplicationMap(
    //   newNotice.noticeId,
    //   0
    // );
    // assert.equal(
    //   result,
    //   newApplication.applicationId,
    //   "Application not added to notice correctly"
    // );

    let drcCreated = await drcStorageInstance.createDrc(newDrc, {
      from: managerAddress,
    });

    let getDrcData = await drcStorageInstance.getDrc(newDrc.id);

    assert.equal(getDrcData.id, newDrc.id, "Id not same");

    const drcStorageAddress = await drcManagerInstance.drcStorageAddress();
    let drcContractAddress = await drcStorageInstance.address;
    
    console.log(getDrcData.id, newDrc.id, "djhdhkdhhdahd");
    console.log(drcStorageAddress, "drcStorageAddress");
    console.log(drcContractAddress, "drcContractAddress");



    // let addDtaAddedToDrc = await drcStorageInstance.addDtaToDrc(
    //   newDrc.id,
    //   newDrc.applicationId
    // );

    // let addDrcToOwner = await drcStorageInstance.addDrcToOwner(
    //   drcId,
    //   StoH("owner1")
    // );

    // assert.equal(
    //   getDrcData.id,
    //   newDrc.id,
    //   "ID is not stored correctly in the contract "
    // );
    // assert.equal(
    //   getDrcData.applicationId,
    //   newDrc.applicationId,
    //   "application ID is not associated with a new DRC "
    // );
    // assert.equal(
    //   getDrcData.noticeId,
    //   newDrc.noticeId,
    //   "notice ID is not associated with a new DRC"
    // );
    // assert.equal(
    //   getDrcData.status,
    //   newDrc.status,
    //   "initial status of a new DRC is not set correctly."
    // );
    // assert.equal(
    //   getDrcData.farCredited,
    //   newDrc.farCredited,
    //   "the initial FAR credited value of a new DRC is not set correctly."
    // );
    // assert.equal(
    //   getDrcData.farAvailable,
    //   newDrc.farAvailable,
    //   "the initial FAR available value of a new DRC is not set correctly."
    // );

    // result = await tdrStorageInstance.getApplication(newApplication.applicationId);

    // assert.equal(result.noticeId, newApplication.noticeId, "Notice ID not set correctly");
    // assert.equal(result.status, newApplication.status, "Status not set correctly");

    // truffleAssertion.eventEmitted(applicationCreated, "ApplicationCreated", (e) => {
    //     return e.noticeId == newNotice.id && e.applicationId == newApplication.id;
    // });

    // truffleAssertion.eventEmitted(noticeCreated, "NoticeCreated", (e) => {
    //     return e.noticeId == newNotice.id && e.notice == newNotice;
    // });

    // truffleAssertion.eventEmitted(addDtaAddedToDrc, "DtaAddedToDrc", (e) => {
    //     return e.dtaId == newDrc.id && e.applicationId == newDrc.applicationId;
    //   });

    // truffleAssertion.eventEmitted(addDrcToOwner, "DrcAddedToOwner", (e) => {
    //   return (e.drcId = drcId && e.ownerId == StoH(`owner1`));
    // });

    // truffleAssertion.eventEmitted(drcCreated, "DrcCreated", (e) => {
    //   return e.drcId == newDrc.id;
    // });

    await drcManagerInstance.createTransferApplication(
      getDrcData.id,
      applicationId,
      50,
      [
        "0x6275796572310000000000000000000000000000000000000000000000000000",
        "0x6275796572320000000000000000000000000000000000000000000000000000",
      ]
    );
  });
});
