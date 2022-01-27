const {token, fee, vrfDelay, newOwner} = require("./config")

async function main() {

  const CoinFlip = await hre.ethers.getContractFactory("CoinFlip");
  const coinFlip = await CoinFlip.deploy(token, fee, vrfDelay);
  await coinFlip.transferOwnership(newOwner)

  await coinFlip.deployed();

  console.log("Coin flip deployed to:", coinFlip.address, "and contract ownership transferred to:", newOwner);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
