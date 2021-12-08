from brownie import accounts, network, config

LOCAL_BLOCKCHAIN_ENVIRONMENTS = NON_FORKED_LOCAL_BLOCKCHAIN_ENVIRONMENTS + [
    "mainnet-fork",
    "binance-fork",
    "matic-fork",
]

def get_account(index=None, id=None):
    if index:
        return accounts[index]
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        return accounts[0]
    if id:
        return accounts.load(id)
    return accounts.add(config["wallets"]["from_key"])

def get_contract(contract_name):
    try:
        contract_address = config["networks"][network.show_active()][contract_name]
        contract = Contract.from_abi(
            contract_type._name, contract_address, contract_type.abi
        )
    except KeyError:
        print(
            f"{network.show_active()} address not found, perhaps you should add it to the config or deploy mocks?"
        )
        print(
            f"brownie run scripts/deploy_mocks.py --network {network.show_active()}"
        )
    return contract    

