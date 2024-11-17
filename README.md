## RWA Contracts

**ERC1155:** 

* A multi-token standard that can handle both fungible (identical, interchangeable) and non-fungible tokens within a single contract. 
* Uses a single contract for multiple tokens (different real estate properties)
* Supports batch transfers, allowing multiple tokens (both fungible and non-fungible) to be sent in a single transaction, reducing gas fees and improving efficiency.
* Metadata is more flexible and can be shared across tokens
* With ERC1155, upon minting, for each non-fungible asset (id) one can mint N amount of fungible tokens to represent that non-fungible asset

**Issuer: deployed to main chain => issues (mints RWA tokens)**

issue: retrieve RWA metadata from off-chain API for specific, hardcoded property using CL Functions => returns IPFS link to RWA metadata => mint specified amount of NFT to receiver address => when mint is called on ERC1155, tokenURI is set => the minted NFT corresponds with a specific property & by providing an amount value, this property is fractionalized (can be divided in amount equal perts - fungible aspect of ERC1155).


**ERC1155Core is ERC1155Supply => base contract for CrossChainBurnAndMintERC1155**

SV: _tokenURIs[id=>url]

mint (set tokenURI), burn & setURI


**CrossChainBurnAndMintERC1155 is ERC1155Core => add CCIP features**

SVs: IRouterClient, LinkTokenInterface, currentChainSelector, chains[chainSelector=>NFTDetails]  

enableChain & disableChain : allow/disallow transfer to other chain

crossChainTransferFrom : burn token on source chain => create EVM2AnyMessage (receiver, data, feeToken) => calculate fee for message => call ccipRouter.ccipSend to transfer message

ccipReceive : allows to receive a message from another chain => decode message data => mint token for receiver


**RealEstatePriceDetails => uses CL Functions to retrieve RWA price data from offchain API**

SVs: priceDetails[tokenId=>PriceDetails] , automationForwarderAddress

updatePriceDetails : called every 24h by CL Upkeep => calls a CL Function (getPrices - js function executed by CL) to retrieve price daata from offchain API
fulfillRequest : callback from CL Function call => decode response => update priceDetails SV


**RealEstateToken is CrossChainBurnAndMintERC1155, RealEstatePriceDetails => contains only a constructor that calls the constructors of CrossChainBurnAndMintERC1155 &  RealEstatePriceDetails**


## Deployment

**Deploy the RealEstateToken.sol token to Avalanche Fuji, provide the following constructor details:**

- uri\_: "" (this is the base ERC-1155 token URI - leave it empty)

- ccipRouterAddress Fuji: 0xF694E193200268f9a4868e4Aa017A0118C9a8177
- ccipRouterAddress Sepolia: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59

- linkTokenAddress Fuji: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846
- linkTokenAddress Sepolia: 0x779877A7B0D9E8603169DdbD7836e478b4624789

- currentChainSelector Fuji: 14767482510784806043
- currentChainSelector Sepolia: 16015286601757825753

- functionsRouterAddress Fuji: 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0
- functionsRouterAddress Sepolia: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0

**Deploy Issuer.sol to Avalanche Fuji:**

- realEstateToken: The address of the RealEstateToken.sol contract

- functionsRouterAddress Fuji: 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0
- functionsRouterAddress Sepolia: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0

**CL Functions - create a subscription: https://functions.chain.link/**

**Install Packages:**

- forge install foundry-rs/forge-std@bb4ceea --no-commit
- forge install OpenZeppelin/openzeppelin-contracts@dbb6104 --no-commit
- forge install smartcontractkit/foundry-chainlink-toolkit --no-commit

The following packages need to be installed as node modules - need to be added to package.json:

- forge install smartcontractkit/ccip@9686b07 --no-commit
- forge install smartcontractkit/chainlink@2425ea5 --no-commit
- forge install smartcontractkit/chainlink-local@6e92e6d --no-commit

**All chainlink libs need to be installed as NPM packages:**

"dependencies": {
    "@chainlink/env-enc": "^1.0.5",
    "@chainlink/functions-toolkit": "^0.2.8",
    "@chainlink/contracts": "^1.2.0",
    "@chainlink/contracts-ccip": "^1.4.0",
    "@chainlink/local": "^0.2.1"
}  

**Deploy DeployRealEstateToken:**

* source .env => load env variables
* Test: echo $sepolia => if the variable is not found, execute: export sepolia=$(grep ALCHEMY_SEPOLIA_API_URL .env | cut -d '=' -f2)
* Deploy: forge script script/DeployRealEstateToken.s.sol:DeployRealEstateToken --rpc-url $sepolia --broadcast --verify -vvvv


**Deploy Issuer:**

* forge script script/DeployIssuer.s.sol:DeployIssuer --rpc-url $sepolia --broadcast --verify -vvvv

**Create Chainlink Functions Subscription at: https://functions.chain.link/**

* Docs: https://docs.chain.link/chainlink-functions/getting-started
* Function Playground: https://functions.chain.link/playground 
* Params (donId...) : https://functions.chain.link/sepolia
* CCIP params: https://docs.chain.link/ccip/directory/testnet
* Create Subscription : https://sepolia.etherscan.io/tx/0xe93cd6a14b23de9f346eb53d9fdbc54d54d92a4d5beb9d779a3cdfff766d7b87
* Fund subscription with 10 LINK
* Add Issuer & RealEstateToken as Consumers: 0xa41E46d9fAdC55c47ce08F94661ee6669fC8D138 & 0xaF5b99607B33319694Da56Df6B6DE6C125359f22
* Important: Your consumer address must use the Subscription ID 3937 in the Functions request to make use of these funds
* Subscription details: https://functions.chain.link/sepolia/3937 

**Call the issue function of the Issuer SC:**

* Args: to: 0x46F98920C5896Eff11BB90d784D6D6001d74c073 , subscriptionId: 3937 , gasLimit: 300000 , 
    donID: 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000 (Sepolia)
* There is a possibility that the first Functions request might revert => call the cancelPendingRequest() function from the owner() address & repeate issue call
* Txn: https://sepolia.etherscan.io/tx/0x530fca65fe9922ae68046aeacca9bad5d50d6fa91fb07141f54c75a9038a2c0e

**Create Chainlink Automation Subscription: https://automation.chain.link/**

* Use a time-based trigger (every 24h : 0 0 * * *)
* target contract: RealEstateToken (0xaF5b99607B33319694Da56Df6B6DE6C125359f22)
* target function: updatePriceDetails => provide tokenId (eg: 0) , subscriptionId: 3937 , gasLimit: 300000 & donId
* Set 10 Link as starting balance

**Call the setAutomationForwarder function of the RealEstateToken SC:**

* Each registered upkeep under the Chainlink Automation network has its own unique Forwarder contract =>
* call setAutomationForwarder  with that address

**Enable Cross-chain transfers:**

* Deploy the RealEstateToken.sol smart contract on a new blockchain - eg: Avalanche Fuji

* Call the enableChain function and provide chainSelector, xNftAddress and ccipExtraArgs for each of other blockchains where RealEstateToken was deployed => do this for each RealEstateToken instance on all blckchains


## RwaLending

- Lock certain amount of ERC1155 tokens that represent RWA in this contract, and get a loan in USDC in return
- Once user repay its debt in USDC, gets its ERC1155 tokens in return
- If value of an asset drops below liquidation threshold, anyone can liquidate this position and User loses its ERC1155 tokens (fractionalized share of an asset)


## Selling fractionalized RWA on an English Auction

* The address which deployed the contract will be listed as seller. 
* When the seller calls the startAuction function, the contract will lock her ERC-1155 tokens inside it. 
* The auction lasts for 7 days. 
* The bidding is in native tokens (eg: ETH). Anyone can bid, by depositing a greater amount than the current highest bidder. 
* All bidders can withdraw their bids, excluding the current highest bidder. 
* After 7 days, anyone can call the endAuction function which will transfer ERC-1155 real estate tokens to the highest bidder and the highest bid amount to the seller.

## Resources

- https://excalidraw.com/
- https://blog.chain.link/real-world-assets-rwas-explained/
- https://chain.link/education-hub/tokenized-real-estate
- https://bridgedataoutput.com/docs/explorer/reso-web-api#oShowProperty
- https://api.bridgedataoutput.com/api/v2/OData/test/Property('P_5dba1fb94aa4055b9f29696f')?access_token=6baca547742c6f96a6ff71b138424f21
- https://docs.chain.link/chainlink-functions/tutorials/abi-decoding#handling-complex-data-types-with-abi-encoding-and-decoding
- https://www.npmjs.com/package/@chainlink/functions-toolkit
- https://cll-devrel.gitbook.io/ccip-masterclass-3/ccip-masterclass/building-cross-chain-nfts
- https://github.com/smartcontractkit/chainlink-local
- https://docs.chain.link/chainlink-automation/concepts/best-practice#use-the-forwarder

