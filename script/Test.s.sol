// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import 'forge-std/Script.sol';

interface IRealEstateToken {
  function setIssuer(address _issuer) external;
}

interface IIssuer {
  function issue(address to, uint256 amount, uint64 subscriptionId, uint32 gasLimit, bytes32 donID) external;
}

contract SetupRWAContracts is Script {
  function run() external {
    //params to issue an NFT
    address realEstateTokenAddress = 0xaF5b99607B33319694Da56Df6B6DE6C125359f22;
    address issuerAddress = 0xa41E46d9fAdC55c47ce08F94661ee6669fC8D138;
    address nftReceiver = 0x46F98920C5896Eff11BB90d784D6D6001d74c073;
    uint256 amountNFT = 10;
    uint32 gasLimit = 300000;
    uint64 subscriptionId = 3937;
    bytes32 donID = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

    uint256 privateKey = vm.envUint('PRIVATE_KEY');

    vm.startBroadcast(privateKey);

    IRealEstateToken realEstateToken = IRealEstateToken(realEstateTokenAddress);
    IIssuer issuer = IIssuer(issuerAddress);

    //set the issuer address
    //realEstateToken.setIssuer(issuerAddress);

    //issue an NFT
    issuer.issue(nftReceiver, amountNFT, subscriptionId, gasLimit, donID);

    vm.stopBroadcast();
  }
}

//forge script script/Test.s.sol:SetupRWAContracts --rpc-url $sepolia --broadcast -vvvv
