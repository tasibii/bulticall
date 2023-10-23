// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract BacoorMulticall is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    using Address for address;
    /// @custom:oz-upgrades-unsafe-allow constructor

    bytes32 public constant OPERATOR_ROLE = 0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929;

    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin) public initializer {
        __AccessControl_init_unchained();
        __UUPSUpgradeable_init_unchained();

        _grantRole(OPERATOR_ROLE, defaultAdmin);
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    function exec(
        address target,
        bytes[] calldata data
    )
        public
        onlyRole(OPERATOR_ROLE)
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);
        for (uint256 i; i < data.length;) {
            results[i] = target.functionCall(data[i]);
            unchecked {
                ++i;
            }
        }
        return results;
    }

    function exec(
        address[] calldata targets,
        bytes[] calldata data
    )
        public
        onlyRole(OPERATOR_ROLE)
        returns (bytes[] memory results)
    {
        address target;
        bytes memory idata;
        uint256 length = data.length;

        results = new bytes[](length);

        if (targets.length != length) {
            revert("Length params mismatch");
        }

        for (uint256 i; i < length;) {
            idata = data[i];
            target = targets[i];
            results[i] = target.functionCall(idata);
            unchecked {
                ++i;
            }
        }
        return results;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) { }
}
