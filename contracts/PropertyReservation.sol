// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "./PropertyManagement.sol";
import "https://github.com/ConsenSysMesh/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol";

contract PropertyReservation is ERC721 {
    using SafeMath for uint256;

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

    event ReservationCreated(address indexed user, uint propertyId);
    mapping(uint => Booking) public bookings;
    uint256 public bookingCount;

    constructor(PropertyManagement _propertyManagement) ERC721("PropertyReservation", "PROP") {
        propertyManagement = _propertyManagement;
    }

    modifier onlyAuthenticated() {
        require(msg.sender != address(0), "User not authenticated.");
        _;
    }

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
        uint256 totalPrice = totalDays.mul(property.pricePerNight);

        bookings[bookingCount] = Booking({
            id: bookingCount,
            propertyId: _propertyId,
            startDate: startDate,
            endDate: endDate,
            propertyName: property.name,
            price: totalPrice,
            bookerAddr: msg.sender
        });

        _mint(msg.sender, bookingCount); // Emiterea unui token ERC721 pentru fiecare rezervare
        bookingCount = bookingCount.add(1);
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
