import { privateKeyToAccount } from 'viem/accounts';
import { createWalletClient, http, Hex, publicActions, getContract } from 'viem';
import { sepolia } from'viem/chains';
import dotenv from "dotenv";
import smileJson from '../artifacts/Smile.json';

dotenv.config();

const priavteKey = process.env.PRIVATE_KEY;
const account = privateKeyToAccount(priavteKey as Hex);

const {abi: smileAbi, bytecode: smileBytecode} = smileJson;

(async () => {
    const client = await createWalletClient({
        account,
        chain: sepolia,
        transport: http(process.env.SEPOLIA_RPC_URL),
    }).extend(publicActions);
    
    const txnHash = await client.deployContract({
        abi: smileAbi,
        bytecode: smileBytecode as Hex,
        args: []
    });

    console.log("Contract Deployment Txn Hash: ", txnHash);
    
    const receipt = await client.waitForTransactionReceipt({
        hash: txnHash,
    });
    
    const contractAddress = receipt.contractAddress;
    console.log("Contract Deployed At Address: ", contractAddress);

    if(contractAddress) {
        const contract = await getContract({
            address: contractAddress,
            abi: smileAbi,
            client: {
                public: client,
                wallet: client,
            },
        });

        const smiley1 = await client.readContract({
            address: contractAddress,
            abi: smileAbi,
            functionName: "getSmiley",
        });

        console.log("\nSmiley Value from Contract: ", smiley1);
        // console.log("Smiley Value from Contract: ", await contract.read.getSmiley());

        // await contract.write.setSmiley(["😎"]);

        // console.log("\nSmiley Value from Contract: ", await contract.read.getSmiley());

        // WRITE
    const writeTxnHash = await client.writeContract({
        address: contractAddress,
        abi: smileAbi,
        functionName: "setSmiley",
        args: ["😎"],
    });

    await client.waitForTransactionReceipt({
        hash: writeTxnHash,
    });

    // READ AGAIN
    const smiley2 = await client.readContract({
        address: contractAddress,
        abi: smileAbi,
        functionName: "getSmiley",
    });
    console.log("Updated Smiley:", smiley2);

    }

})();