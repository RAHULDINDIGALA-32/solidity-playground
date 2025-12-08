import { privateKeyToAccount } from 'viem/accounts';
import { createPublicClient, http, Hex } from 'viem';
import { sepolia } from'viem/chains';
import { formatEther } from 'viem/utils';
import dotenv from "dotenv";

dotenv.config();

const priavteKey = process.env.PRIVATE_KEY;
const account = privateKeyToAccount(priavteKey as Hex);

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