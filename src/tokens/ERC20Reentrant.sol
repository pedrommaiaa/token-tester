// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "./ERC20.sol";

contract ERC20Reentrant is ERC20 {
    // --- Call Targets ---
    mapping (address => Target) public targets;
    struct Target {
        bytes   data;
        address addr;
    }
    function setTarget(address addr, bytes calldata data) external {
        targets[msg.sender] = Target(data, addr);
    }

    // --- Token ---
    function transferFrom(address src, address dst, uint wad) override public returns (bool res) {
        res = super.transferFrom(src, dst, wad);
        Target memory target = targets[src];
        if (target.addr != address(0)) {
            (bool status,) = target.addr.call{gas: gasleft()}(target.data);
            require(status, "call failed");
        }
    }
}