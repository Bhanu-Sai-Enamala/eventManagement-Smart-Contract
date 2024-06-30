pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "../src/Event.sol";

contract EventScript is Script {
    function setUp() public {}

    function run() public {
        
        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey = vm.deriveKey(seedPhrase, 0);
        vm.startBroadcast(privateKey);
        

        EventFactory CampaignCreator = new EventFactory();
        console.log("Contract Deployed at:", address(CampaignCreator));  // Debug output to check deployed contract address
        
        vm.stopBroadcast();
    }
}
