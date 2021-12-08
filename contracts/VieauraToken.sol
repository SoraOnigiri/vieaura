// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VieauraToken is ERC20 {
    constructor() public ERC20("Vieaura Token", "VARA") {
        _mint(msg.sender, 1000000000000000000000000);
    }
}
