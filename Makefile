install:
	forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --commit
	forge remappings > remappings.txt
build:
	forge build
compile:
	forge compile
test:
	forge test