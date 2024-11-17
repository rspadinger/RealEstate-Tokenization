// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { RealEstateToken } from './RealEstateToken.sol';
import { OwnerIsCreator } from '@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol';
import { FunctionsClient } from '@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol';
import { FunctionsRequest } from '@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol';
import { FunctionsSource } from './FunctionsSource.sol';

//mint a mock version of real estate in a form of ERC-1155 tokens
contract Issuer is FunctionsClient, FunctionsSource, OwnerIsCreator {
  using FunctionsRequest for FunctionsRequest.Request;

  error LatestIssueInProgress();

  struct FractionalizedNft {
    address to;
    uint256 amount;
  }

  RealEstateToken internal immutable i_realEstateToken;

  bytes32 internal s_lastRequestId;
  uint256 private s_nextTokenId;

  mapping(bytes32 requestId => FractionalizedNft) internal s_issuesInProgress;

  constructor(address realEstateToken, address functionsRouterAddress) FunctionsClient(functionsRouterAddress) {
    i_realEstateToken = RealEstateToken(realEstateToken);
  }

  function issue(
    address to,
    uint256 amount,
    uint64 subscriptionId,
    uint32 gasLimit,
    bytes32 donID
  ) external onlyOwner returns (bytes32 requestId) {
    if (s_lastRequestId != bytes32(0)) revert LatestIssueInProgress();

    FunctionsRequest.Request memory req;

    //@note init FunctionsRequest with the getNftMetadata js function (in FunctionsSource.sol)
    req.initializeRequestForInlineJavaScript(this.getNftMetadata());
    //send request with required input data => function returns IPFS string: ipfs://${ipfsCid}
    requestId = _sendRequest(req.encodeCBOR(), subscriptionId, gasLimit, donID);

    s_issuesInProgress[requestId] = FractionalizedNft(to, amount);

    s_lastRequestId = requestId;
  }

  function cancelPendingRequest() external onlyOwner {
    s_lastRequestId = bytes32(0);
  }

  //@note callback function => called by CL Functions when the request is fianlized
  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    if (err.length != 0) {
      revert(string(err));
    }

    if (s_lastRequestId == requestId) {
      //get the IPFS string : ipfs://${ipfsCid}
      string memory tokenURI = string(response);

      uint256 tokenId = s_nextTokenId++;
      FractionalizedNft memory fractionalizedNft = s_issuesInProgress[requestId];

      //mint the NFT
      i_realEstateToken.mint(fractionalizedNft.to, tokenId, fractionalizedNft.amount, '', tokenURI);

      s_lastRequestId = bytes32(0);
    }
  }
}
