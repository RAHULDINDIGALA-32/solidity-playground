import { privateKeyToAccount } from 'viem/accounts';
import { createWalletClient, http, Hex, publicActions, getContract, parseAbiItem } from 'viem';
import { sepolia } from'viem/chains';
import dotenv from "dotenv";
import smileJson from '../artifacts/Smile.json';

dotenv.config();

const priavteKey = process.env.PRIVATE_KEY;
const account = privateKeyToAccount(priavteKey as Hex);
const contractAddress = "0x22366f4a678cc624b682e62f9854bf6fce727ab0";

const {abi: smileAbi, bytecode: smileBytecode} = smileJson;

(async () => {
    const client = await createWalletClient({
        account,
        chain: sepolia,
        transport: http(process.env.SEPOLIA_RPC_URL),
    }).extend(publicActions);

    const contract = await getContract({
        address: contractAddress,
        abi: smileAbi,
        client,
    });

    const latestBlock = await client.getBlockNumber();

    const events = await client.getLogs({
        address: contractAddress,
        event: parseAbiItem('event SmileyChanged(string indexed oldSmiley, string newSmiley)'),
        fromBlock: latestBlock - 9n,
        toBlock: latestBlock,
    })
    
    // const events = await contract,getEvents.SmileyChanged({
    //     fromBlock: latestBlock - 9n,
    //     toBlock: latestBlock,
    // });

    console.log("SmileyChanged Events: ", events);


    if (contract.watchEvent?.SmileyChanged) {
        await contract.watchEvent.SmileyChanged({
            onLogs: (logs) => console.log("\nNew SmileyChanged Event: ", logs),
        });
    }

    const smiles = ["😀", "😃", "😄", "😁", "😆", "😅", "🤣", "😂", "🙂", "🙃"];
    setInterval(async () =>{
        const randomSmile = smiles[Math.floor(Math.random() * smiles.length)];
        if(contract.write?.setSmiley){
            const writeTxnHash = await contract.write.setSmiley([randomSmile]);
            await client.waitForTransactionReceipt({
            hash: writeTxnHash,
        });
             console.log("\nUpdated Smiley to: ", randomSmile);
        }
    }, 3000);
  }
)();

