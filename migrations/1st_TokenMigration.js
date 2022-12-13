const token = artifacts.require("Token");

module.exports = async function (deployer) {
    await deployer.deploy(token);
};


// const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

// const Tokens = artifacts.require("Token");

// module.exports = async function(deployer) {

//     await deployProxy(Tokens,"mad", "mad", 1000000000000,{ deployer, kind: "uups" });
//     // await upgradeProxy("0x5Ffb1d89c92B3fD221254201Fb7E175751a39Ba5", Tokens, { deployer, kind: "uups" });
// };