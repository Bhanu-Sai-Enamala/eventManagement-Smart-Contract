# Hardhat Smart Contract Project

This folder contains the smart contract development using the Hardhat framework. The project includes contracts for creating and managing events, along with deployment and test scripts.

## Contracts

### EventFactory.sol

The `EventFactory` contract is responsible for creating and managing events. It keeps track of deployed events and provides a function to create new events.

### Event.sol

The `Event` contract handles the details of an individual event, including ticket sales, usage, refunds, and transfers. It also manages event-specific information such as name, ticket price, ticket supply, and the event manager.

## Deployment

### Deployment Script

The `Event.js` script is used to deploy the `EventFactory` contract.

## Testing

### Test Script

The `eventTest.js` script contains various tests to ensure the functionality of the `Event` contract, including creating events, buying tickets, using tickets, requesting refunds, and withdrawing funds.

## Configuration

### Hardhat Configuration

