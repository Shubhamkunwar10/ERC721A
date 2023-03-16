const userManager = artifacts.require("UserManager");

module.exports = function(deployer, network, accounts) {
    deployer.deploy(userManager, accounts[1], accounts[2], { from: accounts[0] });
}