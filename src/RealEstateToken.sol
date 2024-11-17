// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { CrossChainBurnAndMintERC1155 } from './CrossChainBurnAndMintERC1155.sol';
import { RealEstatePriceDetails } from './RealEstatePriceDetails.sol';

//our actual RWA => a cross chain NFT (mint & burn) + connection to off-chain oracles to get price data
contract RealEstateToken is CrossChainBurnAndMintERC1155, RealEstatePriceDetails {
  constructor(
    string memory uri_,
    address ccipRouterAddress,
    address linkTokenAddress,
    uint64 currentChainSelector,
    address functionsRouterAddress
  )
    CrossChainBurnAndMintERC1155(uri_, ccipRouterAddress, linkTokenAddress, currentChainSelector)
    RealEstatePriceDetails(functionsRouterAddress)
  {}
}
