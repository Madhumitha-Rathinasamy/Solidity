//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

// import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract migrationBeaconProxy is BeaconProxy {
    constructor(address _migrationBeacon, bytes memory data) BeaconProxy(_migrationBeacon, data) {}
}