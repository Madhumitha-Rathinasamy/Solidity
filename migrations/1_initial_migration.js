const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');
 
const Locker = artifacts.require("Locker");

// const  MigrationBeacon = artifacts.require("MigrationBeacon");

// const migrationBeaconProxy = artifacts.require("migrationBeaconProxy");

module.exports = async function(deployer) {

    await deployProxy(Locker,{ deployer, kind: "uups" });
    // await upgradeProxy("0x36918937dC9B5C979b86DD211061859f35176387", Locker, { deployer, kind: "uups" });

//  await deployer.deploy(vesting);
// const migrationInst = await vesting.deployed()
// await deployer.deploy(MigrationBeacon, migrationInst.address);
// let migrationBeconInst = await MigrationBeacon.deployed();
// await deployer.deploy(migrationBeaconProxy, migrationBeconInst.address,"0x0000000000000000000000000000000000000000000000000000000000000000");

};


 
 