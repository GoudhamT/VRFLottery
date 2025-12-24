//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";

abstract contract CodeConstants {
    uint256 public constant SEPLOIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
    uint256 public constant ETH_MAINNET = 1;
}

contract HelperConfig is Script, CodeConstants {
    struct NetworkConfig {
        uint256 enterranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 gasLimit;
    }

    NetworkConfig public localNetworkConfig;

    function getConfig() public returns (NetworkConfig memory) {
        if (block.chainid == SEPLOIA_CHAIN_ID) {
            localNetworkConfig = getSepoliaConfig();
            return localNetworkConfig;
        } else if (block.chainid == ETH_MAINNET) {
            localNetworkConfig = getEthMainnetConfig();
            return localNetworkConfig;
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                enterranceFee: 0.01 ether, //10000000000000000,
                interval: 30, //30 seconds
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 0,
                gasLimit: 150000
            });
    }

    function getEthMainnetConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                enterranceFee: 0.01 ether, //10000000000000000,
                interval: 30, //30 seconds
                vrfCoordinator: 0xD7f86b4b8Cae7D942340FF628F82735b7a20893a,
                gasLane: 0x3fd2fec10d06ee8f65e7f2e95f5c56511359ece3f33960ad8a866ae24a8ff10b,
                subscriptionId: 0,
                gasLimit: 150000
            });
    }
}
