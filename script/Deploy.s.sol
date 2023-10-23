// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseScript.s.sol";
import { BacoorMulticall } from "src/BacoorMulticall.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployScript is BaseScript {
    /**
     * * @dev For non-proxy deployment, the return value must be `address deployment`,
     * * and for proxy deployment, it should be `address proxy, address implementation, string memory kind`
     */
    function run() public returns (address proxy, address implementation, string memory kind) {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));
        (proxy, implementation, kind) = _deployUUPS();
        vm.stopBroadcast();
    }

    function _deployUUPS() internal returns (address proxy, address implementation, string memory kind) {
        (proxy, implementation, kind) = deployProxyRaw(
            type(BacoorMulticall).name,
            abi.encodeCall(BacoorMulticall.initialize, vm.addr(vm.envUint("DEPLOYER_PRIVATE_KEY"))),
            "uups"
        );
    }
}
