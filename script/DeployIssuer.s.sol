// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import { Issuer } from '../src/Issuer.sol';

contract DeployIssuer is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey); // Start broadcasting transactions

    address realEstateToken = 0xaF5b99607B33319694Da56Df6B6DE6C125359f22;
    address functionsRouterAddress = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;

    //deploy the contract
    Issuer issuerInstance = new Issuer(realEstateToken, functionsRouterAddress);
    console.log('Contract deployed to:', address(issuerInstance));

    vm.stopBroadcast(); // End broadcasting transactions
  }
}

//source .env  to load environment variables
//forge script script/DeployIssuer.s.sol:DeployIssuer --rpc-url $sepolia --broadcast --verify -vvvv
//address: 0xa41E46d9fAdC55c47ce08F94661ee6669fC8D138
