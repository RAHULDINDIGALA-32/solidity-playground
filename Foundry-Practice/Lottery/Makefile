-include .env

.PHONY: all test deploy install build deploy-sepolia

build:
	forge build

test:
	forge test

install:
	forge install cyfrin/foundry-devops && \
	forge install smartcontractkit/chainlink-brownie-contracts && \
	forge install foundry-rs/forge-std && \
	forge install transmissions11/solmate

deploy-sepolia:
	@forge script script/DeployRaffle.s.sol:DeployRaffle \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--account defaultAcc \
		--broadcast \
		--verify

verify-contract:
	@forge verify-contract \
		$(TO_VERIFY_CONTARCT_ADDRESS) \
		src/Raffle.sol:Raffle \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--show-standard-json-input \
		> raffle.json
