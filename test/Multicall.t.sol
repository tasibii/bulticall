// SPDX-License-Identifier: Unlicense

pragma solidity 0.8.20;

import { console2, Test } from "forge-std/Test.sol";
import { BacoorMulticall } from "src/BacoorMulticall.sol";
import { IMockERC20, MockERC20 } from "./utils/MockERC20.sol";
import { IMockERC721, MockERC721 } from "./utils/MockERC721.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TestMulticall is Test {
    MockERC20 public token;
    MockERC721 public nft;
    BacoorMulticall public multicaller;

    address admin = vm.addr(1);
    address attacker = vm.addr(2);
    address bob = vm.addr(3);
    address alice = vm.addr(4);

    function setUp() public {
        vm.startPrank(admin);
        token = new MockERC20();
        nft = new MockERC721();
        multicaller = BacoorMulticall(
            payable(
                new ERC1967Proxy(address(new BacoorMulticall()), abi.encodeCall(BacoorMulticall.initialize, (admin)))
            )
        );
        vm.stopPrank();
    }

    function testExecSingleTarget() public {
        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeCall(IMockERC20.mint, (bob, 100));
        data[1] = abi.encodeCall(IMockERC20.mint, (alice, 1000));

        vm.startPrank(admin);
        multicaller.exec(address(token), data);
        vm.stopPrank();

        assertEq(token.balanceOf(bob), 100);
        assertEq(token.balanceOf(alice), 1000);
    }

    function testExecMultiTarget() public {
        address[] memory targets = new address[](2);
        targets[0] = address(token);
        targets[1] = address(nft);

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeCall(IMockERC20.mint, (bob, 100));
        data[1] = abi.encodeCall(IMockERC721.mint, (alice, 1));

        vm.startPrank(admin);
        multicaller.exec(targets, data);
        vm.stopPrank();

        assertEq(token.balanceOf(bob), 100);
        assertEq(nft.ownerOf(1), alice);
    }
}
