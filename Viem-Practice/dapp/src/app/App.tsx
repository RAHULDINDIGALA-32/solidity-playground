'use client';

import '@rainbow-me/rainbowkit/styles.css';
import {
    getDefaultConfig,
    RainbowKitProvider,
    darkTheme
} from '@rainbow-me/rainbowkit';
import { WagmiProvider } from 'wagmi';
import {
    mainnet,
    polygon,
    optimism,
    arbitrum,
    base,
    sepolia
} from 'wagmi/chains';
import {
    QueryClientProvider,
    QueryClient,
} from "@tanstack/react-query";
import { providers } from 'web3';


const config = getDefaultConfig({
    appName: 'My RainbowKit App',
    projectId: 'YOUR_PROJECT_ID',
    chains: [mainnet, polygon, optimism, arbitrum, base, sepolia],
    ssr: true, // If your dApp uses server side rendering (SSR)
});

const queryClient = new QueryClient();
const App = ({ children }: { children: React.ReactNode }) => {
    return (
        <WagmiProvider config={config}>
            <QueryClientProvider client={queryClient}>
                <RainbowKitProvider modalSize='wide' theme={darkTheme()} initialChain={sepolia}>
                    {children}
                </RainbowKitProvider>
            </QueryClientProvider>
        </WagmiProvider>
    );
};


export default App;


// Wagmi tutorial without Rainbowkit
// import { createClient } from 'wagmi';
// import { providers } from 'ethers';
// import { WagmiConfig } from 'wagmi';
// import { Children } from 'react';
// export const client = createClient({
//     autoConnect: true,
//     // provider: getDefaultProvider(),
//     provider({chainId}) => {
//        return new providers.AlchemyProvider(ChainIdMismatchError, apiKey)
//        }
// });


// const App = ({children}: {children: React.ReactNode}) => {
//     return(
//         <WagmiConfig client={client}>
//             {children}
//         </WagmiConfig>
//     )
// }





