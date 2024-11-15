// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import { Issuer } from '../src/Issuer.sol'; 

contract DeployIssuer is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY'); 
    vm.startBroadcast(deployerPrivateKey); // Start broadcasting transactions

    /:deploy the contract
    Issuer issuerInstance = new Issuer();
    console.log('Contract deployed to:', address(issuerInstance));

    vm.stopBroadcast(); // End broadcasting transactions
  }
}

//source .env  to load environment variables
//forge script script/DeployIssuer.s.sol:DeployIssuer --rpc-url $sepolia --broadcast --verify -vvvv
