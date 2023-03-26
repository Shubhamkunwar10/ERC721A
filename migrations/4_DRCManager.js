const DRCManager = artifacts.require("DRCManager");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(DRCManager, accounts[1], accounts[2], { from: accounts[0] });
};
