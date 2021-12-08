from brownie import VieauraPool, VieauraToken, Stake
from scripts.helper.utils import get_account, get_contract
def deploy_token_and_pool():
    account = getAccount()
    token = VieauraToken.deploy({"from": account})
    pool = VieauraPool.deploy(token.address, {"from": account})
    tx = token.transfer(pool.address, token.totalSupply(), {"from": account})
    tx.wait(1)
    dai_token = get_contract("dai_token")
    add_token(pool, dai_token, account)
    return pool, token

def add_token(token_pool, dai_token, account):
    add_tx = token_pool.addAllowedTokens(dai_token.address, {"from": account})
    add_tx.wait(1)
    set_tx = token_pool.setPriceFeedContract(dai_token.address, dai_token), {"from": account})
    set_tx.wait(1)
    return token_pool

def main():
    deploy_token_and_pool()
    pool = Contract('3pool')
    s = Stake.deploy(Contract('address_provider'), {"from": accounts[0]})
    