// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/OTCMaker.sol";

contract OTCMakerTest is Test {
    OTCMaker otcMaker;

    address marketMaker = address(0x1);
    address akashaToken = address(0x2);

    function setUp() public {
        otcMaker = new OTCMaker(marketMaker, akashaToken, 7 days);
    }

    function testDeployment() public {
        assertEq(otcMaker.marketMaker(), marketMaker);
        assertEq(otcMaker.akashaToken(), akashaToken);
        assertEq(otcMaker.tradeExpiry(), 7 days);
    }

    function testLoadBlocks() public {
        uint256;
        uint256;

        sizes[0] = 100;
        sizes[1] = 500;

        prices[0] = 10;
        prices[1] = 50;

        vm.prank(marketMaker); // Simulate calls from the market maker
        otcMaker.loadBlocks(sizes, prices);

        (uint256 size, uint256 price, bool isAvailable) = otcMaker.blocks(0);
        assertEq(size, 100);
        assertEq(price, 10);
        assertEq(isAvailable, true);
    }
}
