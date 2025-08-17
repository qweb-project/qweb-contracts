// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import "../WebsiteRegistry.sol";

contract WebsiteRegistryTest is Test {
    WebsiteRegistry public registry;

    function setUp() public {
        registry = new WebsiteRegistry();
    }

    function testRegisterWebsite() public {
        registry.registerWebsite("https://google.com", address(this), 1 ether);
        WebsiteRegistry.Website memory website = registry.getWebsite("https://google.com");
        assertEq(website.owner, address(this));
    }

    function testGetWebsite() public {
        registry.registerWebsite("https://google.com", address(this), 1 ether);
        WebsiteRegistry.Website memory website = registry.getWebsite("https://google.com");
        assertEq(website.owner, address(this));
    }

    function testRemoveWebsite() public {
        registry.registerWebsite("https://google.com", address(this), 1 ether);
        registry.removeWebsite("https://google.com");
        vm.expectRevert("Website not found");
        registry.getWebsite("https://google.com");
    }

    function testRemoveWebsite_RevertWhen_NotOwner() public {
        registry.registerWebsite("https://google.com", address(this), 1 ether);
        vm.prank(address(1));
        vm.expectRevert("Only website owner can remove");
        registry.removeWebsite("https://google.com");
    }
}
