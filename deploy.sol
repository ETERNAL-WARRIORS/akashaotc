// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../contracts/OTCMaker.sol";

contract DeployOTCMaker is Script {
    function run() external {
        // Replace these with your own addresses
        address marketMaker = 0xYourMarketMakerAddress; // Market Maker wallet
        address akashaToken = 0xYourAkashaTokenAddress; // Akasha Token address
        uint256 tradeExpiry = 7 days;                  // Example: Block expiry set to 7 days

        vm.startBroadcast(); // Broadcasts transactions to the network
        OTCMaker otcMaker = new OTCMaker(marketMaker, akashaToken, tradeExpiry);
        vm.stopBroadcast();

        console.log("OTC Maker deployed at:", address(otcMaker));
    }
}
