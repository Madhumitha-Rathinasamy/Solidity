//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract MigrationBeacon is UpgradeableBeacon {
    constructor(address _implementation) UpgradeableBeacon(_implementation) {}

    function upgrateMigration(address _newImpl) external {
        upgradeTo(_newImpl);
    }
}