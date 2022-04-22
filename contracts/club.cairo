%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import storage_read, storage_write
from starkware.cairo.common.math import sign

# This contract manages members of a club.
# In this club, all users are rewarded periodically (say every week). 
# Hence the contract needs a function that "iterates" over each member and pays each member.
# 
#
#
#
#
#
#
#
#
#
#
#




const TRUE = 1
const FALSE = 0

struct UserBalances:
    member balance1 : felt
    member balance2 : felt
end

################################
#  Storage variables
################################

@storage_var
func num_users_storage() -> (num : felt):
end

@storage_var
func user_index_to_user_dictionary_key_storage(index : felt) -> (slot : felt):
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
func user_index_to_user_dictionary_key{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(index : felt) -> (slot : felt):
    let (slot) = user_index_to_user_dictionary_key_storage.read(index)
    return (slot)
end

@view
func user_dictionary_key_to_user_balances{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}(memory_key : felt) -> (user_balances : UserBalances):
    let user_balances_array = cast([memory_key], UserBalances*)
    let user_balances = [user_balances_array]
    return (user_balances)
end

@view
func is_user_registered{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_alias : felt
) -> (bool : felt):
    let (user_memory_key) = get_user_dictionary_key(user_alias)
    let (user_balance1) = storage_read(user_memory_key)
    let (user_balance2) = storage_read(user_memory_key)
    
    # make separate function for these checks
    if sign(user_balance1-100) == 1:
        if sign(user_balance2-100)==1:
            return (TRUE)
        end
    end
    return (FALSE)

end

################################
#  External functions
################################

@external
func register_user{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_alias : felt, user_balances : UserBalances
):
    let (user_dictionary_key : felt) = get_user_dictionary_key(user_alias)
    storage_write(user_dictionary_key, user_balances.balance1)
    storage_write(user_dictionary_key + 1, user_balances.balance2)
    let (current_num_users) = num_users()
    num_users_storage.write(current_num_users + 1)
    return ()
end

################################
#  Internal functions
################################

@view
func get_user_dictionary_key{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_alias : felt
) -> (key : felt):
    # TODO: Here we could put the hash of the alias
    return (user_alias)
end

################################
#  Constructor
################################

# NOTE: This is used for testing purposes only and it is not relevant
# to the exploit
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let dummy_user_alias = 100
    let dummy_user_balances = UserBalances(balance1=400, balance2=999)
    register_user(dummy_user_alias, dummy_user_balances)
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
    let (key) = user_index_to_user_dictionary_key(user_index)
    let (user_balances) = user_dictionary_key_to_user_balances(key)
    let user_balance = user_balances.balance
    assert user_balances.balance = user_balance + 1
    return ()
end

@external
func reward_all_members{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let initial_user_index = 0
    recurrently_reward_users(user_index=initial_user_index)
    return ()
end
