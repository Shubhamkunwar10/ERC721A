const DRCManager = artifacts.require("DRCManager");
const DrcStorage = artifacts.require("DrcStorage");
const TdrStorage = artifacts.require("TdrStorage");
const DuaStorage = artifacts.require("DuaStorage");
const UserManager = artifacts.require("UserManager");
const truffleAssertion = require(`truffle-assertions`);

const StoH = (value) => {
  return web3.utils.asciiToHex(value).padEnd(66, "0");
};

contract(`DRCManager`, async (accounts) => {
  let drcManagerInstance;
  let drcStorageInstance;
  let tdrStorageInstance;
  let duaStorageInstance;
  let userManagerInstance;
  let ownerAddress = accounts[0];
  let adminAddress = accounts[1];
  let managerAddress = accounts[2];
  let updatedAdminAddress = accounts[3];
  let updatedManagerAddress = accounts[4];

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

    userManagerInstance = await UserManager.deployed(
      adminAddress,
      managerAddress,
      { from: ownerAddress }
    );

    duaStorageInstance = await DuaStorage.deployed(
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
    let drcStorageContractAddress = await drcStorageInstance.address;
    await drcManagerInstance.loadDrcStorage(drcStorageContractAddress);
    assert.equal(
      await drcManagerInstance.drcStorageAddress(),
      drcStorageContractAddress,
      " Load DRC storage address not same"
    );
  });

  it(`4. Function to update DRC storage address`, async () => {
    let updatedDrcStorageInstance = await DrcStorage.deployed(
      adminAddress,
      managerAddress,
      { from: ownerAddress }
    );

    await drcManagerInstance.updateDrcStorage(updatedDrcStorageInstance.address);
    assert.equal(
      await drcManagerInstance.drcStorageAddress(),
      updatedDrcStorageInstance.address,
      "Update DRC storage not run "
    );
  });

  it(`5. Function to load User Manager address`, async () => {
    await drcManagerInstance.loadUserManager(userManagerInstance.address);
    assert.equal(
      await drcManagerInstance.userManagerAddress(),
      userManagerInstance.address,
      "Load User Manager address not same"
    );
  });

  it(`6. Function to update User Manager address`, async () => {
    let updateUserManagerInstance = await DrcStorage.deployed(
      adminAddress,
      managerAddress,
      { from: ownerAddress }
    );
    await drcManagerInstance.updateUserManager(updateUserManagerInstance.address);
    assert.equal(
      await drcManagerInstance.userManagerAddress(),
      updateUserManagerInstance.address,
      "Unable to update User manager address"
    );
  });

  it(`9. Function to load DUA Storage address`, async () => {
    await drcManagerInstance.loadDuaStorage(duaStorageInstance.address);
    assert.equal(
      await drcManagerInstance.duaStorageAddress(),
      duaStorageInstance.address,
      "Unable to load DUA Storage address"
    );
  });

  it(`10. Function to update DUA Storage address`, async () => {
    let updateDuaStorageInstance = await DuaStorage.deployed(
      adminAddress,
      managerAddress,
      { from: ownerAddress }
    );
    await drcManagerInstance.updateDuaStorage(updateDuaStorageInstance.address);
    assert.equal(
      await drcManagerInstance.duaStorageAddress(),
      updateDuaStorageInstance.address,
      "Unable to update DUA Storage Address"
    );
  });

});