# Submission to the Underhanded Cairo contest

## Description

Here we imagine an abstract project that manages a network of entities in the following way:

- All the funds of the entities live in the L1.
- All heavy computations or operations around the management of the entities are done in StarkNet, and the result of these computations is sent to the L1 to update/manage funds accordingly.
- Being part of this network grants privileges.

## Design choices

We make the following design choices (we also provide some justification for these choices):

- Entities are identified in the L1 contract by the keccak256 hash of their name. In the L2 contract they are identified by the first 250 bits of the keccak256 hash (this is the standard version the keccak function used within StarkNet).

*Justification:* this would make sense (as opposed to, for example, using a wallet address for each entity) if entities are "wallet-less": for example, entities could be non-tech-****savvy local stores; or they could be more "ethereal" objects such as databases; or even huge communities such as entire countries.

- In the L2, the entity identifier (i.e. the hash of the entity's name) is used as the memory location where the entity information is stored (together with all extra subsequent memory cells required).

***remove this just?*  *Justification:* Dedpending on the functionality implemented, this can be more efficient than using, for example, storage variables or the `dict` methods from the standard library. This is because the name hashes are already used and provided by the L1. Moreover, this is consistent with how the L1 contract works.

- An entity can be registered or not in the L2 contract. An entity can become registered in the L2 contract only via a message sent from the L1 contract (see the function `register_entity` in the contract `contract.cairo`).

Here we present a minimal StarkNet contract that follows these guidelines and that contains a bug/exploit. Most functionality is left unimplemented since it is not relevant to the bug.

## Assumptions and notes

- We assume that the L1 contract and the L1-L2 communication between the L1 and L2 contracts is completely secure. For this reason we do not provide any L1 contract implementation (we just assume that the L1 part works as expected).
- In this work entity names are integers (perhaps the ascii encoding of a string) different than `0`.

