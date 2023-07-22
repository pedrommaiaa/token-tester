// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "./ERC20.sol";

contract ERC20TransferFee is ERC20 {
    uint immutable fee;

    // --- Init ---
    constructor(uint _fee) { fee = _fee; }

    // --- Token ---
    function transferFrom(address src, address dst, uint wad) override public returns (bool) {
        require(balanceOf[src] >= wad, "insufficient-balance");
        if (src != msg.sender && allowance[src][msg.sender] != type(uint).max) {
            require(allowance[src][msg.sender] >= wad, "insufficient-allowance");
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += (wad - fee);
        balanceOf[address(0)] += fee;

        emit Transfer(src, dst, (wad - fee));
        emit Transfer(src, address(0), fee);

        return true;
    }
}