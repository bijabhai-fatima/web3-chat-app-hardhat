 
const hre = require("hardhat");

async function main() { 

  const chatApp = await hre.ethers.deployContract("ChatApp");

  await chatApp.waitForDeployment(); 
  
}
 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
