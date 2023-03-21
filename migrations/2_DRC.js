const DrcStorage = artifacts.require("DrcStorage");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(DrcStorage, accounts[1], accounts[2], { from: accounts[0] });
};
