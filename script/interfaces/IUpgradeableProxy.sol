// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IUpgradeableProxy {
    // forgefmt: disable-start
    function upgradeToAndCall(
        address implementation,
        bytes calldata data
    ) external payable;
    // forgefmt: disable-end
}
