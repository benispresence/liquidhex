# Liquid HEX Solidity Contract

This is the repository for the "Liquid HEX" smart contract, which will be deployed to Pulsechain. LiquidHEX.sol is the main contract that inherits the ERC20 implementation standards from OpenZeppelin. You can find the exact dependencies in the OpenZeppelin contracts, which are fully audited. LiquidHEX.sol introduces a sole claim function that depends on the Merkle root provided at the time of deployment. Here is how the claim function works:

### Claim Function Explanation

The `claim` function in the `LiquidHEX` smart contract is essential for distributing tokens under specific conditions. Below is a step-by-step explanation of how this function operates:

1. **Time Constraints**
   - The function checks if the current blockchain timestamp (`block.timestamp`) is within a specified window, defined by `mintingStartDate` and `mintingEndDate`. This ensures that claims can only be processed during this designated period.

2. **Unique Claims**
   - It verifies whether the claim identified by `id` has already been processed (`hasClaimedId[id]`). This mechanism prevents multiple claims with the same ID, ensuring each eligible claim can only be used once.

3. **Signature Verification (Optional)**
   - If a signature is provided, the function performs the following steps to verify the claimant’s identity:
     - Constructs a message hash from the claimant's address (`msg.sender`), the claim `id`, and the `amount`.
     - Converts this hash into an Ethereum-specific signed message hash.
     - Recovers the address from the provided signature using the signed message hash, determining if the signature truly belongs to an eligible claimant (`eligibleAddress`).

4. **Node Construction**
   - Constructs a data node using the `id`, the `eligibleAddress` (determined from the signature or assumed to be `msg.sender` if no signature is provided), the `amount`, and the minting dates. This node is a hashed representation of these details.

5. **Merkle Proof Verification**
   - Verifies the constructed node against the stored `merkleRoot` using the provided Merkle proof (`merkleProof`). This step is crucial as it confirms that the claim details are part of a pre-approved list encapsulated by the `merkleRoot`.

6. **Token Minting**
   - Marks the `id` as claimed to prevent future claims with the same `id`.
   - Mints the specified `amount` of tokens to the claimant’s address (`msg.sender`).

7. **Event Logging**
   - Logs the claim event, capturing the `id`, the claimant's address, the amount of tokens minted, and the timestamp of the claim.

This function utilizes cryptographic signatures and Merkle proofs to ensure secure and verifiable distribution of tokens to eligible users within a defined period on the blockchain.
