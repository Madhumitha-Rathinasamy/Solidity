const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const vesting = artifacts.require("vesting");

const  MigrationBeacon = artifacts.require("MigrationBeacon");

const migrationBeaconProxy = artifacts.require("migrationBeaconProxy");

module.exports = async function(deployer) {

    // await deployProxy(vesting,{ deployer, kind: "uups" });
//     // await upgradeProxy("0x97690d698EA13532A9f025CB612C6e5ba476Ee37", crowdSale, { deployer, kind: "uups" });

 await deployer.deploy(vesting);
const migrationInst = await vesting.deployed()
await deployer.deploy(MigrationBeacon, migrationInst.address);
let migrationBeconInst = await MigrationBeacon.deployed();
await deployer.deploy(migrationBeaconProxy, migrationBeconInst.address,"0x0000000000000000000000000000000000000000000000000000000000000000");

};


 
 