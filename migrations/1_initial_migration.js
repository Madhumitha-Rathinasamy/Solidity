const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const crowdSale = artifacts.require("vesting");

module.exports = async function(deployer) {

    await deployProxy(crowdSale,{ deployer, kind: "uups" });
    // await upgradeProxy("0x97690d698EA13532A9f025CB612C6e5ba476Ee37", crowdSale, { deployer, kind: "uups" });
};