// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol"; // Import console for logging
import {RewardToken} from "../src/RewardToken.sol";
import {DappRewards} from "../src/DappRewards.sol"; // Assuming DappRewards is in src folder

contract DeployScript is Script {
    function run() public {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the RewardToken contract
        RewardToken rewardToken = new RewardToken();

        // Deploy the DappRewards contract with RewardToken's address as a constructor argument
        DappRewards dappRewards = new DappRewards(rewardToken);

        // Transfer ownership of RewardToken to the DappRewards contract
        rewardToken.transferOwnership(address(dappRewards));

        // Logging the contract addresses
        console.log("RewardToken deployed to:", address(rewardToken));
        console.log("DappRewards deployed to:", address(dappRewards));

        // End broadcasting transactions
        vm.stopBroadcast();
    }
}
