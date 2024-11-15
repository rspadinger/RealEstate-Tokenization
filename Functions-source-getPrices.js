//@note dynamic import - useful in contexts where you want to conditionally load libraries =>
//this code will be sent as a whole to CL Functions => thats why we need to load thos elibs dynamically
const { ethers } = await import('npm:ethers@6.10.0');

//@note object that allows encoding and decoding of data according to Ethereum’s ABI => used to prepare data for contract calls
const abiCoder = ethers.AbiCoder.defaultAbiCoder();

//specify arg like: node Functions-source-getPrices.js someArgument
const tokenId = args[0];

//Bridge is an integrated data distribution and licensing platform for real estate => get some test data
const apiResponse = await Functions.makeHttpRequest({
    url: `https://api.bridgedataoutput.com/api/v2/OData/test/Property('P_5dba1fb94aa4055b9f29696f')?access_token=6baca547742c6f96a6ff71b138424f21`,
});

const listPrice = Number(apiResponse.data.ListPrice);
const originalListPrice = Number(apiResponse.data.OriginalListPrice);
const taxAssessedValue = Number(apiResponse.data.TaxAssessedValue);

console.log(`List Price: ${listPrice}`);
console.log(`Original List Price: ${originalListPrice}`);
console.log(`Tax Assessed Value: ${taxAssessedValue}`);

const encoded = abiCoder.encode([`uint256`, `uint256`, `uint256`, `uint256`], [tokenId, listPrice, originalListPrice, taxAssessedValue]);

//takes the encoded byte string and converts it to a raw byte array =>
//some functions may require input in byte format rather than a hex string => an array of 4 distinct raw byte strings, each starting with 0x
return ethers.getBytes(encoded);
