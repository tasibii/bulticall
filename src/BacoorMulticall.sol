// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract BacoorMulticall is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant OPERATOR_ROLE = 0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929;

    struct Call {
        address target;
        bytes callData;
    }

    struct AdvancedCall {
        address target;
        bool allowFailure;
        bytes callData;
    }

    struct AdvancedCallValue {
        address target;
        bool allowFailure;
        uint256 value;
        bytes callData;
    }

    struct Result {
        bool success;
        bytes returnData;
    }

    error CallFailed(bytes4 fnSig);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin) public initializer {
        __AccessControl_init_unchained();
        __UUPSUpgradeable_init_unchained();

        _grantRole(OPERATOR_ROLE, defaultAdmin);
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    function aggregateCalls(
        bool requireSuccess,
        Call[] calldata calls
    )
        public
        payable
        onlyRole(OPERATOR_ROLE)
        returns (Result[] memory returnData)
    {
        uint256 length = calls.length;
        returnData = new Result[](length);
        Call calldata call;

        uint256 i;
        while (i < length) {
            call = calls[i];
            Result memory result = returnData[i];
            (result.success, result.returnData) = call.target.call(call.callData);
            if (requireSuccess) {
                if (!result.success) revert CallFailed(msg.sig);
            }
            unchecked {
                ++i;
            }
        }
    }

    function aggregateAdvancedCalls(AdvancedCall[] calldata calls)
        public
        payable
        onlyRole(OPERATOR_ROLE)
        returns (Result[] memory returnData)
    {
        uint256 length = calls.length;
        returnData = new Result[](length);
        AdvancedCall calldata icall;

        uint256 i;
        while (i < length) {
            icall = calls[i];
            Result memory result = returnData[i];
            (result.success, result.returnData) = icall.target.call(icall.callData);

            assembly {
                if iszero(or(calldataload(add(icall, 0x20)), mload(result))) {
                    mstore(0x00, 0xefa64d4b) // CallFailed(bytes4)
                    mstore(0x20, shl(0xe0, 0xae2d33cb)) // aggregateAdvancedCalls((address,bool,bytes)[])
                    revert(0x1c, 0x24)
                }
            }

            unchecked {
                ++i;
            }
        }
    }

    function aggregateAdvancedCallsWithValue(AdvancedCallValue[] calldata calls)
        public
        payable
        onlyRole(OPERATOR_ROLE)
        returns (Result[] memory returnData)
    {
        uint256 requiredValue;
        uint256 length = calls.length;
        returnData = new Result[](length);
        AdvancedCallValue calldata icall;

        uint256 i;
        while (i < length) {
            icall = calls[i];
            uint256 value = icall.value;
            Result memory result = returnData[i];
            (result.success, result.returnData) = icall.target.call{ value: value }(icall.callData);

            unchecked {
                requiredValue += value;
            }

            assembly {
                if iszero(or(calldataload(add(icall, 0x20)), mload(result))) {
                    mstore(0x00, 0xefa64d4b) // CallFailed(bytes4)
                    mstore(0x20, shl(0xe0, 0xe9d4d0dc)) // aggregateAdvancedCallsWithValue((address,bool,uint256,bytes)[])
                    revert(0x1c, 0x24)
                }
            }

            unchecked {
                ++i;
            }
        }
        require(msg.value == requiredValue, "Value mismatch");
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) { }
}
