const { expect } = require("chai");
const hre = require("hardhat");
const { ethers } = hre;

describe("EventFactory", function () {
    let eventFactory;
    let eventInstance;
    let manager;
    let nonManager;

    before(async function () {

        [manager, nonManager] = await hre.ethers.getSigners();
        const EventFactory = await hre.ethers.getContractFactory("EventFactory");
        eventFactory = await EventFactory.deploy();
        await eventFactory.createEvent("First Event", hre.ethers.parseEther("1"), 100);
        const deployedEvents = await eventFactory.getDeployedEvents();
        const eventAddress = deployedEvents[0];
        const Event = await hre.ethers.getContractFactory("Event");
        eventInstance = Event.attach(eventAddress);
        
    });

    beforeEach(async function () {
        // Take a snapshot before each test
        snapshotId = await hre.network.provider.send("evm_snapshot");
    });

    afterEach(async function () {
        // Revert to the snapshot after each test
        await hre.network.provider.send("evm_revert", [snapshotId]);
    });


    it("should create a new event", async function () {
        await eventFactory.createEvent("Second Event", ethers.parseEther("1"), 100);
        const deployedEvents = await eventFactory.getDeployedEvents();
        expect(deployedEvents.length).to.equal(2);
    });

    it("should mark caller as manager", async function () {
        const managerAddress = await eventInstance.manager();
        expect(managerAddress).to.equal(manager.address);
    });

    it("should enforce only manager can withdraw funds", async function () {
        await expect(
            eventInstance.connect(nonManager).withdrawFunds()
        ).to.be.revertedWith("Only manager can perform this action");
    });

    it("should enforce valid ticket ID", async function () {
        const invalidTicketId = 101;
        await expect(eventInstance.useTicket(invalidTicketId)).to.be.revertedWith("Invalid ticket ID");
    });

    it("should enforce ticket ownership", async function () {
        await eventInstance.buyTicket({ value: ethers.parseEther("1") });
        await expect(
            eventInstance.connect(nonManager).useTicket(99)
        ).to.be.revertedWith("You do not own this ticket");
    });

    it("should allow buying a ticket", async function () {
        await eventInstance.buyTicket({ value: ethers.parseEther("1") });

        const ticket = await eventInstance.tickets(99); // Assuming ticket ID starts from 0
        expect(ticket.owner).to.equal(manager.address);
        expect(ticket.isUsed).to.be.false;
    });

    it("should allow using a ticket", async function () {
        await eventInstance.buyTicket({ value: ethers.parseEther("1") });
        await eventInstance.useTicket(99); // Assuming ticket ID starts from 0

        const ticket = await eventInstance.tickets(99); // Assuming ticket ID starts from 0
        expect(ticket.isUsed).to.be.true;
    });

    it("should allow transferring a ticket", async function () {
        const newOwner = nonManager.address;

        await eventInstance.buyTicket({ value: ethers.parseEther("1") });
        await eventInstance.transferTicket(99, newOwner); 

        const ticket = await eventInstance.tickets(99); 
        expect(ticket.owner).to.equal(newOwner);
    });
});
