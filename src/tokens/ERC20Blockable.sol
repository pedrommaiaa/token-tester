// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "./ERC20.sol";

contract ERC20Blockable is ERC20 {
    // --- Access Control ---
    address owner;
    modifier auth() { require(msg.sender == owner, "unauthorised"); _; }

    // --- BlockList ---
    mapping(address => bool) blocked;
    function blockUsr(address usr) auth public { blocked[usr] = true;  }
    function allowUsr(address usr) auth public { blocked[usr] = false; }

    // --- Init ---
    constructor() { owner = msg.sender; }

    // --- Token ---
    function transferFrom(address src, address dst, uint wad) override public returns (bool) {
        require(!blocked[src] && !blocked[dst], "blocked");
        return super.transferFrom(src, dst, wad);
    }
}