// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract PropertyManagement {
    struct Period {
        uint256 startDate;
        uint256 endDate;
    }

    struct Property {
        uint256 id;
        address owner;
        string name;
        int256 latitude;
        int256 longitude;
        string description;
        uint256 pricePerNight;
        Period[] bookedPeriods;
    }

    event PropertyAdded(
        uint256 indexed id,
        address indexed owner,
        string location
    );
    event PropertyRemoved(uint256 indexed id, address indexed owner);

    mapping(uint256 => Property) public properties;
    uint256 public nextPropertyId;

    // Modifier to allow only the owner of the property to execute a function
    modifier onlyOwner(uint256 _propertyId) {
        require(
            properties[_propertyId].owner == msg.sender,
            "You are not the owner of this property."
        );
        _;
    }
    
    // Modifier to check if property ID is valid
    modifier validPropertyId(uint256 _propertyId) {
        require(_propertyId < nextPropertyId, "Invalid property ID");
        _;
    }

    function addProperty(
        string memory _name,
        string memory _description,
        uint256 _pricePerNight,
        int256 _latitude,
        int256 _longitude
    ) external {
        Property storage p = properties[nextPropertyId];
        p.id = nextPropertyId;
        p.owner = msg.sender;
        p.name = _name;
        p.latitude = _latitude;
        p.longitude = _longitude;
        p.description = _description;
        p.pricePerNight = _pricePerNight;

        emit PropertyAdded(nextPropertyId, msg.sender, _name);
        nextPropertyId++;
    }

    function bookProperty(uint256 propertyId, uint256 startDate, uint256 endDate) external {
        properties[propertyId].bookedPeriods.push(Period({
            startDate: startDate,
            endDate: endDate
        }));
    }

    // Function to "remove" a property by marking it as unavailable and resetting its data
    function removeProperty(uint256 _propertyId)
        external
        onlyOwner(_propertyId)
        validPropertyId(_propertyId)
    {
        emit PropertyRemoved(_propertyId, msg.sender);
        delete properties[_propertyId];
        nextPropertyId--;
    }

    function getProperty(uint256 _propertyId)
        external
        view
        returns (Property memory)
    {
        return properties[_propertyId];
    }
}
