%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import storage_read, storage_write
from starkware.cairo.common.math import sign
from starkware.cairo.common.keccak import unsafe_keccak

struct EntityInfo:
    member name : felt
    # The data fields below are irrelevant for us
    member data1 : felt
    member data2 : felt
end

@storage_var
func total_number_of_registered_entities() -> (res : felt):
end

@storage_var
func foo() -> (res : felt):
end

# .... add as many variables as needed

@l1_handler
func register_entity{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    from_address : felt, hash_of_entity_name : felt, entity_name : felt, data1 : felt, data2 : felt
):
    # - This function receives a message from an L1 contract ordering to register an entity into the L2 contract.
    # - It provides the `sn_keccak256` value of the entity name (as the argument `hash_of_entity_name`), plus all other arguments that form the struct EntityInfo.
    # - We assume that the L1 contract is secure and that all messages received here are trustworthy.
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
    alloc_locals
    let (local entity_name) = storage_read(hash_of_entity_name)
    let (is_entity_name_more_than_zero) = sign(entity_name - 1)
    if is_entity_name_more_than_zero == 1:
        # Entity is registered
        return (1)
    else:
        # In this case entity_name = 0 and so the entity is not registered
        # because 0 is agreed to not be a valid name for an entity
        return (0)
    end
end
