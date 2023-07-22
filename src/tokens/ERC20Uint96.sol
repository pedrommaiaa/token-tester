// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

contract ERC20Uint96 {
    // --- ERC20 Data ---
    string  public constant name     = "Token";
    string  public constant symbol   = "TKN";
    uint8   public constant decimals = 18;
    uint96  internal supply;

    mapping (address => uint96)                      internal balances;
    mapping (address => mapping (address => uint96)) internal allowances;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    // --- Math ---
    function safe96(uint256 n) internal pure returns (uint96) {
        require(n < 2**96);
        return uint96(n);
    }

    // --- Getters ---
    function totalSupply() external view returns (uint) {
        return supply;
    }
    function balanceOf(address usr) external view returns (uint) {
        return balances[usr];
    }
    function allowance(address src, address dst) external view returns (uint) {
        return allowances[src][dst];
    }

    // --- Token ---
    function transfer(address dst, uint wad) virtual public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }
    function transferFrom(address src, address dst, uint wad) virtual public returns (bool) {
        uint96 amt = safe96(wad);

        if (src != msg.sender && allowances[src][msg.sender] != type(uint96).max) {
            allowances[src][msg.sender] -= amt;
        }

        balances[src] -= amt;
        balances[dst] += amt;
        emit Transfer(src, dst, wad);
        return true;
    }
    function approve(address usr, uint wad) virtual public returns (bool) {
        uint96 amt;
        if (wad == type(uint).max) {
            amt = type(uint96).max;
        } else {
            amt = safe96(wad);
        }

        allowances[msg.sender][usr] = amt;

        emit Approval(msg.sender, usr, amt);
        return true;
    }
}