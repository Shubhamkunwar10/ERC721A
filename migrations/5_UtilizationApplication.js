const DuaStorage = artifacts.require("DuaStorage");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(DuaStorage, accounts[1], accounts[2], { from: accounts[0] });
};
