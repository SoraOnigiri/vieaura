# Vieaura challenge 
Vieauras can be passive stores of money but can also actively manage funds. 
In this challenge, the goal is to implement a profit making Vieaura by 
depositing the Vieaura's funds into the [Curve 3pool](https://curve.fi/3pool). 

## Task 
Implement a single-asset DAI Vieaura that earns profit through depositing 
the funds into the Curve 3pool. 
The Vieaura is also an ERC20 token itself (for accounting purposes, to keep 
track of the funds of individual depositors). We call this type of ERC20 
token an LP token. 
The Vieaura should implement the following functions: 
Q1. `deposit(uint256 underlyingAmount)` - allows a user to deposit 
`underlyingAmount` DAI and receive LP tokens in return 
Q2. The user needs to have approved the Vieaura to spend at least 
`underlyingAmount` DAI on his behalf 
Q3. `withdraw(uint256 lpAmount)` - allows a user to withdraw `lpAmount` 
LP tokens and receive underlying tokens in return 
Q4. `harvest()` - claims the accumulated CRV rewards from Curve and 
converts them to DAI 
Q5. `exchangeRate()` - returns the exchange rate between the underlying 
token (DAI) and the LP token 

## Requirements and Criteria 
- Preferred programming language: Solidity 
- Preferred framework: Truffle (https://www.trufflesuite.com) 
- Accepted programming language: Solidity, Vyper 
- Accepted frameworks: Brownie, Hardhat, Truffle 
To convert the CRV into DAI, you are free to use any on-chain exchange. 
Your solution will be judged based on the following criteria: 
- Quality of the code 
- Readability of the code 
- Security of the code 
- The code does not need to be bulletproof but potential vulnerabilities 
or issues, if any, should be briefly documented 
- Tests 

## By no means is this code complete. Use at your own risk. 