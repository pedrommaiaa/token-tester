// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {Strings} from "openzeppelin-contracts/utils/Strings.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {ERC20} from "./tokens/ERC20.sol";
import {ERC20Uint96} from "./tokens/ERC20Uint96.sol";
import {ERC20Pausable} from "./tokens/ERC20Pausable.sol";
import {ERC20NoRevert} from "./tokens/ERC20NoRevert.sol";
import {ERC20DaiPermit} from "./tokens/ERC20DaiPermit.sol";
import {ERC20Blockable} from "./tokens/ERC20Blockable.sol";
import {ERC20Reentrant} from "./tokens/ERC20Reentrant.sol";
import {ERC20Upgradable} from "./tokens/ERC20Upgradable.sol";
import {ERC20TransferFee} from "./tokens/ERC20TransferFee.sol";
import {ERC20LowDecimals} from "./tokens/ERC20LowDecimals.sol";
import {ERC20HighDecimals} from "./tokens/ERC20HighDecimals.sol";
import {ERC20ApprovalRace} from "./tokens/ERC20ApprovalRace.sol";
import {ERC20ReturnsFalse} from "./tokens/ERC20ReturnsFalse.sol";
import {ERC20Proxied, TokenProxy} from "./tokens/ERC20Proxied.sol";
import {ERC20MissingReturns} from "./tokens/ERC20MissingReturns.sol";
import {ERC20Bytes32Metadata} from "./tokens/ERC20Bytes32Metadata.sol";
import {ERC20TransferFromSelf} from "./tokens/ERC20TransferFromSelf.sol";
import {ERC20ApprovalToZeroAddress} from "./tokens/ERC20ApprovalToZeroAddress.sol";
import {ERC20ApprovalWithZeroValue} from "./tokens/ERC20ApprovalWithZeroValue.sol";
import {ERC20TransferToZeroAddress} from "./tokens/ERC20TransferToZeroAddress.sol";
import {ERC20TransferWithZeroValue} from "./tokens/ERC20TransferWithZeroValue.sol";

contract TokenTester is Test {
    IERC20 public tokenTest;

    address[] public tokens;
    string[] public tokenNames;
    string public tokenNameStr;

    enum Tokens {
        WETH,
        ERC20,
        ERC20Uint96,
        ERC20Pausable,
        ERC20NoRevert,
        ERC20DaiPermit,
        ERC20BlockList,
        ERC20Reentrant,
        ERC20Upgradable,
        ERC20TransferFee,
        ERC20LowDecimals,
        ERC20HighDecimals,
        ERC20ApprovalRace,
        ERC20ReturnsFalse,
        ERC20MissingReturns,
        ERC20Proxied,
        ERC20Bytes32Metadata,
        ERC20TransferFromSelf,
        ERC20ApprovalToZeroAddress,
        ERC20ApprovalWithZeroValue,
        ERC20TransferToZeroAddress,
        ERC20TransferWithZeroValue
    }

    constructor() {
        tokens.push(address(new WETH()));
        tokenNames.push("WETH");
        
        tokens.push(address(new ERC20()));
        tokenNames.push("ERC20");

        tokens.push(address(new ERC20Uint96()));
        tokenNames.push("Uint96");

        tokens.push(address(new ERC20Pausable()));
        tokenNames.push("Pausable");

        tokens.push(address(new ERC20NoRevert()));
        tokenNames.push("NoRevert");

        tokens.push(address(new ERC20DaiPermit()));
        tokenNames.push("DaiPermit");

        tokens.push(address(new ERC20Blockable()));
        tokenNames.push("BlockList");

        tokens.push(address(new ERC20Reentrant()));
        tokenNames.push("Reentrant");

        tokens.push(address(new ERC20Upgradable()));
        tokenNames.push("Upgradable");

        tokens.push(address(new ERC20TransferFee(0.001 ether)));
        tokenNames.push("TransferFee");

        tokens.push(address(new ERC20LowDecimals()));
        tokenNames.push("LowDecimals");

        tokens.push(address(new ERC20HighDecimals()));
        tokenNames.push("HighDecimals");

        tokens.push(address(new ERC20ApprovalRace()));
        tokenNames.push("ApprovalRace");

        tokens.push(address(new ERC20ReturnsFalse()));
        tokenNames.push("ReturnsFalse");

        tokens.push(address(new ERC20MissingReturns()));
        tokenNames.push("MissingReturns");

        ERC20Proxied proxied = new ERC20Proxied();
        TokenProxy proxy = new TokenProxy(address(proxied));
        tokens.push(address(proxy));
        tokenNames.push("Proxied");

        tokens.push(address(new ERC20Bytes32Metadata()));
        tokenNames.push("Bytes32Metadata");

        tokens.push(address(new ERC20TransferFromSelf()));
        tokenNames.push("TransferFromSelf");

        tokens.push(address(new ERC20ApprovalToZeroAddress()));
        tokenNames.push("ApprovalToZeroAddress");

        tokens.push(address(new ERC20ApprovalWithZeroValue()));
        tokenNames.push("ApprovalWithZeroValue");

        tokens.push(address(new ERC20TransferToZeroAddress()));
        tokenNames.push("TransferToZeroAddress");

        tokens.push(address(new ERC20TransferWithZeroValue()));
        tokenNames.push("TransferWithZeroValue");

        uint256 i;
        for (i; i < tokenNames.length;) {
            tokenNameStr = string.concat(tokenNameStr, tokenNames[i]);
            tokenNameStr = string.concat(tokenNameStr, ",");
            unchecked {
                ++i;
            }
        }
    }

    modifier tokenTester(Tokens index) {
        // short circuit if TOKEN_TEST is not enabled
        bool enabled = vm.envBool("TOKEN_TEST");
        if (!enabled) {
            // default to ERC20
            tokenTest = IERC20(address(tokens[uint256(index)]));
            _;
            return;
        }

        // the ffi script will set `FORGE_TOKEN_TESTER_ID=n`
        uint256 envTokenId = vm.envOr("FORGE_TOKEN_TESTER_ID", uint256(0));

        if (envTokenId != 0) {
            tokenTest = IERC20(tokens[envTokenId - 1]);
            _;
        } else {
            bytes32 a;
            assembly {
                a := calldataload(0x0)
            }

            string[] memory inputs = new string[](5);
            inputs[0] = "node";
            inputs[1] = "dist/script.js";
            inputs[2] = Strings.toHexString(uint256(a));
            inputs[3] = Strings.toHexString(uint256(tokens.length));
            inputs[4] = tokenNameStr;

            vm.ffi(inputs);
        }
    }
}
