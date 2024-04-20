// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "remix_tests.sol"; // this import is automatically injected by Remix.
import "/contracts/PropertyManagement.sol";

contract PropertyManagementTest {
    PropertyManagement propertyManagement;
    address owner;

    function beforeAll() public {
        owner = msg.sender;
        propertyManagement = new PropertyManagement();
    }

    function checkAddProperty() public {
        propertyManagement.addProperty("Test Property", "A beautiful property", 100, 123456, 654321);
        PropertyManagement.Property memory property = propertyManagement.getProperty(0);
        Assert.equal(property.id, uint256(0), "Property ID should be 0");
        Assert.equal(property.name, "Test Property", "Property name should be 'Test Property'");
        Assert.equal(property.description, "A beautiful property", "Property description should be 'A beautiful property'");
        Assert.equal(property.pricePerNight, uint256(100), "Price per night should be 100");
        Assert.equal(property.latitude, int256(123456), "Latitude should be 123456");
        Assert.equal(property.longitude, int256(654321), "Longitude should be 654321");
    }

    function checkRemoveProperty() public {
        propertyManagement.removeProperty(0);
        PropertyManagement.Property memory property = propertyManagement.getProperty(0);
        Assert.equal(property.id, uint256(0), "Property ID should be 0 after removal");
    }

    function checkBookProperty() public {
        uint256 startDate = block.timestamp;
        uint256 endDate = startDate + 1 days;
        propertyManagement.bookProperty(0, startDate, endDate);
        PropertyManagement.Property memory property = propertyManagement.getProperty(0);
        Assert.equal(property.bookedPeriods[0].startDate, startDate, "Start date should be the same as the booked start date");
        Assert.equal(property.bookedPeriods[0].endDate, endDate, "End date should be the same as the booked end date");
    }
}
