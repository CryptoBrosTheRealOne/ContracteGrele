// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Importăm interfața pentru Oracle
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
interface IPropertyManagement {
    function addProperty(
        string memory _name,
        string memory _description,
        uint256 _pricePerNight,
        int256 _latitude,
        int256 _longitude
    ) external;
}
contract PropertyManagement  is IPropertyManagement{
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

    // Adăugăm un nou câmp pentru Oracle
    AggregatorV3Interface internal priceFeed;

    event PropertyAdded(
        uint256 indexed id,
        address indexed owner,
        string location
    );
    event PropertyRemoved(uint256 indexed id, address indexed owner);

    mapping(uint256 => Property) public properties;
    uint256 public nextPropertyId;

    // Modificator pentru a permite doar proprietarului proprietății să execute o funcție
    modifier onlyOwner(uint256 _propertyId) {
        require(
            properties[_propertyId].owner == msg.sender,
            "You are not the owner of this property."
        );
        _;
    }

    // Modificator pentru a verifica dacă ID-ul proprietății este valid
    modifier validPropertyId(uint256 _propertyId) {
        require(_propertyId < nextPropertyId, "Invalid property ID");
        _;
    }

    // Constructor pentru a seta adresa Oracle-ului
    constructor() {
        priceFeed = AggregatorV3Interface(0x5fb1616F78dA7aFC9FF79e0371741a747D2a7F22);
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

    // Funcție pentru a "elimina" o proprietate prin marcarea acesteia ca indisponibilă și resetarea datelor sale
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

    // Funcție pentru a obține prețul curent de la Oracle
    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
}

// Implementăm Proxy Pattern
contract PropertyManagementProxy is IPropertyManagement {
    PropertyManagement private propertyManagement;
    address private owner;

    constructor(address _propertyManagementAddress) {
        propertyManagement = PropertyManagement(_propertyManagementAddress);
        owner = msg.sender; // Setăm proprietarul contractului la adresa care a desfășurat contractul
    }

    // Modificator pentru a permite doar proprietarului să execute o funcție
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "You are not the owner of this contract."
        );
        _;
    }

    function addProperty(
        string memory _name,
        string memory _description,
        uint256 _pricePerNight,
        int256 _latitude,
        int256 _longitude
    ) public override onlyOwner {
        propertyManagement.addProperty(_name, _description, _pricePerNight, _latitude, _longitude);
    }

    function bookProperty(uint256 propertyId, uint256 startDate, uint256 endDate) external {
        propertyManagement.bookProperty(propertyId, startDate, endDate);
    }

    function removeProperty(uint256 _propertyId) external {
        propertyManagement.removeProperty(_propertyId);
    }

    function getProperty(uint256 _propertyId) external view returns (PropertyManagement.Property memory) {
        return propertyManagement.getProperty(_propertyId);
    }

    function getLatestPrice() public view returns (int) {
        return propertyManagement.getLatestPrice();
    }
}