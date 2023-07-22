// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

contract ERC20MissingReturns {
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
    function transfer(address dst, uint wad) external {
        transferFrom(msg.sender, dst, wad);
    }
    function transferFrom(address src, address dst, uint wad) public {
        require(balanceOf[src] >= wad, "insufficient-balance");
        if (src != msg.sender && allowance[src][msg.sender] != type(uint).max) {
            require(allowance[src][msg.sender] >= wad, "insufficient-allowance");
            unchecked { allowance[src][msg.sender] -= wad; }
        }
        balanceOf[src] -= wad;
        balanceOf[dst] += wad;
        emit Transfer(src, dst, wad);
    }
    function approve(address usr, uint wad) external {
        allowance[msg.sender][usr] = wad;
        emit Approval(msg.sender, usr, wad);
    }
}