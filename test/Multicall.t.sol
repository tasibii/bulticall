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

    error AccessControlUnauthorizedAccount(address, bytes32);

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

    function testAggregateCallsRequireSuccessWhenSuccess() public {
        BacoorMulticall.Call[] memory call = new BacoorMulticall.Call[](4);
        call[0] = BacoorMulticall.Call(address(token), abi.encodeCall(IMockERC20.mint, (bob, 100)));
        call[1] = BacoorMulticall.Call(address(token), abi.encodeCall(IMockERC20.mint, (alice, 1000)));
        call[2] = BacoorMulticall.Call(address(nft), abi.encodeCall(IMockERC721.mint, (bob, 1)));
        call[3] = BacoorMulticall.Call(address(nft), abi.encodeCall(IMockERC721.mint, (alice, 2)));

        vm.startPrank(admin);
        multicaller.aggregateCalls(true, call);
        vm.stopPrank();

        assertEq(token.balanceOf(bob), 100);
        assertEq(token.balanceOf(alice), 1000);
        assertEq(nft.ownerOf(1), bob);
        assertEq(nft.ownerOf(2), alice);
    }

    function testAggregateCallsNoneRequireSuccessWhenFail() public {
        BacoorMulticall.Call[] memory call = new BacoorMulticall.Call[](4);
        call[0] = BacoorMulticall.Call(address(token), abi.encodeCall(IMockERC20.minta, (bob, 100)));
        call[1] = BacoorMulticall.Call(address(token), abi.encodeCall(IMockERC20.minta, (alice, 1000)));
        call[2] = BacoorMulticall.Call(address(nft), abi.encodeCall(IMockERC721.minta, (bob, 1)));
        call[3] = BacoorMulticall.Call(address(nft), abi.encodeCall(IMockERC721.minta, (alice, 2)));

        vm.startPrank(admin);
        multicaller.aggregateCalls(false, call);
        vm.stopPrank();

        assertEq(token.balanceOf(bob), 0);
        assertEq(token.balanceOf(alice), 0);
        assertEq(nft.balanceOf(bob), 0);
        assertEq(nft.balanceOf(alice), 0);
    }

    function testAggregateCallsWhenSuccess() public {
        BacoorMulticall.AdvancedCall[] memory call = new BacoorMulticall.AdvancedCall[](4);
        call[0] = BacoorMulticall.AdvancedCall(address(token), false, abi.encodeCall(IMockERC20.mint, (bob, 100)));
        call[1] = BacoorMulticall.AdvancedCall(address(token), false, abi.encodeCall(IMockERC20.mint, (alice, 1000)));
        call[2] = BacoorMulticall.AdvancedCall(address(nft), false, abi.encodeCall(IMockERC721.mint, (bob, 1)));
        call[3] = BacoorMulticall.AdvancedCall(address(nft), false, abi.encodeCall(IMockERC721.mint, (alice, 2)));

        vm.startPrank(admin);
        multicaller.aggregateAdvancedCalls(call);
        vm.stopPrank();

        assertEq(token.balanceOf(bob), 100);
        assertEq(token.balanceOf(alice), 1000);
        assertEq(nft.ownerOf(1), bob);
        assertEq(nft.ownerOf(2), alice);
    }

    function testAggregateCallsNotAllowFailureWhenFail() public {
        BacoorMulticall.AdvancedCall[] memory call = new BacoorMulticall.AdvancedCall[](4);
        call[0] = BacoorMulticall.AdvancedCall(address(token), false, abi.encodeCall(IMockERC20.minta, (bob, 100)));
        call[1] = BacoorMulticall.AdvancedCall(address(token), false, abi.encodeCall(IMockERC20.minta, (alice, 1000)));
        call[2] = BacoorMulticall.AdvancedCall(address(nft), false, abi.encodeCall(IMockERC721.minta, (bob, 1)));
        call[3] = BacoorMulticall.AdvancedCall(address(nft), false, abi.encodeCall(IMockERC721.minta, (alice, 2)));

        vm.startPrank(admin);
        vm.expectRevert(
            abi.encodeWithSelector(BacoorMulticall.CallFailed.selector, BacoorMulticall.aggregateAdvancedCalls.selector)
        );
        multicaller.aggregateAdvancedCalls(call);
        vm.stopPrank();
    }

    function testAggregateCallsAllowFailureSuccessWhenFail() public {
        BacoorMulticall.AdvancedCall[] memory call = new BacoorMulticall.AdvancedCall[](4);
        call[0] = BacoorMulticall.AdvancedCall(address(token), true, abi.encodeCall(IMockERC20.minta, (bob, 100)));
        call[1] = BacoorMulticall.AdvancedCall(address(token), true, abi.encodeCall(IMockERC20.minta, (alice, 1000)));
        call[2] = BacoorMulticall.AdvancedCall(address(nft), true, abi.encodeCall(IMockERC721.minta, (bob, 1)));
        call[3] = BacoorMulticall.AdvancedCall(address(nft), true, abi.encodeCall(IMockERC721.minta, (alice, 2)));

        vm.startPrank(admin);
        // vm.expectRevert(
        //     abi.encodeWithSelector(BacoorMulticall.CallFailed.selector,
        // BacoorMulticall.aggregateAdvancedCalls.selector)
        // );
        multicaller.aggregateAdvancedCalls(call);
        vm.stopPrank();

        assertEq(token.balanceOf(bob), 0);
        assertEq(token.balanceOf(alice), 0);
        assertEq(nft.balanceOf(bob), 0);
        assertEq(nft.balanceOf(alice), 0);
    }

    function testAggregateCallsMixedRevert() public {
        BacoorMulticall.AdvancedCall[] memory call = new BacoorMulticall.AdvancedCall[](8);
        call[0] = BacoorMulticall.AdvancedCall(address(token), true, abi.encodeCall(IMockERC20.mint, (bob, 100)));
        call[1] = BacoorMulticall.AdvancedCall(address(token), false, abi.encodeCall(IMockERC20.mint, (alice, 1000)));
        call[2] = BacoorMulticall.AdvancedCall(address(nft), true, abi.encodeCall(IMockERC721.minta, (bob, 1)));
        call[3] = BacoorMulticall.AdvancedCall(address(nft), false, abi.encodeCall(IMockERC721.minta, (alice, 2)));
        call[4] = BacoorMulticall.AdvancedCall(address(nft), true, abi.encodeCall(IMockERC721.mint, (bob, 1)));
        call[5] = BacoorMulticall.AdvancedCall(address(nft), false, abi.encodeCall(IMockERC721.mint, (alice, 2)));
        call[6] = BacoorMulticall.AdvancedCall(address(token), true, abi.encodeCall(IMockERC20.minta, (bob, 100)));
        call[7] = BacoorMulticall.AdvancedCall(address(token), false, abi.encodeCall(IMockERC20.minta, (alice, 1000)));

        vm.startPrank(admin);
        vm.expectRevert(
            abi.encodeWithSelector(BacoorMulticall.CallFailed.selector, BacoorMulticall.aggregateAdvancedCalls.selector)
        );
        multicaller.aggregateAdvancedCalls(call);
        vm.stopPrank();
    }

    function testAggregateCallsMixedNotRevert() public {
        BacoorMulticall.AdvancedCall[] memory call = new BacoorMulticall.AdvancedCall[](8);
        call[0] = BacoorMulticall.AdvancedCall(address(token), true, abi.encodeCall(IMockERC20.mint, (bob, 100)));
        call[1] = BacoorMulticall.AdvancedCall(address(token), false, abi.encodeCall(IMockERC20.mint, (alice, 1000)));
        call[2] = BacoorMulticall.AdvancedCall(address(nft), true, abi.encodeCall(IMockERC721.minta, (bob, 1)));
        call[3] = BacoorMulticall.AdvancedCall(address(nft), true, abi.encodeCall(IMockERC721.minta, (alice, 2)));
        call[4] = BacoorMulticall.AdvancedCall(address(nft), true, abi.encodeCall(IMockERC721.mint, (bob, 1)));
        call[5] = BacoorMulticall.AdvancedCall(address(nft), false, abi.encodeCall(IMockERC721.mint, (alice, 2)));
        call[6] = BacoorMulticall.AdvancedCall(address(token), true, abi.encodeCall(IMockERC20.minta, (bob, 100)));
        call[7] = BacoorMulticall.AdvancedCall(address(token), true, abi.encodeCall(IMockERC20.minta, (alice, 1000)));

        vm.startPrank(admin);
        multicaller.aggregateAdvancedCalls(call);
        vm.stopPrank();

        assertEq(token.balanceOf(bob), 100);
        assertEq(token.balanceOf(alice), 1000);
        assertEq(nft.ownerOf(1), bob);
        assertEq(nft.ownerOf(2), alice);
    }
}
