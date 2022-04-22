from starkware.starknet.compiler.compile import get_selector_from_name

def starknet_keccak(name:str):
    # Note this won't compute the keccak of `name` if `name="__default__" or `name="__l1_default__"``
    return get_selector_from_name(name)