//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract CreateSubscription is Script {
    function run() public {
        createSubscriptionFromConfig();
    }

    function createSubscriptionFromConfig() public returns (uint256) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        (uint256 subId, ) = getOrCreateSubscription(vrfCoordinator);
        return (subId);
    }

    function getOrCreateSubscription(
        address _vrfCoordinator
    ) public returns (uint256, address) {
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(_vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        return (subId, _vrfCoordinator);
    }
}
