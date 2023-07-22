// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "./ERC20.sol";

contract ERC20ApprovalRace is ERC20 {
    // --- Token ---
    function approve(address usr, uint wad) override public returns (bool) {
        require(allowance[msg.sender][usr] == 0, "unsafe-approve");
        return super.approve(usr, wad);
    }
}