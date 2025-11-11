## Foundry

### Contracts

* Follow the style guide provided by Solidity docs.
* While writing functions use "CEI" (Checks, Effects, Interactions) & "FREI-PI" (Function Requirements, Effects-Interactions, Protocol-Invariants) principles.

### Tests

1. Write deployment scripts
     -- which won't work with zkSync
2. Write tests
    1. local chain
    2. forked testnet
    3. forked mainnet

* To write test functions use "AAA" principle => "Arrange" -> "Act" -> "Assert".