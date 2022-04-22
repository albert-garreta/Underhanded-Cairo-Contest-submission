# cairo_underhanded_solution


## Descriptiion of the contract `club.cairo`

This contract manages a club. The members of such club get a periodic remuneration. Other privileges are also granted to the memebrs (the exact form of the privileges is unimportant for us).

Moreover, we assume that the members of the club are busy people who don't wish to bother getting into the nuts and bolts of web3. Hence the contract ...

### Structs
    - `UserInfo`: stores the name and the balances of the user

### External functions
    - `reward_all_members`: Increases the balances of all users by a certain (irrelevant to us) amount.
    - `is_user_registered`: Takes a user name and returns 1 or 0 depending if such user is a member of the club. 

### Implementation 
The presence of the function `reward_all_members` requires the contract to have a method for "iterating" through all memebers in order to reward each one of them. This means that we cannot simply store user information in a dictionary-like fashion (as seems to be the defualt approach in starknet contract writing) since then we have no way to iterate through all users. On the other hand, the function `is_user_registered` requires us to access member information in a dictionary-like fashion (unless we want to somehow inefficiently iterate over all users).

The approach taken is the following:
    - Each user has a memory cell assigned, which is `sn_keccak256(user_name)`, where `sn_keccak256` is ...
    - For each `user_name`, the corresponding struct `UserInfo` is stored at the corresponding memory cell (plus all needed subsequent memory cells).
    - There's a storage variable called `num_users_storage` which stores the total number of members.
    - There's a storage variable called `user_index_to_user_dictionary_key` wich is used to map integers from [0, ..., num_users-1] to a user memory cell.
The first two bullets allow us to access user information in a dictionary-like fashion: Given a user name, we obtain its `UserInfo` in the cell `sn_keccak256(user_name)`. The other two bullets allow us to use recursion in order to "iterate" over all users.