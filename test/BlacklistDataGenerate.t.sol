// SPDX-License-Identifier: Unlicense

pragma solidity 0.8.20;

import { console2, Test } from "forge-std/Test.sol";
import { IAuthority, BlacklistDataGenerate } from "src/BlacklistDataGenerate.sol";

contract BlacklistDataGenerateTest is Test {
    address[] public accounts;
    bytes[] public pausableResult;
    bytes[] public nonpausableResult;
    BlacklistDataGenerate public generator;

    function setUp() public {
        generator = new BlacklistDataGenerate();

        accounts = new address[](10);
        accounts[0] = 0x988ddE194401E64A48D60D482280894Fb2350A20;
        accounts[1] = 0x3d3B571857141859AF6d465372c3f4E89067410B;
        accounts[2] = 0x3e58377Dd30CC3BD218Dd2E0639c245BFe239D5B;
        accounts[3] = 0xC90Ad09D22bC9d2BDA0412C911D5fA8bB5b8c87f;
        accounts[4] = 0x30E8880fB75E456034E4369243d2e47EeFe680ED;
        accounts[5] = 0xd115aCdF6056A74a5eF64063043e0C4683BEFFdB;
        accounts[6] = 0xc56ddF834C3F1df8C4034d0B989F0266EB87B2a3;
        accounts[7] = 0x35268fCCB85dA8169b18f1960f867068168C38fc;
        accounts[8] = 0x176Df3eA679386f57d581d5f72db02aAd0F7D070;
        accounts[9] = 0x32bDE48b3d883DEc008b3D16233eD84fd5775FC3;

        nonpausableResult = new bytes[](10);
        nonpausableResult[0] = abi.encodeCall(IAuthority.setUserStatus, (accounts[0], true));
        nonpausableResult[1] = abi.encodeCall(IAuthority.setUserStatus, (accounts[1], true));
        nonpausableResult[2] = abi.encodeCall(IAuthority.setUserStatus, (accounts[2], true));
        nonpausableResult[3] = abi.encodeCall(IAuthority.setUserStatus, (accounts[3], true));
        nonpausableResult[4] = abi.encodeCall(IAuthority.setUserStatus, (accounts[4], true));
        nonpausableResult[5] = abi.encodeCall(IAuthority.setUserStatus, (accounts[5], true));
        nonpausableResult[6] = abi.encodeCall(IAuthority.setUserStatus, (accounts[6], true));
        nonpausableResult[7] = abi.encodeCall(IAuthority.setUserStatus, (accounts[7], true));
        nonpausableResult[8] = abi.encodeCall(IAuthority.setUserStatus, (accounts[8], true));
        nonpausableResult[9] = abi.encodeCall(IAuthority.setUserStatus, (accounts[9], true));

        pausableResult = new bytes[](12);
        pausableResult[0] = abi.encodeCall(IAuthority.pause, ());
        pausableResult[1] = abi.encodeCall(IAuthority.setUserStatus, (accounts[0], true));
        pausableResult[2] = abi.encodeCall(IAuthority.setUserStatus, (accounts[1], true));
        pausableResult[3] = abi.encodeCall(IAuthority.setUserStatus, (accounts[2], true));
        pausableResult[4] = abi.encodeCall(IAuthority.setUserStatus, (accounts[3], true));
        pausableResult[5] = abi.encodeCall(IAuthority.setUserStatus, (accounts[4], true));
        pausableResult[6] = abi.encodeCall(IAuthority.setUserStatus, (accounts[5], true));
        pausableResult[7] = abi.encodeCall(IAuthority.setUserStatus, (accounts[6], true));
        pausableResult[8] = abi.encodeCall(IAuthority.setUserStatus, (accounts[7], true));
        pausableResult[9] = abi.encodeCall(IAuthority.setUserStatus, (accounts[8], true));
        pausableResult[10] = abi.encodeCall(IAuthority.setUserStatus, (accounts[9], true));
        pausableResult[11] = abi.encodeCall(IAuthority.unpause, ());
    }

    function testPausableRequire() public {
        bytes[] memory data = generator.pausableRequired(accounts, true);

        for (uint256 i; i < data.length; ++i) {
            assertEq(data[i], pausableResult[i]);
        }
    }

    function testNonPausableRequire() public {
        bytes[] memory data = generator.nonpausableRequired(accounts, true);

        for (uint256 i; i < data.length; ++i) {
            assertEq(data[i], nonpausableResult[i]);
        }
    }
}
