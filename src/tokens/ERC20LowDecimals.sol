// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "./ERC20.sol";

contract ERC20LowDecimals is ERC20 {
    constructor() { decimals = 2; }
}