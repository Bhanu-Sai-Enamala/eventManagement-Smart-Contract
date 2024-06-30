// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EventFactory {
    address[] public deployedEvents;

    event EventCreated(address eventAddress, string name, uint ticketPrice);

    function createEvent(string memory name, uint ticketPrice, uint ticketSupply) public {
        Event newEvent = new Event(name, ticketPrice, ticketSupply, msg.sender);
        deployedEvents.push(address(newEvent));
        emit EventCreated(address(newEvent), name, ticketPrice);
    }

    function getDeployedEvents() public view returns (address[] memory) {
        return deployedEvents;
    }
}

contract Event {
    struct Ticket {
        address owner;
        bool isUsed;
    }

    string public name;
    uint public ticketPrice;
    uint public ticketSupply;
    address public manager;
    uint public ticketsSold;

    mapping(uint => Ticket) public tickets;
    uint[] public availableTickets;

    event TicketPurchased(address buyer, uint ticketId);
    event TicketUsed(uint ticketId);
    event TicketRefunded(address owner, uint ticketId);
    event TicketTransferred(address from, address to, uint ticketId);

    modifier onlyManager {
        require(msg.sender == manager, "Only manager can perform this action");
        _;
    }

    modifier validTicket(uint ticketId) {
        require(ticketId < ticketSupply, "Invalid ticket ID");
        _;
    }

    modifier ticketOwner(uint ticketId) {
        require(tickets[ticketId].owner == msg.sender, "You do not own this ticket");
        _;
    }

    constructor(string memory eventName, uint price, uint supply, address creator) {
        name = eventName;
        ticketPrice = price;
        ticketSupply = supply;
        manager = creator;
        for (uint i = 0; i < ticketSupply; i++) {
            availableTickets.push(i);
        }
    }

    function buyTicket() public payable {
        require(availableTickets.length > 0, "All tickets are sold out");
        require(msg.value == ticketPrice, "Incorrect ticket price");

        uint ticketId = availableTickets[availableTickets.length - 1];
        availableTickets.pop();

        tickets[ticketId] = Ticket({
            owner: msg.sender,
            isUsed: false
        });

        ticketsSold++;
        emit TicketPurchased(msg.sender, ticketId);
    }

    function useTicket(uint ticketId) public validTicket(ticketId) ticketOwner(ticketId) {
        require(!tickets[ticketId].isUsed, "Ticket already used");

        tickets[ticketId].isUsed = true;
        emit TicketUsed(ticketId);
    }

    function requestRefund(uint ticketId) public validTicket(ticketId) ticketOwner(ticketId) {
        require(!tickets[ticketId].isUsed, "Used tickets cannot be refunded");

        address payable ticketHolder = payable(tickets[ticketId].owner);
        tickets[ticketId].owner = address(0);
        ticketsSold--;
        availableTickets.push(ticketId);

        ticketHolder.transfer(ticketPrice);
        emit TicketRefunded(ticketHolder, ticketId);
    }

    function transferTicket(uint ticketId, address newOwner) public validTicket(ticketId) ticketOwner(ticketId) {
        require(!tickets[ticketId].isUsed, "Used tickets cannot be transferred");

        tickets[ticketId].owner = newOwner;
        emit TicketTransferred(msg.sender, newOwner, ticketId);
    }

    function withdrawFunds() public onlyManager {
        address payable managerAddress = payable(manager);
        managerAddress.transfer(address(this).balance);
    }

    function getEventDetails() public view returns (string memory, uint, uint, uint) {
        return (name, ticketPrice, ticketSupply, ticketsSold);
    }

    function getTicketOwners() public view returns (address[] memory) {
        uint count = 0;
        address[] memory owners = new address[](ticketsSold);

        for (uint i = 0; i < ticketSupply; i++) {
            if (tickets[i].owner != address(0)) {
                owners[count] = tickets[i].owner;
                count++;
            }
        }

        return owners;
    }

}
