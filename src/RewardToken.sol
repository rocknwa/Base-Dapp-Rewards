// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable{
    constructor() ERC20("RewardToken", "RWD") {}

    // Mint function to create new tokens
    function mint(address to, uint256 amount) external onlyOwner{
        _mint(to, amount);
    }
}
