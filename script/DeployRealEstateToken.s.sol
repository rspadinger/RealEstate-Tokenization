// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Script.sol';
import { RealEstateToken } from '../src/RealEstateToken.sol';

contract DeployRealEstateToken is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');

    string memory uri = '';
    address ccipRouterAddress = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    address linkTokenAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    uint64 currentChainSelector = 16015286601757825753;
    address functionsRouterAddress = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;

    vm.startBroadcast(deployerPrivateKey); // Start broadcasting transactions

    //deploy the contract
    RealEstateToken realEstateTokenInstance = new RealEstateToken(
      uri,
      ccipRouterAddress,
      linkTokenAddress,
      currentChainSelector,
      functionsRouterAddress
    );
    console.log('Contract deployed to:', address(realEstateTokenInstance));

    vm.stopBroadcast(); // End broadcasting transactions
  }
}

//source .env  to load environment variables
//forge script script/DeployRealEstateToken.s.sol:DeployRealEstateToken --rpc-url $sepolia --broadcast --verify -vvvv
//contract: 0xaF5b99607B33319694Da56Df6B6DE6C125359f22
