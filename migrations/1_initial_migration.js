const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const crowdSale = artifacts.require("vesting");

module.exports = async function(deployer) {

    await deployProxy(crowdSale,{ deployer, kind: "uups" });
    // await upgradeProxy("0x5Ffb1d89c92B3fD221254201Fb7E175751a39Ba5", SparkTokens, { deployer, kind: "uups" });
};