const UserManager = artifacts.require("UserManager");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(UserManager, accounts[1], accounts[2], { from: accounts[0] });
};
