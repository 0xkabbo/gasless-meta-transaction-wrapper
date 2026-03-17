# Gasless Meta-Transaction Wrapper

A professional, flat-structured repository for implementing EIP-712 compliant meta-transactions. This is the gold standard for onboarding Web3 users without requiring them to hold native gas tokens (ETH/MATIC) immediately.

## Features
* **EIP-712 Standards:** Uses typed data hashing for secure, human-readable signing in wallets like MetaMask.
* **Signature Verification:** Robust logic to recover signers and prevent signature malleability.
* **Replay Protection:** Includes nonces for every user to ensure a transaction cannot be executed twice.
* **Relayer Ready:** Designed to work seamlessly with Gelato, OpenZeppelin Defender, or custom relayers.

## How It Works
1. **Sign:** The user signs a structured data message containing their intent (e.g., "Transfer 10 Tokens").
2. **Relay:** A relayer receives the signature and the transaction details.
3. **Execute:** The relayer calls `executeMetaTransaction`, pays the gas, and the contract verifies the signature before performing the logic.

## Security
This contract strictly follows the Checks-Effects-Interactions pattern and validates nonces to ensure security and atomicity.
