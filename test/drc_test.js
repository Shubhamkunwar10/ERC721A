const DrcStorage = artifacts.require("DrcStorage");

const StoH = (value) => {
  return web3.utils.asciiToHex(value).padEnd(66, "0");
}

contract("DrcStorage", (accounts) => {
  let storage;
  const owner = accounts[0];
  const admin = accounts[3];
  const manager = accounts[4];
  const tdrManager = accounts[5];

  beforeEach(async () => {
    storage = await DrcStorage.deployed(admin, manager, { from: owner });
  });

  describe("DrcStorage", () => {
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

    it("should set tdrManager address", async () => {
      await storage.setTdrManager(tdrManager, { from: owner });
      const result = await storage.tdrManager();
      assert.equal(result, tdrManager, "TdrManager address not set correctly");
    });

    it("should assign a unique ID and other details to a new DRC and store it correctly in the contract", async () => {
      // Create a new DRC object
      const newDrc = {
        id: StoH("12345"), 
        applicationId: StoH("app001"),
        noticeId: StoH("notice001"),
        status: 0, // DrcStatus.available
        farCredited: 100,
        farAvailable: 150,
        areaSurrendered: 10,
        circleRateSurrendered: 1000,
        circleRateUtilization: 1000,
        owners: [
          StoH("user001"),
          StoH("user002")
        ],
      };

      // Call the createDrc function to create the new DRC
      await storage.createDrc(newDrc, { from: tdrManager || manager });

      // Get the created DRC object from the contract
      let createdDrc = await storage.getDrc(newDrc.id);

      // Check that the DRC was stored correctly with the correct ID and attributes
      assert.equal(createdDrc.id, newDrc.id, "ID is not stored correctly in the contract ");
      assert.equal(createdDrc.applicationId, newDrc.applicationId, "application ID is not associated with a new DRC ");
      assert.equal(createdDrc.noticeId, newDrc.noticeId, "notice ID is not associated with a new DRC");
      assert.equal(createdDrc.status, newDrc.status, "initial status of a new DRC is not set correctly.");
      assert.equal(createdDrc.farCredited, newDrc.farCredited, "the initial FAR credited value of a new DRC is not set correctly.");
      assert.equal(createdDrc.farAvailable, newDrc.farAvailable, "the initial FAR available value of a new DRC is not set correctly.");

      const updatedDrc = {
        id: StoH("12345"),
        applicationId: StoH("app001"),
        noticeId: StoH("notice001"),
        status: 1, 
        farCredited: 100,
        farAvailable: 150,
        areaSurrendered: 10,
        circleRateSurrendered: 1000,
        circleRateUtilization: 1000,
        owners: [
          StoH("user001"),
          StoH("user002")
        ],
      };

      await storage.updateDrc(StoH("12345"), updatedDrc,{ from: manager });
      createdDrc = await storage.getDrc(updatedDrc.id);

      assert.equal(createdDrc.status, updatedDrc.status, "the status can not be updated correctly.");
      assert.isTrue(updatedDrc.farCredited % 50 === 0, "farCredited is not in the multiple of 50.");
      assert.isTrue(updatedDrc.farAvailable % 50 === 0, "farAvailable is not in the multiple of 50.");
      assert.equal(createdDrc.areaSurrendered, updatedDrc.areaSurrendered, "the initial area surrendered value of a new DRC is not set correctly");
      assert.equal(createdDrc.circleRateSurrendered, updatedDrc.circleRateSurrendered, "the initial circle rate surrendered value of a new DRC is not set correctly");
      assert.equal(createdDrc.circleRateUtilization, newDrc.circleRateUtilization, "the initial circle rate utilization value of a new DRC is not set correctly");
      assert.equal(createdDrc.owners.length, updatedDrc.owners.length, "the initial owners of a new DRC are not set correctly");
      for (let i = 0; i < createdDrc.owners.length; i++) {
        assert.equal(createdDrc.owners[i].userId, updatedDrc.owners[i].userId);
        assert.equal(createdDrc.owners[i].area, updatedDrc.owners[i].area);
      }
    });

  });
});