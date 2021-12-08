# @version ^0.2.16
"""
@title Quick Curve Staker
@author Curve.Fi
@license Copyright (c) Curve.Fi, 2021 - all rights reserved
"""


from vyper.interfaces import ERC20

interface Curve3Pool:
   def add_liquidity(amounts: uint256[3], min_mint_amount: uint256): nonpayable
   def remove_liquidity(_amount: uint256, min_amounts: uint256[3]): nonpayable
   
interface Gauge:
   def deposit(_value: uint256): nonpayable
   def withdraw(_value: uint256): nonpayable
   def balanceOf(arg0: address) -> uint256: view
   
interface Registry:
   def get_n_coins(_pool: address) -> uint256[2]: view
   def get_coins(_pool: address) -> address[8]: view
   def get_gauges(_pool: address) -> (address[10], int128[10]): view
   def is_meta(_pool: address) -> bool: view
   def get_pool_from_lp_token(arg0: address) -> address: view
   def get_lp_token(arg0: address) -> address: view
   
interface AddressProvider:
   def get_registry() -> address : nonpayable


address_provider: public(AddressProvider)
registry: public(Registry)

# INTERNAL FUNCTIONS


@internal
def _get_coin_index(coin_addr: address, pool_addr: address) -> int256[2]:
    """
    @notice Determine index for a coin in a pool
    @param coin_addr Address of ERC20 Token
    @param pool_addr Address of Curve Pool
    """
    coins: address[8] = self.registry.get_coins(pool_addr)
    ret_index: int256 = -1
    ret_number: int256 = -1

    for i in range(8):
        if coin_addr == coins[i]:
            ret_index = i
        if ret_number == -1 and coins[i] == ZERO_ADDRESS:
            ret_number = i

    return [ret_index, ret_number]


@internal
def _add_liquidity(coin_addr: address, pool_addr: address):
    """
    @notice Approve and Deposit an ERC20 coin into a Curve Pool
    @param coin_addr Address of ERC20 Token
    @param pool_addr Address of Curve Pool
    """
    coin_bal: uint256 = ERC20(coin_addr).balanceOf(self)
    assert coin_bal > 0, "No Balance"

    ERC20(coin_addr).approve(pool_addr, coin_bal)
    coin_index: int256[2] = self._get_coin_index(coin_addr, pool_addr)
    assert coin_index[0] >= 0, "Coin not found"

    if coin_index[1] == 3:
        liq_arr: uint256[3] = [0, 0, 0]
        liq_arr[coin_index[0]] = coin_bal
        Curve3Pool(pool_addr).add_liquidity(liq_arr, 0)

    else:
        assert False, "Pool not supported"


# CONSTRUCTOR


@external
def __init__(address_provider: address):
    """
    @notice Contract constructor
    @param address_provider Address of Curve Address Provider
    """
    self.address_provider = AddressProvider(address_provider)
    self.registry = Registry(self.address_provider.get_registry())

# EXTERNAL FUNCTIONS


@external
def deposit_liquidity(coin_addr: address, pool_addr: address):
    """
    @notice Ape into a Curve Pool, then stake in Rewards Gauge
    @param coin_addr Address of ERC20 used to ape in
    @param pool_addr Curve pool address to ape into
    """

    if self.registry.is_meta(pool_addr):
        metapool_lp: address = self.registry.get_coins(pool_addr)[1]
        metapool: address = self.registry.get_pool_from_lp_token(metapool_lp)
        self._add_liquidity(coin_addr, metapool)
        self._add_liquidity(metapool_lp, pool_addr)
    else:
        self._add_liquidity(coin_addr, pool_addr)

    lp_addr: address = self.registry.get_lp_token(pool_addr)
    lp_bal: uint256 = ERC20(lp_addr).balanceOf(self)
    assert lp_bal > 0, "Error Depositing"

    rewards_addr: address = self.registry.get_gauges(pool_addr)[0][0]
    ERC20(lp_addr).approve(rewards_addr, lp_bal)
    Gauge(rewards_addr).deposit(lp_bal)


@external
def withdraw_liquidity(pool_addr: address):
    """
    @notice Withdraw liquidity from Curve Rewards Gauge and Unstake
    @param pool_addr Pool Address to Drain
    """

    lp_addr: address = self.registry.get_lp_token(pool_addr)
    rewards_addr: address = self.registry.get_gauges(pool_addr)[0][0]

    Gauge(rewards_addr).withdraw(Gauge(rewards_addr).balanceOf(self))
    coins: uint256 = self.registry.get_n_coins(pool_addr)[1]
    if coins == 3:
        Curve3Pool(pool_addr).remove_liquidity(
            ERC20(lp_addr).balanceOf(self), [0, 0, 0]
        )


@external
def claim_erc20(coin_addr: address):
    """
    @notice Drain all ERC20 tokens to your address
    @param coin_addr Address of ERC20 Token
    """
    ERC20(coin_addr).transfer(msg.sender, ERC20(coin_addr).balanceOf(self))


@external
def set_registry():
    """
    @notice Update the registry pointer based on Curve Address Provider
    """

    self.registry = Registry(self.address_provider.get_registry())
