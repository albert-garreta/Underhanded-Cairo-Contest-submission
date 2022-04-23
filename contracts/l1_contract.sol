// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../interfaces/IStarknetCore.sol";

/* ----------------------------------------------------------------
The actual implementation of this contract is not important to us
We assume that there are no security issues here
The contract written here is provided for testing purposes
*/

contract L1_contract {
    // The StarkNet core contract.
    IStarknetCore starknetCore;

    constructor(address starknetCore_) {
        starknetCore = IStarknetCore(starknetCore_);
    }

    // The following function is a placeholder for a true function that registers
    // entities into the L2 contract. It is written for testing purposes.
    // Proper identity verification must be performed,
    // and most likely the function **should not be marked as public**.
    function PLACEHOLDER_register_entity_into_L2(
        uint256 entity_name,
        uint256 entity_data1,
        uint256 entity_data2
    ) public {
        // Get the starknet version of the Keccak256 hash of the entity name
        uint256 starknet_keccak_of_name = get_starknet_keccak_of_a_uint256(
            entity_name
        );
        
        // Prepare the payload to be sent to the L2
        uint256[] memory payload = new uint256()[4];
        payload[0] = starknet_keccak_of_name;
        payload[1] = entity_name;
        payload[2] = entity_data1;
        payload[3] = entity_data2;

        // Send the message to the StarkNet core contract.
        starknetCore.sendMessageToL2(
            l2ContractAddress,
            register_l2_function_selector,
            payload
        );
    }

    function get_starknet_keccak_of_a_uint256(uint256 number)
        public
        view
        returns (uint256)
    {
        // We need to compute the keccak hash of the number, and then return the
        // first 250 bits of the resulting hash (as a uint256 type)
        bytes32 hash_of_number = keccak256(abi.encode(number));
        uint256 reduced_hash = hash_of_number; // TODO: complete this
        return reduced_hash;
    }
}
