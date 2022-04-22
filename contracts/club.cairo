%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import storage_read, storage_write
from starkware.cairo.common.math import sign

const TRUE = 1
const FALSE = 0

struct UserInfo:
    member name : felt
    member balance : felt
end

################################
#  Storage variables
################################

@storage_var
func num_users_storage() -> (num : felt):
end

@storage_var
func user_index_to_user_memory_key_storage(index : felt) -> (slot : felt):
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
func user_index_to_user_memory_key{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(index : felt) -> (slot : felt):
    let (slot) = user_index_to_user_memory_key_storage.read(index)
    return (slot)
end

@view
func user_memory_key_to_user_info{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(memory_key : felt) -> (user_info : UserInfo):
    let user_info_array = cast([memory_key], UserInfo*)
    let user_info = [user_info_array]
    return (user_info)
end

@view
func is_user_registered{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_name : felt
) -> (bool : felt):
    alloc_locals
    let (user_memory_key) = get_user_memory_key(user_name)
    let (user_name) = storage_read(user_memory_key)
    let (user_balance) = storage_read(user_memory_key + 1)

    # make separate function for these checks
    let (is_positive) = sign(user_balance - 100)
    if is_positive == 1:
        return (TRUE)
    else:
        return (FALSE)
    end
end

################################
#  External functions
################################

@external
func register_user{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_info : UserInfo
):
    let user_name = user_info.name
    let (user_dictionary_key : felt) = get_user_memory_key(user_name)
    storage_write(user_dictionary_key, user_name)
    storage_write(user_dictionary_key + 1, user_info.balance)
    let (current_num_users) = num_users()
    num_users_storage.write(current_num_users + 1)
    return ()
end

################################
#  Internal functions
################################

@view
func get_user_memory_key{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_name : felt
) -> (key : felt):
    # TODO: Here we could put the hash of the name
    return (user_name)
end

################################
#  Constructor
################################

# NOTE: This is used for testing purposes only and it is not relevant
# to the exploit
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let dummy_user_info = UserInfo(name=100, balance=999)
    register_user(dummy_user_info)
    return ()
end

################################
#  Off-topic business logic
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
    let (key) = user_index_to_user_memory_key(user_index)
    let (user_info) = user_memory_key_to_user_info(key)
    let user_balance = user_info.balance
    assert user_info.balance = user_balance + 1
    return ()
end

@external
func reward_all_members{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let initial_user_index = 0
    recurrently_reward_users(user_index=initial_user_index)
    return ()
end
