// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IScript {
    function run(bytes calldata args) external;
}
