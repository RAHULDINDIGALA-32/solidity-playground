import { privateKeyToAccount } from 'viem/accounts';
import { createPublicClient, http } from 'viem';
import { sepolia } from'viem/chains';
import { formatEther } from 'viem/utils';
import dotenv from "dotenv";

dotenv.config();

const priavteKey = "0xe32db465a675d49e5c1a0f6bb9726b5adf798e1b5dd31eb4a39c84c016cfb9e8";
const account = privateKeyToAccount(priavteKey);

console.log("Account Details: \n", account);

(async () =>{
    const client = createPublicClient({
        chain: sepolia,
        transport: http(process.env.SEPOLIA_RPC_URL),
    })

    const balance = await client.getBalance({
        address: account.address,
    });

    console.log("\n Account Balance: ", formatEther(balance), "ETH");
})();