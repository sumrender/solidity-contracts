// SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.0 <0.9.0;

contract EventContract {
    struct Event {
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;
    uint public nextEventId;

    modifier eventExists(uint id) {
        require(events[id].date != 0, "This event does not exist");
        require(
            events[id].date > block.timestamp,
            "Event has already occurred!"
        );
        _;
    }

    function createEvent(
        string memory name,
        uint date,
        uint price,
        uint ticketCount
    ) external {
        require(
            date > block.timestamp,
            "You can organize event only for future dates"
        );
        require(ticketCount > 0, "Ticket count must be greater than 0");

        events[nextEventId] = Event(
            msg.sender,
            name,
            date,
            price,
            ticketCount,
            ticketCount
        );
        nextEventId++;
    }

    function buyTicket(
        uint id,
        uint quantity
    ) external payable eventExists(id) {
        Event storage _event = events[id];
        require(msg.value == (_event.price * quantity), "Not enough ethers");
        require(_event.ticketRemain >= quantity, "Not enough tickets");
        _event.ticketRemain -= quantity;
        tickets[msg.sender][id] += quantity;
    }

    function transferTicket(
        uint id,
        uint quantity,
        address to
    ) external eventExists(id) {
        require(
            tickets[msg.sender][id] >= quantity,
            "You do not have enough tickets"
        );
        tickets[msg.sender][id] -= quantity;
        tickets[to][id] += quantity;
    }
}
