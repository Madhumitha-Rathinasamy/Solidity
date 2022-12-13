const tokenFactory = artifacts.require("FactoryToken");
const token = artifacts.require("Token");

module.exports = async function (deployer) {
  let erc20 = await token.deployed();
  await deployer.deploy(tokenFactory, erc20.address);
};
