// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Identity {
    struct UserInfo {
        string name;
        string email;
    }

    mapping(address => UserInfo) private identities;

    function createIdentity(string memory _name, string memory _email) public {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_email).length > 0, "Email cannot be empty");
        require(bytes(identities[msg.sender].name).length == 0, "Identity already exists");

        identities[msg.sender] = UserInfo(_name, _email);
    }

    function getIdentity(address _address) public view returns (string memory, string memory) {
        UserInfo memory user = identities[_address];
        require(bytes(user.name).length > 0, "Identity not found");

        return (user.name, user.email);
    }
}




