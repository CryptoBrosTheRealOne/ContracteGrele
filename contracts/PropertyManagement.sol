// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract PropertyManagement {
    struct Property {
        uint256 id;
        address owner;
        string location;
        string description;
        uint256 pricePerNight;
        bool available;
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
        string memory _location,
        string memory _description,
        uint256 _pricePerNight
    ) external {
        properties[nextPropertyId] = Property({
            id: nextPropertyId,
            owner: msg.sender,
            location: _location,
            description: _description,
            pricePerNight: _pricePerNight,
            available: true
        });

        emit PropertyAdded(nextPropertyId, msg.sender, _location);
        nextPropertyId++;
    }

    function updateAvailability(uint256 _propertyId, bool _available)
        external
        onlyOwner(_propertyId)
    {
        properties[_propertyId].available = _available;
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
