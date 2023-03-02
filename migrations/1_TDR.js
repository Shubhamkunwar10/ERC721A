const TdrStorage = artifacts.require("TdrStorage");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(TdrStorage, accounts[1], accounts[2], { from: accounts[0] });
};
