// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IMockERC721 {
    function mint(address to, uint256 id) external;
    function minta(address to, uint256 id) external;
}

contract MockERC721 is ERC721, IMockERC721 {
    constructor() ERC721("MockERC721", "M721") { }

    function mint(address to, uint256 id) public {
        _mint(to, id);
    }

    function minta(address to, uint256 id) public {
        if (msg.sender != 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf) revert();
        _mint(to, id);
    }
}
