import Image from "next/image";
import { ConnectButton } from "@rainbow-me/rainbowkit";

export default function Home() {
  return (
    <main className="min-h-screen w-full bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-300 flex flex-col items-center justify-center gap-8">
      <h1 className="text-4xl font-bold">
        Welcome to the Viem + RainbowKit DApp!
      </h1>

      <ConnectButton
        label="Connect Wallet"
        showBalance={true}
        accountStatus="address"
        chainStatus="full"
      />
    </main>
  );
}

