// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Event.sol";

contract EventFactoryTest is Test {
    EventFactory public eventFactory;
    Event public eventInstance;

    address manager;
    address nonManager = address(0x123);

    function setUp() public {
        
        eventFactory = new EventFactory();
        eventFactory.createEvent("First Event", 1 ether, 100);
        address[] memory deployedEvents = eventFactory.getDeployedEvents();
        address eventAddress = deployedEvents[0];
        eventInstance = Event(eventAddress);
        manager = address(this);
        
    }

    function testCreateEvent() public {
        // Create a new event
        eventFactory.createEvent("Second Event", 1 ether, 100);

        // Check that the event is created and pushed to the array
        address[] memory deployedEvents = eventFactory.getDeployedEvents();
        assertEq(deployedEvents.length, 2, "Event count should be 2");
    }

    function testMarksCallerAsManager() public view {
        // Check that the manager is the address that created the event
        assertEq(eventInstance.manager(), manager);
    }

    function testOnlyManagerModifier() public {
        // Attempt to call a manager-only function from a non-manager address
        vm.prank(nonManager);
        vm.expectRevert("Only manager can perform this action");
        eventInstance.withdrawFunds();
    }

    function testValidTicketModifier() public {
        // Attempt to use an invalid ticket ID
        uint invalidTicketId = 101; // Out of range ticket ID
        vm.expectRevert("Invalid ticket ID");
        eventInstance.useTicket(invalidTicketId);
    }

    function testTicketOwnerModifier() public {
        // Attempt to use a ticket not owned by the caller
        eventInstance.buyTicket{value: 1 ether}();
        vm.prank(nonManager);
        vm.expectRevert("You do not own this ticket");
        eventInstance.useTicket(0);
    }

    function testBuyTicket() public {
        uint ticketId = 99;

        // Buy a ticket
        eventInstance.buyTicket{value: 1 ether}();

        // Check that the ticket is owned by the buyer
        (address owner, bool isUsed) = eventInstance.tickets(ticketId);
        assertEq(owner, manager, "Ticket owner should be the buyer");
        assertEq(isUsed, false, "Ticket should not be used");
    }

    function testUseTicket() public {
        uint ticketId = 99;

        // Buy a ticket
        eventInstance.buyTicket{value: 1 ether}();

        // Use the ticket
        eventInstance.useTicket(ticketId);

        // Check that the ticket is marked as used
        (, bool isUsed) = eventInstance.tickets(ticketId);
        assertEq(isUsed, true, "Ticket should be marked as used");
    }

    

    function testTransferTicket() public {
        uint ticketId = 99;
        address newOwner = nonManager;

        // Buy a ticket
        eventInstance.buyTicket{value: 1 ether}();

        // Transfer the ticket
        eventInstance.transferTicket(ticketId, newOwner);

        // Check that the ticket ownership is updated
        (address owner, ) = eventInstance.tickets(ticketId);
        assertEq(owner, newOwner, "Ticket owner should be the new owner");
    }

    
}
