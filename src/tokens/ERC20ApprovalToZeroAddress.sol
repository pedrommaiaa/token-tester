// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "./ERC20.sol";

contract ERC20ApprovalToZeroAddress is ERC20 {
    // --- Token ---
    function approve(address usr, uint wad) override public returns (bool) {
        require(usr != address(0), "no approval for the zero address");
        return super.approve(usr, wad);
    }
}