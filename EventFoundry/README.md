# Foundry Smart Contract Project

This folder contains smart contract development using the Foundry framework. The project includes contracts for creating and managing events, along with deployment and test scripts.

## Contracts

### EventFactory.sol
The `EventFactory` contract is responsible for creating and managing events. It keeps track of deployed events and provides a function to create new events.

### Event.sol
The `Event` contract handles the details of an individual event, including ticket sales, usage, refunds, and transfers. It also manages event-specific information such as name, ticket price, ticket supply, and the event manager.

## Deployment

### Deployment Script
The `deploy.s.sol` script is used to deploy the `EventFactory` contract.

## Testing

### Test Script
The `Event.t.sol` script contains various tests to ensure the functionality of the `Event` contract, including creating events, buying tickets, using tickets, requesting refunds, and withdrawing funds.

## Configuration

### Foundry Configuration
In this project, there are secret files used to store sensitive information such as Infura API URLs and mnemonic phrases. These files are added to `.gitignore` to prevent them from being exposed.

- `.env`: Contains the Infura API URL for the Sepolia testnet.
- `.secret`: Contains the secret mnemonic phrase.

Users need to create their own `.env` and `.secret` files in the same directory to deploy and verify the contract source code on various networks.

### Example .gitignore

```gitignore
.env
.secret
node_modules/
out/
