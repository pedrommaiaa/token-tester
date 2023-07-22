// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

contract ERC20TransferFromSelf {
    // --- ERC20 Data ---
    string  public constant name     = "Token";
    string  public constant symbol   = "TKN";
    uint8   public constant decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    // --- Token ---
    function transfer(address dst, uint wad) virtual public returns (bool) {
        _transfer(msg.sender, dst, wad);
        return true;
    }
    function transferFrom(address src, address dst, uint wad) virtual public returns (bool) {
        if (allowance[src][msg.sender] != type(uint).max) {
            require(allowance[src][msg.sender] >= wad, "insufficient-allowance");
            allowance[src][msg.sender] -= wad;
        }
        _transfer(src, dst, wad);
        return true;
    }
    function approve(address usr, uint wad) virtual public returns (bool) {
        allowance[msg.sender][usr] = wad;
        emit Approval(msg.sender, usr, wad);
        return true;
    }

    // --- Internal ---
    function _transfer(address src, address dst, uint wad) private {
        require(balanceOf[src] >= wad, "insufficient-balance");
        balanceOf[src] -= wad;
        balanceOf[dst] += wad;
        emit Transfer(src, dst, wad);
    }
}