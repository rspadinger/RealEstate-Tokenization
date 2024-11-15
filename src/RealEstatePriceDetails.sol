// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { OwnerIsCreator } from '@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol';
import { FunctionsClient } from '@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol';
import { FunctionsRequest } from '@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol';
import { FunctionsSource } from './FunctionsSource.sol';

//@note using CL Functions
//helper smart contract will be used to periodically get price details of our real-world assets
//using Chainlink Automation and Chainlink Functions combined.
contract RealEstatePriceDetails is FunctionsClient, FunctionsSource, OwnerIsCreator {
  using FunctionsRequest for FunctionsRequest.Request;

  struct PriceDetails {
    uint80 listPrice;
    uint80 originalListPrice;
    uint80 taxAssessedValue;
  }

  address internal s_automationForwarderAddress;

  mapping(uint256 tokenId => PriceDetails) internal s_priceDetails;

  error OnlyAutomationForwarderOrOwnerCanCall();

  modifier onlyAutomationForwarderOrOwner() {
    if (msg.sender != s_automationForwarderAddress && msg.sender != owner()) {
      revert OnlyAutomationForwarderOrOwnerCanCall();
    }
    _;
  }

  constructor(address functionsRouterAddress) FunctionsClient(functionsRouterAddress) {}

  function setAutomationForwarder(address automationForwarderAddress) external onlyOwner {
    s_automationForwarderAddress = automationForwarderAddress;
  }

  function updatePriceDetails(
    string memory tokenId,
    uint64 subscriptionId,
    uint32 gasLimit,
    bytes32 donID
  ) external onlyAutomationForwarderOrOwner returns (bytes32 requestId) {
    FunctionsRequest.Request memory req;
    //@note js function defined in FunctionsSource contract : getPrices
    //initialize a request to retrieve data from an inline JavaScript function
    //set up the request configuration to expect JavaScript code rather than fetching data from an API or an external source
    req.initializeRequestForInlineJavaScript(this.getPrices());

    //@note provide an arg => defined in js: const tokenId = args[0]
    string[] memory args = new string[](1);
    args[0] = tokenId;

    req.setArgs(args);

    //@note execute the js function using _sendRequest
    requestId = _sendRequest(req.encodeCBOR(), subscriptionId, gasLimit, donID);
  }

  function getPriceDetails(uint256 tokenId) external view returns (PriceDetails memory) {
    return s_priceDetails[tokenId];
  }

  //@note request callback => reverts if there is an error
  //handle the response from a Chainlink oracle after it processes a data request or computation
  function fulfillRequest(bytes32, /*requestId*/ bytes memory response, bytes memory err) internal override {
    if (err.length != 0) {
      revert(string(err));
    }

    //@note args returned by our getPrices js function : return ethers.getBytes(encoded);
    (uint256 tokenId, uint256 listPrice, uint256 originalListPrice, uint256 taxAssessedValue) = abi.decode(
      response,
      (uint256, uint256, uint256, uint256)
    );

    s_priceDetails[tokenId] = PriceDetails({
      listPrice: uint80(listPrice),
      originalListPrice: uint80(originalListPrice),
      taxAssessedValue: uint80(taxAssessedValue)
    });
  }
}
