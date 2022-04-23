%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import storage_read, storage_write
from starkware.cairo.common.math import sign
from starkware.cairo.common.keccak import unsafe_keccak

const TRUE = 1
const FALSE = 0

struct EntityInfo:
    # The actual contents of this struct are irrelevant to us
    member name : felt
    member data1 : felt
    member data2 : felt
    # ...
end

################################
#  Storage variables
################################

@storage_var
func num_entities_storage() -> (num : felt):
end

@storage_var
func entity_index_to_entity_memory_cell_storage(index : felt) -> (cell : felt):
end

################################
#  View functions
################################

@view
func num_entities{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    num : felt
):
    let (num) = num_entities_storage.read()
    return (num)
end

@view
func entity_index_to_entity_memory_cell{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(index : felt) -> (slot : felt):
    let (slot) = entity_index_to_entity_memory_cell_storage.read(index)
    return (slot)
end

@view
func entity_memory_cell_to_entity_info{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(memory_cell : felt) -> (entity_info : EntityInfo):
    let entity_info_array = cast([memory_cell], EntityInfo*)
    let entity_info = [entity_info_array]
    return (entity_info)
end

@view
func is_entity_registered{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    hashed_entity_identifier : felt
) -> (bool : felt):
    alloc_locals
    # The entity's information is stored in `sn_keccak("entity_identifier")`, which is the argument
    # passed tot he function
    let entity_memory_cell = hashed_entity_identifier
    let (entity_name) = storage_read(entity_memory_cell)
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

@view
func get_entity_memory_cell{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    entity_name : felt
) -> (key : felt):
    let entity_name_as_array = cast(entity_name, felt*)
    let (memory_cell_high, memory_cell_low) = unsafe_keccak(data=entity_name_as_array, length=1)
    return ()
end

################################
#  Business logic
################################

@external
func PLACEHOLDER_register_entity{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    entity_info : EntityInfo, hashed_entity_identifier : felt
):
    # IMPORTANT NOTE: This function is a PLACEHOLDER for a function that registers entities into the system.
    # An actual implementation of such a function **MUST NOT BE MARKED EXTERNAL**, and it must perform all
    # necessary security checks before registering an identity (which will depend on the specific
    # context in which the contract is written)
    # We have written it because we need to have some entities registered into the system for our exploit to work.

    let entity_name = entity_info.name
    # let (entity_memory_cell : felt) = get_entity_memory_cell(entity_name)
    let entity_memory_cell = hashed_entity_identifier
    storage_write(entity_memory_cell, entity_name)
    storage_write(entity_memory_cell + 1, entity_info.data1)
    storage_write(entity_memory_cell + 2, entity_info.data2)
    # ...

    # Increase the number of entities by 1
    let (current_num_entities) = num_entities()
    num_entities_storage.write(current_num_entities + 1)
    return ()
end

@external
func update_data_for_all_entities{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    # Using the mapping index -> memory_cell provided by the variable `entity_index_to_entity_memory_cell` and the variable
    # `num_entity` we visit all entities using a standard recurrence construction.
    # NOTE: The functions below simply implement this construction and are not relevant to the exploit.
    let initial_entity_index = 0
    recurrently_update_data(entity_index=initial_entity_index)
    return ()
end

func recurrently_update_data{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    entity_index
):
    let (total_number_of_users) = num_entities()
    if entity_index + 1 == total_number_of_users:
        # We have visited all entities
        return ()
    else:
        update_data(entity_index=entity_index)
        return recurrently_update_data(entity_index=entity_index - 1)
    end
end

func update_data{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    entity_index : felt
):
    # Retrieve the EntityInfo corresponding to the `identity_index`
    let (key) = entity_index_to_entity_memory_cell(entity_index)
    let (entity_info) = entity_memory_cell_to_entity_info(key)
    dummy_update_data(entity_info)
    return ()
end

func dummy_update_data{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    entity_info : EntityInfo
):
    # Here we would update the data in `entity_info` as necessary.
    # This is not important for us and we leave it blank
    return ()
end
