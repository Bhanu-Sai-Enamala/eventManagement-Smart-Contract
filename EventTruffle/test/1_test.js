const EventFactory = artifacts.require("EventFactory");

contract("Event", (accounts) => {
    let eventFactory;
    let eventInstance;
    let manager = accounts[0];

    before(async function () {
        eventFactory = await EventFactory.deployed();
        await eventFactory.createEvent("First Event", web3.utils.toWei('1', 'ether'), 100);
        const [eventAddress] = await eventFactory.getDeployedEvents();
        const abi = require('../build/contracts/Event.json').abi;
        eventInstance = new web3.eth.Contract(abi, eventAddress);
    });

    it("should create a new event", async function () {
        await eventFactory.createEvent("Second Event", web3.utils.toWei('1', 'ether'), 100);
        const deployedEvents = await eventFactory.getDeployedEvents();
        assert.equal(deployedEvents.length, 2);
    });

    it("should mark caller as manager", async function () {
        const managerAddress = await eventInstance.methods.manager().call();
        assert.equal(managerAddress, manager);
    });

    it("should allow buying a ticket", async function () {
        await eventInstance.methods.buyTicket().send({ from: manager, value: web3.utils.toWei('1', 'ether') });
        const ticket = await eventInstance.methods.tickets(99).call();
        assert.equal(ticket.owner, manager);
        assert.equal(ticket.isUsed, false);
    });

    it("should allow using a ticket", async function () {
        await eventInstance.methods.buyTicket().send({ from: manager, value: web3.utils.toWei('1', 'ether') });
        await eventInstance.methods.useTicket(98).send({ from: manager });
        const ticket = await eventInstance.methods.tickets(98).call();
        assert.equal(ticket.isUsed, true);
    });

    it("should allow requesting a refund", async function () {
        await eventInstance.methods.buyTicket().send({ from: manager, value: web3.utils.toWei('1', 'ether') });
        const initialBalance = await web3.eth.getBalance(manager);
        await eventInstance.methods.requestRefund(97).send({ from: manager });
        const ticket = await eventInstance.methods.tickets(97).call();
        const finalBalance = await web3.eth.getBalance(manager);
        assert.equal(ticket.owner, '0x0000000000000000000000000000000000000000');
        assert.isTrue(new web3.utils.BN(finalBalance).gt(new web3.utils.BN(initialBalance)));
    });

    it("should allow manager to withdraw funds", async function () {
        await eventInstance.methods.buyTicket().send({ from: manager, value: web3.utils.toWei('1', 'ether') });
        const initialBalance = await web3.eth.getBalance(manager);
        await eventInstance.methods.withdrawFunds().send({ from: manager });
        const finalBalance = await web3.eth.getBalance(manager);
        assert.isTrue(new web3.utils.BN(finalBalance).gt(new web3.utils.BN(initialBalance)));
    });
});
