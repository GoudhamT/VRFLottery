//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

abstract contract CodeConstants {
    /*MOCK constants*/
    uint96 public constant MOCK_BASE_FEE = 10 ether; //0.02 ether;
    uint96 public constant MOCK_GAS_PRICE = 1e18;
    int256 public constant MOCK_WEI_PER_LINK = 4e15;

    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
    uint256 public constant ETH_MAINNET = 1;
}

contract HelperConfig is Script, CodeConstants {
    error Raffle_HelperConfig__InvalidChainID(uint256 id);
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 gasLimit;
        address link;
    }

    NetworkConfig public localNetworkConfig;

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(
        uint256 _chainID
    ) public returns (NetworkConfig memory) {
        if (_chainID == SEPOLIA_CHAIN_ID) {
            return getSepoliaConfig();
        } else if (_chainID == ETH_MAINNET) {
            return getEthMainnetConfig();
        } else if (_chainID == LOCAL_CHAIN_ID) {
            if (localNetworkConfig.vrfCoordinator == address(0)) {
                return getorCreateAnvilconfig();
            }
            return localNetworkConfig;
        } else {
            revert Raffle_HelperConfig__InvalidChainID(_chainID);
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether, //10000000000000000,
                interval: 30, //30 seconds
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 15128166972103155481899904279290870035163628868134405121389517347304582586668,
                gasLimit: 150000,
                link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
            });
    }

    function getEthMainnetConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether, //10000000000000000,
                interval: 30, //30 seconds
                vrfCoordinator: 0xD7f86b4b8Cae7D942340FF628F82735b7a20893a,
                gasLane: 0x3fd2fec10d06ee8f65e7f2e95f5c56511359ece3f33960ad8a866ae24a8ff10b,
                subscriptionId: 0,
                gasLimit: 150000,
                link: 0x514910771AF9Ca656af840dff83E8264EcF986CA
            });
    }

    function getorCreateAnvilconfig() public returns (NetworkConfig memory) {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE,
            MOCK_WEI_PER_LINK
        );
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();
        localNetworkConfig = NetworkConfig({
            entranceFee: 0.01 ether, //10000000000000000,
            interval: 30, //30 seconds
            vrfCoordinator: address(vrfCoordinatorMock),
            //doesn't matter
            gasLane: 0x3fd2fec10d06ee8f65e7f2e95f5c56511359ece3f33960ad8a866ae24a8ff10b,
            subscriptionId: 0,
            gasLimit: 150000,
            link: address(linkToken)
        });
        return localNetworkConfig;
    }
}
