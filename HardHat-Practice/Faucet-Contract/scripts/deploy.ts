import {ethers} from "ethers";
import hre from "hardhat";
import { configVariable } from "hardhat/config";
import "dotenv/config";

async function main() {
    //const url = configVariable("SEPOLIA_RPC_URL");
    //const privateKey = configVariable("SEPOLIA_PRIVATE_KEY");
    const url = process.env.SEPOLIA_RPC_URL!;
    const privateKey = process.env.SEPOLIA_PRIVATE_KEY!;

    if(!url || !privateKey) {
        throw new Error("SEPOLIA_RPC_URL or SEPOLIA_PRIVATE_KEY is not defined in environment variables");
    }

    const provider = new ethers.JsonRpcProvider(url);
    const wallet = new ethers.Wallet(privateKey, provider);

    let artifacts = await hre.artifacts.readArtifact("Faucet");

     // Create an instance of a Faucet Factory
    const factory = new ethers.ContractFactory(
        artifacts.abi,
        artifacts.bytecode,
        wallet
    );

    let faucet = await factory.deploy();

    console.log("Deploying Faucet contract...");
    await faucet.waitForDeployment();

    const address = await faucet.getAddress();

    console.log("Faucet Address:", address);
    console.log("Faucet contract deployed!");

    const txn = await faucet.deploymentTransaction();
    console.log("Transaction Hash:", txn?.hash);
}   


main()
    .then()
    .catch((err) =>{
        console.error(err);
        process.exitCode = 1;
    })