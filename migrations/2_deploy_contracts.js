var DappTaxi = artifacts.require("./DappTaxi.sol");

module.exports = function (deployer) {
    deployer.deploy(DappTaxi);
};