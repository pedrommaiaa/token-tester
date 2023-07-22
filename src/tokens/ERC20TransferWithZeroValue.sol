// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "./ERC20.sol";

contract ERC20TransferWithZeroValue is ERC20 {
    // --- Token ---
    function transferFrom(address src, address dst, uint wad) override public returns (bool) {
        require(wad != 0, "zero-value-transfer");
        return super.transferFrom(src, dst, wad);
    }
}