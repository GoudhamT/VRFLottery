//SPDX-License-Identifier:MIT

pragma solidity 0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployScript} from "script/DeployScript.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;
    address PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    function setUp() external {
        DeployScript deployer = new DeployScript();
        (raffle, helperConfig) = deployer.deployContract();
    }

    function testCheckInitializedRaffleStateIsOpen() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testCheckRaffleStateUint() public view {
        assert(uint256(raffle.getRaffleState()) == 0);
    }
}
