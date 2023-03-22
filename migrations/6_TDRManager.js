const TDRManager = artifacts.require("TDRManager");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(TDRManager, accounts[1], accounts[2], { from: accounts[0] });
};
