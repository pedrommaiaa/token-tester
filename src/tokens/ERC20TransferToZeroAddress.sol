// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "./ERC20.sol";

contract ERC20TransferToZeroAddress is ERC20 {
    // --- Token ---
    function transferFrom(address src, address dst, uint wad) override public returns (bool) {
        require(dst != address(0), "transfer-to-zero");
        return super.transferFrom(src, dst, wad);
    }
}