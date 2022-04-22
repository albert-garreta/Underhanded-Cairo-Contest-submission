# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import sign
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import storage_read, storage_write

const TRUE = 1
const FALSE = 0

struct UserInfo:
    member alias : felt
    member balance : felt
end

################################
#  Storage variables
################################

@storage_var
func num_users_storage() -> (num : felt):
end

@storage_var
func index_to_user_memory_slot_storage(index : felt) -> (slot : felt):
end

@storage_var
func user_memory_slot_to_user_info_storage(memory_slot : felt) -> (user_info : UserInfo):
end

@storage_var
func is_user_registered_storage(user_alias : felt) -> (bool : felt):
end

################################
#  View functions
################################

@view
func num_users{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (num : felt):
    let (num) = num_users_storage.read()
    return (num)
end

@view
func index_to_user_memory_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    index : felt
) -> (slot : felt):
    let (slot) = index_to_user_memory_slot_storage.read(index)
    return (slot)
end

@view
func user_memory_slot_to_user_info{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(memory_slot : felt) -> (user_info : UserInfo):
    alloc_locals
    if [memory_slot] == 0:
        let null_user = UserInfo(alias=0, balance=0)
        return (null_user)
    end
    local user_info_array : UserInfo* = cast([memory_slot], UserInfo*)
    let user_info = [user_info_array]
    return (user_info)
end

@view
func is_user_registered{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_alias : felt
) -> (bool : felt):
    let (user_info_x) = storage_read(user_alias)
    if user_info_x == 0:
        return (FALSE)
    else:
        return (TRUE)
    end
end

################################
#  External functions
################################

@external
func reward_all_users{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let initial_user_index = 0
    recurrently_reward_users(user_index=initial_user_index)
    return ()
end

@external
func register_user{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_info : UserInfo
):
    let (current_num_users) = num_users()
    let user_memory_slot = user_info.alias
    storage_write(user_memory_slot, user_info.alias)
    storage_write(user_memory_slot + 1, user_info.balance)
    num_users_storage.write(current_num_users + 1)
    return ()
end

################################
#  Internal functions
################################

func recurrently_reward_users{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_index
):
    let (last_user_bool) = is_the_last_user(user_index)
    if last_user_bool == TRUE:
        return ()
    else:
        reward_user(user_index=user_index)
        # TODO: change naming since here we are iterating instead of rewarding one user
        recurrently_reward_users(user_index=user_index - 1)
        return ()
    end
end

func is_the_last_user{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_index : felt
) -> (bool : felt):
    # TODO: add some range checks? (other checks throughout the code?)
    let (total_number_of_users) = num_users()
    if user_index + 1 == total_number_of_users:
        return (TRUE)
    else:
        return (FALSE)
    end
end

func reward_user{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_index : felt
):
    let (memory_slot) = index_to_user_memory_slot(user_index)
    let (user_info) = user_memory_slot_to_user_info(memory_slot)
    let user_balance = user_info.balance
    assert user_info.balance = user_balance + 1
    return ()
end

################################
#  Constructor
################################

# NOTE: This is used for testing purposes only and it is not relevant
# to the exploit
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let dummy_user_info = UserInfo(alias=100, balance=999)
    # assert dummy_user_info.alias = 100
    # assert dummy_user_info.balance = 999
    register_user(dummy_user_info)
    return ()
end
