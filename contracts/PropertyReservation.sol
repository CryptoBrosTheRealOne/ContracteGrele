// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "./PropertyManagement.sol";

contract PropertyReservation {
    // Referință către contractul de administrare a proprietăților
    PropertyManagement public propertyManagement;

    // Evenimente
    event ReservationCreated(address indexed user, uint propertyId);

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
    function reserveProperty(uint _propertyId) external onlyAuthenticated {
        // Verificăm disponibilitatea proprietății
        PropertyManagement.Property memory property = propertyManagement.getProperty(_propertyId);
        require(property.available, "Property is not available for reservation.");
        propertyManagement.updateAvailability(_propertyId, false);
        // Creăm rezervarea
        emit ReservationCreated(msg.sender, _propertyId);
    }
}
