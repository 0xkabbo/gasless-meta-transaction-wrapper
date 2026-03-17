// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./NativeMetaTransaction.sol";

/**
 * @title ExampleToken
 * @dev A simple ERC20 token that supports gasless transfers.
 */
contract ExampleToken is ERC20, NativeMetaTransaction {
    constructor() ERC20("GaslessToken", "GTK") NativeMetaTransaction("GaslessToken", "1") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    // Overriding _msgSender() to support meta-transactions
    function _msgSender() internal view override(NativeMetaTransaction) returns (address) {
        return NativeMetaTransaction._msgSender();
    }
    
    // Standard ERC20 context helper
    function _contextSuffixLength() internal view override returns (uint256) {
        return 20;
    }
}
