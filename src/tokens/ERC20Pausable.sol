// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "./ERC20.sol";

contract ERC20Pausable is ERC20 {
    // --- Access Control ---
    address owner;
    modifier auth() { require(msg.sender == owner, "unauthorised"); _; }

    // --- Pause ---
    bool live = true;
    function stop() auth external { live = false; }
    function start() auth external { live = true; }

    // --- Init ---
    constructor() { owner = msg.sender; }

    // --- Token ---
    function approve(address usr, uint wad) override public returns (bool) {
        require(live, "paused");
        return super.approve(usr, wad);
    }
    function transfer(address dst, uint wad) override public returns (bool) {
        require(live, "paused");
        return super.transfer(dst, wad);
    }
    function transferFrom(address src, address dst, uint wad) override public returns (bool) {
        require(live, "paused");
        return super.transferFrom(src, dst, wad);
    }
}