// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/**
 * @title NativeMetaTransaction
 * @dev Abstract contract to enable gasless transactions via EIP-712 signatures.
 */
abstract contract NativeMetaTransaction is EIP712 {
    using ECDSA for bytes32;

    mapping(address => uint256) private _nonces;

    event MetaTransactionExecuted(address userAddress, address relayerAddress, bytes functionSignature);

    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    constructor(string memory name, string memory version) EIP712(name, version) {}

    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public payable returns (bytes memory) {
        MetaTransaction memory metaTx = MetaTransaction({
            nonce: _nonces[userAddress],
            from: userAddress,
            functionSignature: functionSignature
        });

        require(verify(userAddress, metaTx, r, s, v), "Signer and signature do not match");

        _nonces[userAddress]++;

        emit MetaTransactionExecuted(userAddress, msg.sender, functionSignature);

        // Append userAddress at the end of functionSignature to identify the original sender
        (bool success, bytes memory returnData) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );
        require(success, "Function call not successful");

        return returnData;
    }

    function hashMetaTransaction(MetaTransaction memory metaTx) internal view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256("MetaTransaction(uint256 nonce,address from,bytes functionSignature)"),
                    metaTx.nonce,
                    metaTx.from,
                    keccak256(metaTx.functionSignature)
                )
            )
        );
    }

    function verify(address signer, MetaTransaction memory metaTx, bytes32 r, bytes32 s, uint8 v) public view returns (bool) {
        return signer != address(0) && hashMetaTransaction(metaTx).recover(v, r, s) == signer;
    }

    function getNonce(address user) public view returns (uint256 nonce) {
        nonce = _nonces[user];
    }

    function _msgSender() internal view virtual returns (address sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := mload(add(array, index))
            }
        } else {
            sender = msg.sender;
        }
        return sender;
    }
}
