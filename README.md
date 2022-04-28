# Submission to the Underhanded Cairo contest

This is a "proof-of-concept" project with a hidden bug/exploit within it. It was submitted to the *Underhanded Cairo contest* (April 2022) and obtained an honorable mention (from a total of 1 winner and 2 honorable mentions).

The bug is described within the folder `exploit_description`. Outside of this folder there are as little hints as possible about what the exploit is, this way the repository can be trated as an exercise where the reader tries to find the hidden bug.

The context is the following: the project manages a network of *entities* (it is not important what these entities are exactly) with the following scheme:

- There are two contracts, one in Ethereum's layer 1 (L1) and one in StarkNet's layer 2 (L2). 
- All the funds of the entities live in the L1.
- The L2 contract performs all the heavy computations related to the management of the entities' funds and data. It sends the results of these computations to the L1 contract, and the L1 contract then acts accordingly.
- Being part of this network grants privileges and costs some fees.

Here I present a minimal StarkNet contract that follows these guidelines and that contains a bug/exploit. Most functionality is left unimplemented since it is not relevant to the bug. **NOTE** The bug is hidden within the L2 contract and it is not related to L1-L2 message communication (this L1-L2 messaging serves as context for the design of the contract).

## Design choices

The project makes the following design choices:

### Choice 1

Entities have a name, and they are identified in the L1 contract by the keccak256 hash of such a name (alternatively, they could be identified with the hash of a passphrase). In the L2 contract they are identified by the first 250 bits of this hash (this is the standard version the keccak function used within StarkNet).

*Justification:* this makes sense (as opposed to, for example, using a wallet address for each entity) if entities are "wallet-less": for example, entities could be non-tech-savvy local stores; or they could be more "ethereal" objects such as databases; or even huge communities such as entire countries.

### Choice 2

In the L2 contract, the entity identifier (i.e. the hash of the entity's name) is used as the memory location where the entity information is stored (together with all extra subsequent memory cells required).

*Justification:* Depending on the functionality implemented, this can be more efficient (and also more consistent with the L1 contract) than using, for example, a storage variable or the `dict` method from the standard library. This is because the name hashes are already used and provided by the L1 contract. 

### Choice 3

An entity can be registered or not in the L2 contract. The only way an entity can become registered in the L2 contract is via a message sent from the L1 contract (see the function `register_entity` in the contract `contract.cairo`).

## Assumptions and notes

- It is assumed that the L1 contract and the L1-L2 communication between the L1 and L2 contracts is completely secure. For this reason I do not provide any L1 contract implementation (I just assume that the L1 part works as expected).
- Entity names are identified with integers (e.g the ascii encoding of a string) different than `0`.

