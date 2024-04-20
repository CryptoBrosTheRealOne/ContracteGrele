// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "./PropertyManagement.sol";

contract PropertyReservation {
    // Referință către contractul de administrare a proprietăților
    PropertyManagement public propertyManagement;
    struct Booking {
        uint256 id;
        uint propertyId;
        uint startDate;
        uint endDate;
        string propertyName;
        uint price;
        address bookerAddr;
    }

    // Evenimente
    event ReservationCreated(address indexed user, uint propertyId);
    mapping(uint => Booking) public bookings;
    uint256 public bookingCount;

    // Constructor - inițializează contractul cu referința către contractul de administrare a proprietăților
    constructor(PropertyManagement _propertyManagement) {
        propertyManagement = _propertyManagement;
    }

    // Modifier pentru a restricționa accesul doar pentru utilizatorii autentificați
    modifier onlyAuthenticated() {
        require(msg.sender != address(0), "User not authenticated.");
        _;
    }

    // Funcție pentru rezervarea unei proprietăți
    function reserveProperty(uint _propertyId, uint startDate, uint endDate) external onlyAuthenticated {
        require(startDate <= endDate, "Invalid period: start date must be before end date");

        PropertyManagement.Property memory property = propertyManagement.getProperty(_propertyId);
        for (uint256 i = 0; i < property.bookedPeriods.length; i++) {
            PropertyManagement.Period memory period = property.bookedPeriods[i];
            if ((startDate <= period.endDate) && (endDate >= period.startDate)) {
                revert("Property is already booked during this period");
            }
        }

        propertyManagement.bookProperty(_propertyId, startDate, endDate);

        uint256 totalDays = (endDate - startDate) / 1 days + 1;
        uint256 totalPrice = totalDays * property.pricePerNight;

        // Increment booking count and create the booking
        
        bookings[bookingCount] = Booking({
            id: bookingCount,
            propertyId: _propertyId,
            startDate: startDate,
            endDate: endDate,
            propertyName: property.name,
            price: totalPrice,
            bookerAddr: msg.sender
        });

        bookingCount += 1;
        // Creăm rezervarea
        emit ReservationCreated(msg.sender, _propertyId);
    }


    function getMyBookings(address myAddress) public view returns (Booking[] memory) {
        uint count = 0;
        Booking[] memory tempBookings = new Booking[](bookingCount);

        for (uint i = 0; i < bookingCount; i++) {
            if (bookings[i].bookerAddr == myAddress) {
                tempBookings[count] = bookings[i];
                count++;
            }
        }

        // Create a new array with the exact size needed
        Booking[] memory filteredBookings = new Booking[](count);
        for (uint i = 0; i < count; i++) {
            filteredBookings[i] = tempBookings[i];
        }

        return filteredBookings;
    }

    function getBookings() public view returns (Booking[] memory) {
        Booking[] memory tempBookings = new Booking[](bookingCount);

        for (uint i = 0; i < bookingCount; i++) {
                tempBookings[i] = bookings[i];
        }

        return tempBookings;
    }
    
}
