// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BikeChain {
    address owner;
    uint ownerBalance;

    constructor() {
        owner = msg.sender;
    }

    modifier isRenter(address walletAddress) {
        require(
            msg.sender == walletAddress,
            "You can only manage your account"
        );
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Not Authorized");
        _;
    }

    // Add yourself as a Renter
    struct Renter {
        address payable walletAddress;
        string firstName;
        string lastName;
        bool canRent;
        bool active;
        uint balance;
        uint due;
        uint start;
        uint end;
    }

    mapping(address => Renter) public renters;

    function addRenter(
        address payable walletAddress,
        string memory firstName,
        string memory lastName,
        bool canRent,
        bool active,
        uint balance,
        uint due,
        uint start,
        uint end
    ) public {
        renters[walletAddress] = Renter(
            walletAddress,
            firstName,
            lastName,
            canRent,
            active,
            balance,
            due,
            start,
            end
        );
    }

    // Check out Bike
    function checkOut(address walletAddress) public {
        // TODO: can't checkout if no credit present
        require(renters[walletAddress].due == 0, "You have a pending balance");
        require(
            renters[walletAddress].canRent == true,
            "You cannot rent at this time"
        );
        renters[walletAddress].active = true;
        renters[walletAddress].start = block.timestamp;
        renters[walletAddress].canRent = false;
    }

    // Check in bike
    function checkIn(address walletAddress) public {
        require(
            renters[walletAddress].active == true,
            "Please check out a bike first"
        );
        renters[walletAddress].active = false;
        renters[walletAddress].end = block.timestamp;
        renters[walletAddress].canRent = true;
        // TODO: set the amount due
        setDue(walletAddress);
    }

    // Get total duration of bike use
    function renterTimespan(uint start, uint end) internal pure returns (uint) {
        return end - start;
    }

    function getTotalDuration(
        address walletAddress
    ) public view returns (uint) {
        if (
            renters[walletAddress].start == 0 || renters[walletAddress].end == 0
        ) return 0;
        uint timespan = renterTimespan(
            renters[walletAddress].start,
            renters[walletAddress].end
        );
        uint timespanInMinutes = timespan / 60;
        return timespanInMinutes;
    }

    // Get contract balance
    function balanceOf() public view onlyOwner returns (uint) {
        return address(this).balance;
    }

    // Get owner balance
    function getOwnerBalance() public view onlyOwner returns (uint) {
        return ownerBalance;
    }

    // Withdraw Owner Balance
    function withdrawOwnerBalance() public payable {
        payable(owner).transfer(ownerBalance);
        ownerBalance = 0;
    }

    // Get Renter's balance
    function balanceOfRenter(address walletAddress) public view returns (uint) {
        return renters[walletAddress].balance;
    }

    // Set due amount
    function setDue(address walletAddress) internal {
        uint timespanInMinutes = getTotalDuration(walletAddress);
        uint fiveMinuteIncrements = timespanInMinutes / 5;
        renters[walletAddress].due = fiveMinuteIncrements * (5000000000000000);
        // Instead of hardcoding, I should get latest USD and
        // charge some percent of it per 5 minutes
    }

    function canRentBike(address walletAddress) public view returns (bool) {
        return renters[walletAddress].canRent;
    }

    // Deposit
    function deposit(address walletAddress) public payable {
        renters[walletAddress].balance += msg.value;
    }

    // Make payment
    function makePayment(address walletAddress, uint amount) public {
        require(
            renters[walletAddress].due > 0,
            "You do not have anything due at this time"
        );
        require(
            renters[walletAddress].balance > amount,
            "You do not have enough funds to cover the payment. Please make a deposit"
        );
        renters[walletAddress].balance -= amount;
        ownerBalance += amount;
        renters[walletAddress].canRent = true;
        renters[walletAddress].due = 0;
        renters[walletAddress].start = 0;
        renters[walletAddress].end = 0;
    }

    function getDue(address walletAddress) public view returns (uint) {
        return renters[walletAddress].due;
    }

    function getRenter(
        address walletAddress
    )
        public
        view
        returns (
            string memory firstName,
            string memory lastName,
            bool canRent,
            bool active
        )
    {
        firstName = renters[walletAddress].firstName;
        lastName = renters[walletAddress].lastName;
        canRent = renters[walletAddress].canRent;
        active = renters[walletAddress].active;
    }

    function renterExists(address walletAddress) public view returns (bool) {
        return renters[walletAddress].walletAddress != address(0);
    }
}
