// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract LiquidHEX is ERC20, ERC20Permit {
    using ECDSA for bytes32;
    bytes32 public immutable merkleRoot;
    mapping(uint256 => bool) public hasClaimedId; // Tracks claimed IDs

    event Claimed(uint256 indexed id, address indexed account, uint256 amount, uint256 timestamp);

    constructor(bytes32 _merkleRoot)
        ERC20("LiquidHEX", "LHEX")
        ERC20Permit("LiquidHEX") {
            merkleRoot = _merkleRoot;
    }

    // Override the decimals function to set to 8 decimal places
    function decimals() public view virtual override returns (uint8) {
        return 8;
    }
    
    function claim(
        uint256 id,
        uint256 amount,
        uint256 mintingStartDate,
        uint256 mintingEndDate,
        bytes32[] calldata merkleProof,
        bytes calldata signature
    ) external {
        require(block.timestamp >= mintingStartDate && block.timestamp <= mintingEndDate, "Not within the minting window.");
        require(!hasClaimedId[id], "This ID has already been claimed.");

        address eligibleAddress;

        if (signature.length > 0) {
            // Case with signature: Recover the eligible address from the signature
            bytes32 messageHash = keccak256(abi.encode(msg.sender, id, amount));
            bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
            eligibleAddress = ethSignedMessageHash.recover(signature);
        } else {
            eligibleAddress = msg.sender;
        }

        // Construct the node from the eligible address
        bytes32 node = keccak256(abi.encode(id, eligibleAddress, amount, mintingStartDate, mintingEndDate));

        // Verify the provided Merkle proof against the stored Merkle root
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "Invalid Merkle proof.");

        // Record the claim and mint the tokens to the recipient address if not the same
        hasClaimedId[id] = true;
        _mint(msg.sender, amount);

        emit Claimed(id, msg.sender, amount, block.timestamp);
    }

}
