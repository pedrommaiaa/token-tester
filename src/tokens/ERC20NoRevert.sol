// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

contract ERC20NoRevert {
    // --- ERC20 Data ---
    string  public constant name   = "Token";
    string  public constant symbol = "TKN";
    uint8   public decimals        = 18;
    uint256 public totalSupply;

    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    // --- Token ---
    function transfer(address dst, uint wad) external returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }
    function transferFrom(address src, address dst, uint wad) virtual public returns (bool) {
        if (balanceOf[src] < wad) return false;                        // insufficient src bal
        if (balanceOf[dst] >= (type(uint256).max - wad)) return false; // dst bal too high

        if (src != msg.sender && allowance[src][msg.sender] != type(uint).max) {
            if (allowance[src][msg.sender] < wad) return false;        // insufficient allowance
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);
        return true;
    }
    function approve(address usr, uint wad) virtual external returns (bool) {
        allowance[msg.sender][usr] = wad;
        emit Approval(msg.sender, usr, wad);
        return true;
    }
}