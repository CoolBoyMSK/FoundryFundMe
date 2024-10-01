// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import{Script} from "forge-std/Script.sol";

contract HelperConfig is Script{
    NetworkConfig public activeNetworkConfig;
    MockV3Aggregator mockPriceFeed;
    struct NetworkConfig{
        address PriceFeed;   
    }
    constructor(){
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaConfig();
        } else{
            activeNetworkConfig = getorCreateAnvilEthConfig();
        }
    }
    // FundMe fundMe;
    function getSepoliaConfig() public pure returns(NetworkConfig memory){
    //     NetworkConfig memory sepoliaconfig = NetworkConfig({
    //         PriceFeed: 0x694AA1769357215DE4FAC081bf1f309adc325306
    //     });

    //     return sepoliaconfig;
    }
    function getorCreateAnvilEthConfig() public returns (NetworkConfig memory){
            if (activeNetworkConfig.PriceFeed != address(0)) {
                return activeNetworkConfig;
            }

        vm.startBroadcast();
        mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            PriceFeed: address(mockPriceFeed)
        });

        return anvilConfig;

    }
}