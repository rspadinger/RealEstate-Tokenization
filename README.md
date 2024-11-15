## RWA primer

https://excalidraw.com/

- https://blog.chain.link/real-world-assets-rwas-explained/
- https://chain.link/education-hub/tokenized-real-estate
- https://bridgedataoutput.com/docs/explorer/reso-web-api#oShowProperty
- https://api.bridgedataoutput.com/api/v2/OData/test/Property('P_5dba1fb94aa4055b9f29696f')?access_token=6baca547742c6f96a6ff71b138424f21
- https://docs.chain.link/chainlink-functions/tutorials/abi-decoding#handling-complex-data-types-with-abi-encoding-and-decoding
- https://www.npmjs.com/package/@chainlink/functions-toolkit
- https://cll-devrel.gitbook.io/ccip-masterclass-3/ccip-masterclass/building-cross-chain-nfts
- https://github.com/smartcontractkit/chainlink-local
- https://docs.chain.link/chainlink-automation/concepts/best-practice#use-the-forwarder

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

- forge install smartcontractkit/ccip@9686b07 --no-commit
- forge install smartcontractkit/chainlink@2425ea5 --no-commit
- forge install smartcontractkit/chainlink-local@6e92e6d --no-commit

**All chainlink libs need to be installed as NPM packages:**

npm i @chainlink/contracts @chainlink/contracts-ccip @chainlink/local
