// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IAuthority {
    function pause() external;
    function unpause() external;
    function setUserStatus(address account_, bool status_) external;
}

/**
 * !IMPORTANT - DO NOT USE THIS IN PRODUCT
 */
contract BlacklistDataGenerate {
    function nonpausableRequired(
        address[] calldata accounts,
        bool isBlacklist
    )
        public
        pure
        returns (bytes[] memory data)
    {
        uint256 len = accounts.length;
        data = new bytes[](len);
        for (uint256 i; i < len;) {
            data[i] = abi.encodeCall(IAuthority.setUserStatus, (accounts[i], isBlacklist));
            unchecked {
                ++i;
            }
        }
    }

    function pausableRequired(
        address[] calldata accounts,
        bool isBlacklist
    )
        public
        pure
        returns (bytes[] memory data)
    {
        uint256 len = accounts.length;
        if (len < 1) revert("accounts not be empty");

        data = new bytes[](len + 2);
        data[0] = abi.encodeCall(IAuthority.pause, ());
        for (uint256 i; i < len;) {
            data[i + 1] = abi.encodeCall(IAuthority.setUserStatus, (accounts[i], isBlacklist));

            unchecked {
                ++i;
            }
        }
        data[len + 1] = abi.encodeCall(IAuthority.unpause, ());
    }
}
