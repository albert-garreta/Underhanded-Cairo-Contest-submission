%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import storage_read, storage_write
from starkware.cairo.common.math import sign
from starkware.cairo.common.keccak import unsafe_keccak

struct EntityInfo:
    # This struct stores the information concerning an entity
    member name : felt
    # The data fields below are irrelevant for us
    member data1 : felt
    member data2 : felt
end

# This variable counts the total number of entities registered in the L2 contract
@storage_var
func total_number_of_registered_entities() -> (res : felt):
end

# Getter of the previous variable
@view
func get_total_number_of_registered_entities{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}() -> (res : felt):
    let (num_entities) = total_number_of_registered_entities.read()
    return (num_entities)
end

# Declare variables as needed
@storage_var
func foo() -> (res : felt):
end

@l1_handler
func register_entity{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    from_address : felt, hash_of_entity_name : felt, entity_name : felt, data1 : felt, data2 : felt
):
    # This function receives a message from the L1 contract ordering to register an entity into the L2 contract.
    # The L1 contract sends the `sn_keccak256` hash of the entity name (as the argument `hash_of_entity_name`),
    # plus all other data that forms the struct EntityInfo.
    # The L2 contract stores the entity's data starting at the memory cell given by the hash of the entity's name.
    # We assume that the L1 contract is secure and that all messages received here are trustworthy.
    storage_write(hash_of_entity_name, entity_name)
    storage_write(hash_of_entity_name + 1, data1)
    storage_write(hash_of_entity_name + 2, data2)

    increase_num_of_registered_entities_by_one()

    return ()
end

func increase_num_of_registered_entities_by_one{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    let (current_num_of_registered_entities) = total_number_of_registered_entities.read()
    total_number_of_registered_entities.write(current_num_of_registered_entities + 1)
    return ()
end

@view
func is_entity_registered{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    hash_of_entity_name : felt
) -> (bool : felt):
    # This function is given the hash of an entity's name and it checks if the entity is registered in the contract.
    # To do this, it looks at where the entity's EntityInfo struct would be located
    # if the entity was registered, and it checks whether the value stored there (which is the entity's name in case
    # it is registered) is 0 or not.
    alloc_locals
    let (local entity_name) = storage_read(hash_of_entity_name)
    let (sign_) = sign(entity_name - 1)
    if sign_ == -1:
        # In this case entity_name = 0 and so the entity is not registered
        # because 0 is agreed to not be a valid name for an entity
        return (0)
    else:
        return (1)
    end
end

@external
func DUMMY_register_entity{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    hash_of_entity_name : felt, entity_name : felt, data1 : felt, data2 : felt
):
    # IMPORTANT:
    # - This function is here only for testing purposes.
    # - By design, the only true way an entity can be registered in the L2 is through the function `register_entity`
    # - To minimize the complexity of the repository I have added this function which allows
    # to register entities without the need of writing an L1 contract

    storage_write(hash_of_entity_name, entity_name)
    storage_write(hash_of_entity_name + 1, data1)
    storage_write(hash_of_entity_name + 2, data2)

    increase_num_of_registered_entities_by_one()
    return ()
end
