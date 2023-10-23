// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IMockERC20 {
    function mint(address to, uint256 value) external;
}

contract MockERC20 is ERC20, IMockERC20 {
    constructor() ERC20("MockERC20", "M20") { }

    function mint(address to, uint256 value) public {
        _mint(to, value);
    }
}
