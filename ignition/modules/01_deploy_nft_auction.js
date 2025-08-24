
const { deployments, upgrades } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  console.log("Starting deployment of NFTAuction...");
  const { save } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying NFTAuction with the account:", deployer);

  const NFTAuction = await ethers.getContractFactory("NFTAuction");

  const nftAuctionProxy = await upgrades.deployProxy(NFTAuction, [], { initializer: 'initialize' });

  await nftAuctionProxy.waitForDeployment();

  const nftAuctionAddress = await nftAuctionProxy.getAddress();

  console.log("NFTAuction deployed to:", nftAuctionAddress);
  console.log("NFTAuction deployed by:", deployer);
  console.log("NFTAuction deployed at:", nftAuctionProxy.target);

  // await deploy('NFTAuction', {
  //   from: deployer,
  //   args: ['Hello'],
  //   log: true,
  // });
};
module.exports.tags = ['deployNFTAuction'];