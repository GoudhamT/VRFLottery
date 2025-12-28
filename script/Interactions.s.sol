//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstants} from "script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script, CodeConstants {
    event subscriptionIsCreated(uint256 indexed subID);

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
        uint256 subId;
        console.log("VRF Coordinator is ", _vrfCoordinator);
        console.log("used on chain is ", block.chainid);
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            subId = VRFCoordinatorV2_5Mock(_vrfCoordinator).createSubscription();
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            subId = VRFCoordinatorV2Interface(_vrfCoordinator)
                .createSubscription();
            vm.stopBroadcast();
            console.log("created subscription ID is ", subId);
        }
        emit subscriptionIsCreated(subId);
        return (subId, _vrfCoordinator);
    }
}

contract FundSubscription is Script, CodeConstants {
    uint256 public constant FUND_AMOUNT = 3 ether; // 3 link

    function run() public {
        fundSubscriptionUsingConfig();
    }

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address link = helperConfig.getConfig().link;
        fundSubscription(vrfCoordinator, subscriptionId, link);
    }

    function fundSubscription(
        address _vrfCoordinator,
        uint256 _subId,
        address _linkToken
    ) public {
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(_vrfCoordinator).fundSubscription(
                _subId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(_linkToken).transferAndCall(
                _vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(_subId)
            );
            vm.stopBroadcast();
        }
    }
}

contract AddConsumer is Script {
    function run() public {
        address raffleContract = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerFromConfig(raffleContract);
    }

    function addConsumerFromConfig(address _mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subId = helperConfig.getConfig().subscriptionId;
        addConsumer(_mostRecentlyDeployed, vrfCoordinator, subId);
    }

    function addConsumer(
        address _mostRecentlyDeployed,
        address _vrfCoordinator,
        uint256 _subId
    ) public {
        console.log("Contract generated is ", _mostRecentlyDeployed);
        console.log("for VRF Coordinator", _vrfCoordinator);
        console.log("subscirption ID is ", _subId);
        console.log("on chain", block.chainid);
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(_vrfCoordinator).addConsumer(
            _subId,
            _mostRecentlyDeployed
        );
        vm.stopBroadcast();
    }
}
