//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";

contract DeployScript is Script {
    function run() external {
        deployContract();
    }

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        if (config.subscriptionId == 0) {
            //create subscription
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, ) = createSubscription
                .getOrCreateSubscription(config.vrfCoordinator);
            //Fund Subscription
            FundSubscription funding = new FundSubscription();
            funding.fundSubscription(
                config.vrfCoordinator,
                config.subscriptionId,
                config.link
            );
        }
        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.gasLimit
        );
        vm.stopBroadcast();
        //Add consumer
        AddConsumer contractConsumer = new AddConsumer();
        contractConsumer.addConsumer(
            address(raffle),
            config.vrfCoordinator,
            config.subscriptionId
        );
        return (raffle, helperConfig);
    }
}
