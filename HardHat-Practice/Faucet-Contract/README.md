# 💧 Faucet Smart Contract — Hardhat v3 + Ethers.js + TypeScript

A simple **Faucet** smart contract project built using **Hardhat v3**, **Ethers.js v6**, and **TypeScript**, and deployed on the **Sepolia Testnet**.

> ✅ **Deployed Address (Sepolia):**  
> `0xc1e7FD7eA9A428d082FeF7Bf610217e858B917dd`

---

## 📘 Project Overview

This project demonstrates:
- Setting up a Hardhat v3 environment using **Mocha** and **Ethers.js**
- Writing and deploying a basic **Faucet contract**
- Managing environment variables for secure deployment
- Deploying to **Sepolia Testnet**
- Using Hardhat v3’s modern configuration system (`configVariable`)

---

## 🔐 Environment Variables

Create a .env file in the project root:
```
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/<YOUR_ALCHEMY_KEY>
SEPOLIA_PRIVATE_KEY=<YOUR_PRIVATE_KEY_HERE>

```

## 🧪 Commands

-  Compile Contracts
 ```
npx hardhat compile
```
- Run Tests

```
npx hardhat test
```
- Deploy to Sepolia
```
npx hardhat run scripts/deploy.ts --network sepolia
```



