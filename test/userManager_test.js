const UserManager = artifacts.require("UserManager");
const truffleAssert = require(`truffle-assertions`);

contract(`UserManager`, async (accounts) => {
  let userManagerInstance;
  let ownerAddress = accounts[0];
  let adminAddress = accounts[6];
  let managerAddress = accounts[7];
  let userAddress = accounts[8];
  let newUserAddress = accounts[9];
  let officerAddress = accounts[1];
  let updateOfficerAddress = accounts[2];
  let verifierAddress = accounts[3];
  let updateVerifierAddress = accounts[4];
  let approverAddress = accounts[5];
  let updateApproverAddress = accounts[6];
  let issuerAddress = accounts[7];
  let updateIssuerAddress = accounts[8];
  let userId =
    "0x7573657231000000000000000000000000000000000000000000000000000000";
  let verifierId =
    "0x7665726966696572310000000000000000000000000000000000000000000000";
  let approverId =
    "0x617070726f766572310000000000000000000000000000000000000000000000";
  let issuerId =
    "0x6973737565723100000000000000000000000000000000000000000000000000";

  beforeEach(async () => {
    userManagerInstance = await UserManager.deployed(
      adminAddress,
      managerAddress,
      { from: ownerAddress }
    );
  });

  it(`1. Function to setAmin`, async () => {
    await userManagerInstance.setAdmin(adminAddress, { from: ownerAddress });
    let getadminAddress = await userManagerInstance.admin();
    assert.equal(
      getadminAddress,
      adminAddress,
      "Set admin address not changed"
    );
  });

  it(`2. Function to setManger`, async () => {
    await userManagerInstance.setManager(managerAddress);
    let getmanagerAddress = await userManagerInstance.manager();
    assert.equal(
      getmanagerAddress,
      managerAddress,
      "Set manager address not changed"
    );
  });

  it(`3. Function to add user`, async () => {
    let addUser = await userManagerInstance.addUser(userId, userAddress, {
      from: managerAddress,
    });

    let getUserAddress = await userManagerInstance.userMap(userId);
    let getUserId = await userManagerInstance.reverseUserMap(getUserAddress);
    assert.equal(getUserAddress, userAddress, "User not added");
    assert.equal(getUserId, userId, "User not added");

    truffleAssert.eventEmitted(addUser, "UserAdded", (e) => {
      return e.userId == userId && e.userAddress == userAddress;
    });
  });

  it(`4. Function to update user`, async () => {
    let updateUser = await userManagerInstance.updateUser(
      userId,
      newUserAddress,
      {
        from: adminAddress,
      }
    );

    let getUserId = await userManagerInstance.reverseUserMap(newUserAddress);
    let getUserAddress = await userManagerInstance.userMap(userId);
    assert.equal(newUserAddress, getUserAddress, "User address not exist");
    assert.equal(getUserId, userId, "User ID not exist");

    truffleAssert.eventEmitted(updateUser, "UserUpdated", (e) => {
      return e.userId == userId && e.userAddress == newUserAddress;
    });
  });

  it(`5. Funtion to add officer`, async () => {
    const kdaOfficer = {
      userId: userId,
      role: 3,
      department: 1,
      zone: 1,
    };

    let addOfficer = await userManagerInstance.addOfficer(
      kdaOfficer,
      officerAddress,
      {
        from: managerAddress,
      }
    );
    let kdaOfficerData = await userManagerInstance.officerMap(
      kdaOfficer.userId
    );
    let kdaOfficerAddress = await userManagerInstance.officerAddressMap(
      kdaOfficer.userId
    );
    let kdaOfficerId = await userManagerInstance.reverseOfficerMap(
      kdaOfficerAddress
    );
    assert.equal(kdaOfficerData.userId, kdaOfficer.userId, "Officer not added");
    assert.equal(kdaOfficerAddress, officerAddress, "Officer not added");
    assert.equal(kdaOfficerId, kdaOfficer.userId, "Officer not added");

    truffleAssert.eventEmitted(addOfficer, "OfficerAdded", (e) => {
      return (
        e.officerId == kdaOfficerData.userId &&
        e.officerAddress == kdaOfficerAddress
      );
    });
  });

  it(`6. Function to update officer`, async () => {
    const kdaOfficer = {
      userId: userId,
      role: 3,
      department: 1,
      zone: 1,
    };

    let officerUpdated = await userManagerInstance.updateOfficer(
      kdaOfficer,
      updateOfficerAddress,
      {
        from: managerAddress,
      }
    );
    let kdaOfficerData = await userManagerInstance.officerMap(
      kdaOfficer.userId
    );
    let kdaOfficerAddress = await userManagerInstance.officerAddressMap(
      kdaOfficer.userId
    );
    let kdaOfficerId = await userManagerInstance.reverseOfficerMap(
      kdaOfficerAddress
    );

    assert.equal(
      kdaOfficerData.userId,
      kdaOfficer.userId,
      "Officer not updated"
    );
    assert.equal(
      kdaOfficerAddress,
      updateOfficerAddress,
      "Officer not updated"
    );
    assert.equal(kdaOfficerId, kdaOfficer.userId, "Officer not updated");

    truffleAssert.eventEmitted(officerUpdated, "OfficerUpdated", (e) => {
      return (
        e.officerId == kdaOfficer.userId &&
        e.officerAddress == kdaOfficerAddress
      );
    });
  });

  it(`7. Function to remove officer`, async () => {
    let officerDeleted = await userManagerInstance.deleteOfficer(userId, {
      from: managerAddress,
    });
    let officerAddressMap = await userManagerInstance.officerAddressMap(userId);
    let officerMapAddress = await userManagerInstance.officerMap(userId);
    let officerId = await userManagerInstance.reverseOfficerMap(
      officerAddressMap
    );
    assert.equal(
      officerId,
      0x0000000000000000000000000000000000000000000000000000000000000000,
      "Officer not deleted 1"
    );
    assert.equal(
      officerMapAddress.userId,
      0x0000000000000000000000000000000000000000000000000000000000000000,
      "Officer not deleted 2"
    );
    assert.equal(
      officerAddressMap,
      0x0000000000000000000000000000000000000000000000000000000000000000,
      "Officer userId not exist"
    );

    truffleAssert.eventEmitted(officerDeleted, "OfficerDeleted", (e) => {
      return e.officerId == userId;
    });
  });

  it(`8. Function to add verifier`, async () => {
    let verifierStored = await userManagerInstance.addVerifier(
      verifierId,
      verifierAddress,
      {
        from: adminAddress,
      }
    );
    let getVerifierAddress = await userManagerInstance.verifierMap(verifierId);
    let getVerifierId = await userManagerInstance.reverseVerifierMap(
      getVerifierAddress
    );
    assert.equal(
      getVerifierAddress,
      verifierAddress,
      "Verifier address not added to user ID"
    );
    assert.equal(
      getVerifierId,
      verifierId,
      "Verifier ID not stored to address"
    );

    truffleAssert.eventEmitted(verifierStored, "VerifierAdded", (e) => {
      return e.verifierId == verifierId && e.verifierAddress == verifierAddress;
    });
  });

  it(`9. Function to update verifier`, async () => {
    let updatedVerifier = await userManagerInstance.updateVerifier(
      verifierId,
      updateVerifierAddress,
      {
        from: adminAddress,
      }
    );
    let getVerifierAddress = await userManagerInstance.verifierMap(verifierId);
    let getVerifierId = await userManagerInstance.reverseVerifierMap(
      getVerifierAddress
    );
    assert.equal(
      getVerifierAddress,
      updateVerifierAddress,
      "Verifier ID not exist"
    );
    assert.equal(getVerifierId, verifierId, "Verifier ID not exist");

    truffleAssert.eventEmitted(updatedVerifier, "VerifierUpdated", (e) => {
      return (
        e.verifierId == verifierId && e.verifierAddress == updateVerifierAddress
      );
    });
  });

  it(`10. Function to delete verifier`, async () => {
    let deleteVerifier = await userManagerInstance.deleteVerifier(verifierId, {
      from: adminAddress,
    });
    const getVerifierAddress = await userManagerInstance.verifierMap(
      verifierId
    );
    const getVerifierId = await userManagerInstance.reverseVerifierMap(
      getVerifierAddress
    );
    assert.equal(
      getVerifierAddress,
      0x0000000000000000000000000000000000000000000000000000000000000000,
      "Verifier ID not exist"
    );
    assert.equal(
      getVerifierId,
      0x0000000000000000000000000000000000000000000000000000000000000000,
      "Verifier address not exist"
    );

    truffleAssert.eventEmitted(deleteVerifier, "VerifierDeleted", (e) => {
      return e.C == verifierId;
    });
  });

  it(`11. Funtion to add Approver`, async () => {
    let approverStored = await userManagerInstance.addApprover(
      approverId,
      approverAddress,
      { from: adminAddress }
    );
    let getApproverAddress = await userManagerInstance.approverMap(approverId);
    let getApproverId = await userManagerInstance.reverseApproverMap(
      getApproverAddress
    );

    assert.equal(
      getApproverAddress,
      approverAddress,
      "Approver address not added in ID"
    );
    assert.equal(
      getApproverId,
      approverId,
      "Approver ID not stored in address"
    );

    truffleAssert.eventEmitted(approverStored, "ApproverAdded", (e) => {
      return e.approverId == approverId && e.approverAddress == approverAddress;
    });
  });

  it(`12. Funtion to update Approver`, async () => {
    let updatedApprover = await userManagerInstance.updateApprover(
      approverId,
      updateApproverAddress,
      { from: adminAddress }
    );

    let getApproverAddress = await userManagerInstance.approverMap(approverId);
    let getApproverId = await userManagerInstance.reverseVerifierMap(
      getApproverAddress
    );

    assert.equal(
      getApproverAddress,
      updateApproverAddress,
      "Update Approver address not same"
    );
    assert.equal(getApproverId, approverId, "Approver user ID not same");

    truffleAssert.eventEmitted(updatedApprover, "ApproverUpdated", (e) => {
      return (
        e.approverId == approverId && e.approverAddress == updateApproverAddress
      );
    });
  });

  it(`13. Funtion to delete Approver`, async () => {
    let deleteApprover = await userManagerInstance.deleteApprover(approverId, {
      from: adminAddress,
    });
    let getApproverAddress = await userManagerInstance.approverMap(approverId);
    let getApproverId = await userManagerInstance.reverseApproverMap(
      getApproverAddress
    );
    assert.equal(
      getApproverAddress,
      0x0000000000000000000000000000000000000000000000000000000000000,
      "Approver ID not exist"
    );
    assert.equal(
      getApproverId,
      0x00000000000000000000000000000000000000000000000000000000000000,
      "Approver address not exist"
    );

    truffleAssert.eventEmitted(deleteApprover, "ApproverDeleted", (e) => {
      return e.approverId == approverId;
    });
  });

  it(`14. Function to get Approver`, async () => {
    let getApproverAddress = await userManagerInstance.getApprover(approverId);
    assert.equal(
      getApproverAddress,
      0x00000000000000000000000000000000000000000000000000000000000000,
      "Approver ID not correct"
    );
  });

  it(`15. Function to add Issuer`, async () => {
    let issuerStored = await userManagerInstance.addIssuer(
      issuerId,
      issuerAddress,
      { from: adminAddress }
    );

    let getIssuerAddress = await userManagerInstance.issuerMap(issuerId);
    let getIssuerId = await userManagerInstance.reverseIssuerMap(
      getIssuerAddress
    );

    assert.equal(getIssuerAddress, issuerAddress, "Issuer address not same");
    assert.equal(getIssuerId, issuerId, "Issuer ID not same");

    truffleAssert.eventEmitted(issuerStored, "IssuerAdded", (e) => {
      return e.issuerId == issuerId && e.issuerAddress == issuerAddress;
    });
  });

  it(`16. Function to update Issuer`, async () => {
    let updateIssuerStored = await userManagerInstance.updateIssuer(
      issuerId,
      updateIssuerAddress,
      { from: adminAddress }
    );

    let getIssuerAddress = await userManagerInstance.issuerMap(issuerId);
    let getIssuerId = await userManagerInstance.reverseIssuerMap(
      getIssuerAddress
    );

    assert.equal(
      getIssuerAddress,
      updateIssuerAddress,
      "Issuer Address not same"
    );
    assert.equal(getIssuerId, issuerId, "Issuer ID not same");

    truffleAssert.eventEmitted(updateIssuerStored, "IssuerUpdated", (e) => {
      return e.issuerId == issuerId && e.issuerAddress == updateIssuerAddress;
    });
  });
  it(`17. Function to delete Issuer`, async () => {
    let deleteIssuer = await userManagerInstance.deleteIssuer(issuerId, {
      from: adminAddress,
    });
    let getIssuerAddress = await userManagerInstance.issuerMap(issuerId);
    let getIssuerId = await userManagerInstance.reverseIssuerMap(
      getIssuerAddress
    );

    assert.equal(
      getIssuerAddress,
      0x00000000000000000000000000000000000000000000000000000000000000,
      `Delete issuer not done for ID`
    );

    assert.equal(
      getIssuerId,
      0x00000000000000000000000000000000000000000000000000000000000000,
      `Delete issuer not done for address`
    );

    truffleAssert.eventEmitted(deleteIssuer, "IssuerDeleted", (e) => {
      return e.issuerId == issuerId;
    });
  });

  it(`18. Function to get Issuer`, async () => {
    let getIssuerAddress = await userManagerInstance.getIssuer(issuerId);
    assert.equal(
      getIssuerAddress,
      0x000000000000000000000000000000000000000000000000000000000000,
      "Issuer ID not correct"
    );
  });

  it(`19. Function to get User Id`, async () => {
    let getUserId = await userManagerInstance.getUserId(userAddress);
    assert.equal(getUserId, userId, "User address not correct");
  });

  it(`20. Function to get Verifier Id`, async () => {
    let getVerifierId = await userManagerInstance.getVerifierId(
      verifierAddress
    );
    assert.equal(getVerifierId, verifierId, "Verifier address not correct");
  });

  it(`21. Function to get Issuer Id`, async () => {
    let getIssuerId = await userManagerInstance.getIssuerId(issuerAddress);
    assert.equal(getIssuerId, issuerId, "Issuer address not correct");
  });

  it(`22. Function to get Role`, async () => {
    const kdaOfficerData = await userManagerInstance.getRole(userId);
    assert.equal(kdaOfficerData.role, 0, "User ID not correct");
  });

  it(`23. Function to get Role By Address`, async () => {
    let kdaOfficerData = await userManagerInstance.getRoleByAddress(
      officerAddress
    );
    assert.equal(
      kdaOfficerData.userId,
      0x0000000000000000000000000000000000000000000000000000000000000000,
      "KDA user ID not correct"
    );
  });
});
