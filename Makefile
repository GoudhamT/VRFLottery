include .env

install:
	forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --commit
	forge install transmissions11/solmate@v6
	forge install Cyfrin/foundry-devops
	forge remappings > remappings.txt
build:
	forge build
compile:
	forge compile
test:
	forge test
fund-subscription:
	forge script script/Interactions.s.sol:FundSubscription --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast
create-subscription:
	forge script script/Interactions.s.sol:CreateSubscription --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast -vvv

subscription-directly:
	forge script script/Interactions.s.sol:CreateSubscriptionDirectly --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast -vvvv

deploy-sepolia:
	forge script script/DeployScript.s.sol:DeployScript --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast -vvvv