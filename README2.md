# Submission to the Underhanded Cairo contest

## Description

This is a "proof-of-concept" project that manages a network of *entities* in the following way:

- All the funds of the entities live in Ethereum's layer 1.
- All heavy computations or operations around the management of the entities are done in StarkNet's layer 2, and the result of these computations is sent to the L1 contract, which updates or manages the funds accordingly.
- Being part of this network grants privileges.

## Design choices

The project makes the following design choices:

- Entities have a name, and they are identified in the L1 contract by the keccak256 hash of such a name. In the L2 contract they are identified by the first 250 bits of this hash (this is the standard version the keccak function used within StarkNet).

*Justification:* this would make sense (as opposed to, for example, using a wallet address for each entity) if entities are "wallet-less": for example, entities could be non-tech-****savvy local stores; or they could be more "ethereal" objects such as databases; or even huge communities such as entire countries.

- In the L2, the entity identifier (i.e. the hash of the entity's name) is used as the memory location where the entity information is stored (together with all extra subsequent memory cells required).

***remove this just?*  *Justification:* Depending on the functionality implemented, this can be more efficient (and also more consistent with the L1 contract) than using, for example, storage variables or the `dict` methods from the standard library. This is because the name hashes are already used and provided by the L1 contract. 

- An entity can be registered or not in the L2 contract. The only way an entity can become registered in the L2 contract is via a message sent from the L1 contract (see the function `register_entity` in the contract `contract.cairo`).

Here I present a minimal StarkNet contract that follows these guidelines and that contains a bug/exploit. Most functionality is left unimplemented since it is not relevant to the bug.

## Assumptions and notes

- It is assumed that the L1 contract and the L1-L2 communication between the L1 and L2 contracts is completely secure. For this reason I do not provide any L1 contract implementation (I just assume that the L1 part works as expected).
- In this work entity names are integers (e.g the ascii encoding of a string) different than `0`.

