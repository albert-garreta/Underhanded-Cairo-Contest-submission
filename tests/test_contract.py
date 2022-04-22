"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.compiler.compile import get_selector_from_name


# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "contract.cairo")


# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_increase_balance():
    """Test increase_balance method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    execution_info = await contract.is_user_registered(100).call()
    assert execution_info.result[0] == 1
    
    # TODO: Note this asserts to true!
    execution_info = await contract.is_user_registered(101).call()
    assert execution_info.result[0] == 1
    
    execution_info = await contract.is_user_registered(102).call()
    assert execution_info.result[0] == 0
    
    attack_address = get_selector_from_name("num_users_storage")
    execution_info = await contract.is_user_registered(attack_address).call()
    print("HERE", execution_info)
    assert execution_info.result[0] == 1

    attack_address = get_selector_from_name("num_users_storage")
    execution_info = await contract.is_user_registered(attack_address+1).call()
    print("HERE", execution_info)
    assert execution_info.result[0] == 0