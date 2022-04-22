# cairo_underhanded_solution


## Descriptiion of the contract `club.cairo`

This contract manages a network of entities. Periodically, some data is updated for all entities (e.g. the entities could be banks and the data could be monthly earnings). The members of this network have certain privileges and thus it is not easy to be a part of the network.

The contract written in this repository makes the minimum possible of assumptions on the specific operating logic of this network. The assumptions are kept to a minimum to guarantee the existence of an exploit.

Below we describe some of the functionality we require the contract to have.
### Structs
    - `EntitiyInfo`: stores the `name` of the entity and some `data` about it.
**NOTE**: An entity cannot have the name `0`.

### External function
    - `update_data_for_all_entities`: Updates the data of all entities. What the data is and how it is updated is irrelevant for us. What is important is that the contract has to update all data of all entities (i.e. the contract has to "iterate" over all entities).

### View function
    - `is_entity_registered`: Takes the name of an entity and returns 1 or 0 depending if such entity is a member of the network or not. 
    - `get_entity_info`: Takes the name of an entity, checks whether it is registered or not, and if yes then returns the struct `EntityInfo` corresponding to the entity.

## Implementation 
We begin with the following observations:
- The presence of the function `update_data_for_all_entities` requires the contract to have a method for "iterating" through all entities.  This means that we need to  cannot simply store user information in a dictionary-like fashion (as seems to be the defualt approach in starknet contract writing). 
- On the other hand, the view functions `is_entity_registered` and `get_entity_info` requires to access entity information in a dictionary-like fashion (unless we want to be very inefficient and we "iterate" through all entities).

The approach taken by the developer implementing the contract is the following:
- Each entity has a memory cell assigned, which is `sn_keccak256(entity_name)`, where `sn_keccak256` is StarkNet's version of the Keccak256 hash function.
- For each `entity_name`, the corresponding struct `EntityInfo` is stored starting at the memory cell assigned to the entity (used all needed subsequent memory cells).
- There's a storage variable called `num_users_storage` which stores the total number of members.
- There's a storage variable called `user_index_to_user_memory_key` wich is used to map integers from [0, ..., num_users-1] to a user memory cell. **NOTE:** we are assuming that the index associated to a user is not necessarily immutable (if it were, the contract design could be simplified).

The first two bullets allow the contract to access user information in a dictionary-like fashion: Given a user name, we obtain its `UserInfo` by reading the cell `sn_keccak256(user_name)`. The other two bullets allow the contract to use recursion in order to "iterate" over all users.

